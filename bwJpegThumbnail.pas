unit bwJpegThumbnail;

interface

uses
  System.Classes, Vcl.Graphics, bwResample, jpeg;

type
  TThumbnailCompleteEvent = procedure (AThumbnail: TBitmap; AData: Pointer) of object;
  TJpegThumbnail = class(TThread)
  private
    { Private declarations }
  protected
    FData: Pointer;
    FWidth: Cardinal;
    FHeight: Cardinal;
    FSource: TJPEGImage;
    FOnComplete: TThumbnailCompleteEvent;
    procedure Execute; override;
  public
    constructor Create(ASource: TJpegImage; AData: Pointer);
    property Width: Cardinal read FWidth write FWidth;
    property Height: Cardinal read FHeight write FHeight;
    property OnComplete: TThumbnailCompleteEvent read FOnComplete write FOnComplete;
  end;

implementation

{ TResampler }

constructor TJpegThumbnail.Create;
begin
  FData := AData;
  FSource := ASource;
  inherited Create(True);
  FreeOnTerminate := True;
end;

procedure TJpegThumbnail.Execute;
var
  OriginalRatio, DestRatio: Double;
  Large, Small: TBitmap;
begin
  // Calculate dest prop
  OriginalRatio := FSource.Width / FSource.Height;
  DestRatio := FWidth / FHeight;
  Large := TBitmap.Create;
  Small := TBitmap.Create;
  Small.Width := FWidth;
  Small.Height := FHeight;
  if (OriginalRatio >= DestRatio) then begin
    Large.Width := FSource.Width;
    Large.Height := Round(FSource.Width / DestRatio);
    Large.Canvas.Draw(0, Round((Large.Height - FSource.Height) / 2), FSource);
    Stretch(Large, Small, Lanczos3Filter, 3.0);
  end else begin
    Large.Height := FSource.Height;
    Large.Width := Round(FSource.Height * DestRatio);
    Large.Canvas.Draw(Round((Large.Width - FSource.Width) / 2), 0, FSource);
    Stretch(Large, Small, Lanczos3Filter, 3.0);
  end;
  FSource.Free;
  Large.Free;
  Synchronize(procedure begin
    if Assigned(FOnComplete) then
       FOnComplete(Small, FData);
  end);
end;

end.
