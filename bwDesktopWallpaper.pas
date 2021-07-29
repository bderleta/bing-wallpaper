unit bwDesktopWallpaper;

interface

uses
  System.IOUtils, Win.ComObj, Win.ComObjWrapper, System.UITypes, System.SysUtils, bwShObjIdl;

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
  public
    constructor Create;
    property Enabled: Boolean write SetEnabled;
    property BackgroundColor: TColorRef read GetBackgroundColor write SetBackgroundColor;
    property Position: TDesktopWallpaperPosition read GetPosition write SetPosition;
    property Count: Cardinal read GetCount;
    property Wallpaper[AIndex: Cardinal]: string read GetWallpaper write SetWallpaper;
    property DevicePath[AIndex: Cardinal]: string read GetDevicePath;
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
