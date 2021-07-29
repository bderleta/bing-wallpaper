unit bwMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  System.IOUtils, bwDesktopWallpaper, System.Types,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, bwBingApi, Vcl.ExtCtrls;

type
  TMainForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    TrayIcon: TTrayIcon;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    BingApi: TBingApi;
    DesktopWallpaper: TDesktopWallpaper;
    function GetStorePath: string;
    function GetMaxResolution: TPoint;
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
    DesktopWallpaper.Wallpaper[I] := BingApi.Images[I + 1].GetLocation;
  end;

end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  Image: TBingImage;
  Resolution: TPoint;
begin
  AllocConsole;
  DesktopWallpaper := TDesktopWallpaper.Create;
  Resolution := GetMaxResolution;
  BingApi := TBingApi.Create(Resolution.X, Resolution.Y, GetStorePath());
  BingApi.Update;
  for Image in BingApi.Images do begin
    Writeln(Image.Title);
    Writeln(Chr(9) + Image.CopyrightText);
    Writeln(Chr(9) + Image.GetLocation);
    Writeln('');
  end;
end;

function TMainForm.GetMaxResolution: TPoint;
var
  I: Integer;
begin
  Result := Point(0, 0);
  for I := 0 to Screen.MonitorCount - 1 do begin
    if Result.X < Screen.Monitors[I].Width then
      Result.X := Screen.Monitors[I].Width;
    if Result.Y < Screen.Monitors[I].Height then
      Result.Y := Screen.Monitors[I].Height;
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
