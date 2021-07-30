unit bwDesktopWallpaper;

interface

uses
  System.IOUtils, Win.ComObj, Win.ComObjWrapper, System.UITypes, System.SysUtils, bwShObjIdl,
  System.Types;

type
  TDesktopWallpaperPosition = (
    dwposCenter = 0,
    dwposTile = 1,
    dwposStretch = 2,
    dwposFit = 3,
    dwposFill = 4,
    dwposSpan = 5
  );
  TDesktopWallpaper = class
  protected
    Intf: IDesktopWallpaper;
    procedure SetEnabled(const AValue: Boolean);
    procedure SetBackgroundColor(const AValue: TColorRef);
    function GetBackgroundColor: TColorRef;
    procedure SetPosition(const AValue: TDesktopWallpaperPosition);
    function GetPosition: TDesktopWallpaperPosition;
    function GetCount: Cardinal;
    function GetDevicePath(AIndex: Cardinal): string;
    function GetWallpaper(AIndex: Cardinal): string;
    procedure SetWallpaper(AIndex: Cardinal; const AValue: string);
    function GetRect(AIndex: Cardinal): TRect;
    function GetMaxResolution: TPoint;
  public
    constructor Create;
    property Enabled: Boolean write SetEnabled;
    property BackgroundColor: TColorRef read GetBackgroundColor write SetBackgroundColor;
    property Position: TDesktopWallpaperPosition read GetPosition write SetPosition;
    property Count: Cardinal read GetCount;
    property Wallpaper[AIndex: Cardinal]: string read GetWallpaper write SetWallpaper;
    property DevicePath[AIndex: Cardinal]: string read GetDevicePath;
    property Rect[AIndex: Cardinal]: TRect read GetRect;
    property MaxResolution: TPoint read GetMaxResolution;
  end;

implementation

constructor TDesktopWallpaper.Create;
begin
  Intf := CreateComObject(CLSID_DesktopWallpaper) as IDesktopWallpaper;
end;

procedure TDesktopWallpaper.SetEnabled;
begin
  Intf.Enable(AValue)
end;

function TDesktopWallpaper.GetMaxResolution;
var
  I: Integer;
  Rect: TRect;
begin
  Result := Point(0, 0);
  for I := 0 to GetCount() - 1 do begin
    Rect := Intf.GetMonitorRECT(Intf.GetMonitorDevicePathAt(I));
    Writeln('Monitor: ', I, ' Left: ', Rect.Left, ' Top: ', Rect.Top, ' Right: ',
      Rect.Right, ' Bottom: ', Rect.Bottom, ' Width: ', Rect.Width, ' Height: ',
      Rect.Height);
    if (Rect.Width >= Result.X) and (Rect.Height >= Result.Y) then begin
       Result.X := Rect.Width;
       Result.Y := Rect.Height;
    end;
  end;
end;

function TDesktopWallpaper.GetRect;
begin
  if AIndex >= GetCount() then
    raise EListError.Create('Index out of bounds');
  Result := Intf.GetMonitorRECT(Intf.GetMonitorDevicePathAt(AIndex));
end;

function TDesktopWallpaper.GetDevicePath;
begin
  if AIndex >= GetCount() then
    raise EListError.Create('Index out of bounds');
  Result := Intf.GetMonitorDevicePathAt(AIndex);
end;

function TDesktopWallpaper.GetWallpaper;
begin
  if AIndex >= GetCount() then
    raise EListError.Create('Index out of bounds');
  Result := Intf.GetWallpaper(Intf.GetMonitorDevicePathAt(AIndex));
end;

procedure TDesktopWallpaper.SetWallpaper;
begin
  if AIndex >= GetCount() then
    raise EListError.Create('Index out of bounds');
  Intf.SetWallpaper(Intf.GetMonitorDevicePathAt(AIndex), PWideChar(AValue));
end;

function TDesktopWallpaper.GetCount;
begin
  Result := Intf.GetMonitorDevicePathCount;
end;

procedure TDesktopWallpaper.SetPosition;
begin
  Intf.SetPosition(TDESKTOP_WALLPAPER_POSITION(AValue));
end;

function TDesktopWallpaper.GetPosition;
begin
  Result := TDesktopWallpaperPosition(Intf.GetPosition);
end;

procedure TDesktopWallpaper.SetBackgroundColor;
begin
  Intf.SetBackgroundColor(AValue);
end;

function TDesktopWallpaper.GetBackgroundColor;
begin
  Result := Intf.GetBackgroundColor;
end;

end.
