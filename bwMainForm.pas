unit bwMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  System.IOUtils, bwDesktopWallpaper, System.Types, bwResample,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, bwBingApi, Vcl.ExtCtrls,
  System.ImageList, Vcl.ImgList, Vcl.ComCtrls, jpeg, bwJpegThumbnail,
  System.Generics.Collections;

type
  TMainForm = class(TForm)
    Button1: TButton;
    TrayIcon: TTrayIcon;
    ListView: TListView;
    ImageList: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure OnThumbnailComplete(AOut: TBitmap; AData: Pointer);
  private
    { Private declarations }
  public
    BingApi: TBingApi;
    DesktopWallpaper: TDesktopWallpaper;
    function GetStorePath: string;
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.Button1Click(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to DesktopWallpaper.Count - 1 do begin
    Writeln('Monitor ', I, ': ', DesktopWallpaper.DevicePath[I]);
    Writeln('  wallpaper: ', DesktopWallpaper.Wallpaper[I]);
    DesktopWallpaper.Wallpaper[I] := BingApi.Images[I + 3].GetLocation;
  end;

end;

function HorizontalOrderSortProc(Item1, Item2: TListItem; ParamSort: integer): integer; stdcall;
begin
  if Integer(Item1.Data) = Integer(Item2.Data) then
    Result := 0
  else if Integer(Item1.Data) > Integer(Item2.Data) then
    Result := 1
  else
    Result := -1;
end;

procedure TMainForm.OnThumbnailComplete(AOut: TBitmap; AData: Pointer);
begin
  with ListView.Items.Add do begin
    Caption := 'Monitor ' + IntToStr(Integer(AData) + 1);
    ImageIndex := ImageList.AddMasked(AOut, clWhite);
    Data := Pointer(DesktopWallpaper.Rect[Integer(AData)].Left);
  end;
  ListView.CustomSort(@HorizontalOrderSortProc, 0);
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  Image: TBingImage;
  Resolution, MaxImageSize: TPoint;
  R: TRect;
  I: Integer;
  J: TJPEGImage;
  JO: TObjectList<TJpegThumbnail>;
begin
  AllocConsole;
  ImageList.Clear;
  DesktopWallpaper := TDesktopWallpaper.Create;

  Resolution := DesktopWallpaper.MaxResolution;
  BingApi := TBingApi.Create(Resolution.X, Resolution.Y, GetStorePath());
  BingApi.Update;
  for Image in BingApi.Images do begin
    Image.GetLocation;
  end;

  MaxImageSize := Point(0, 0);
  JO := TObjectList<TJpegThumbnail>.Create;
  for I := 0 to DesktopWallpaper.Count -1 do begin
    if DesktopWallpaper.Wallpaper[I] = '' then begin
      // @todo
    end else begin
      J := TJPEGImage.Create;
      J.LoadFromFile(DesktopWallpaper.Wallpaper[I]);
      if (J.Width > MaxImageSize.X) or (J.Height >= MaxImageSize.Y) then begin
        MaxImageSize.X := J.Width;
        MaxImageSize.Y := J.Height;
      end;
      JO.Add(TJpegThumbnail.Create(J, Pointer(I)));
    end;
  end;

  ImageList.Width := Round((ListView.Width / DesktopWallpaper.Count) * 0.7);
  ImageList.Height := Round(ImageList.Width / (MaxImageSize.X / MaxImageSize.Y));
  for I := 0 to JO.Count - 1 do begin
    JO[I].OnComplete := OnThumbnailComplete;
    JO[I].Width := ImageList.Width;
    JO[I].Height := ImageList.Height;
    JO[I].Start;
  end;
end;

function TMainForm.GetStorePath;
begin
  Result := IncludeTrailingPathDelimiter(
    ExtractFilePath(ParamStr(0)) + 'images'
  );
  TDirectory.CreateDirectory(Result);
  Assert(TDirectory.Exists(Result));
end;

end.
