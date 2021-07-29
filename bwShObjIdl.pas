unit bwShObjIdl;

interface

{ Extracted roughly from https://github.com/CMCHTPC/WindowsAPI/ on 2021-07-29.
  Used calls were checked and fixed to utilize safecall convention.
  The files were available under Apache License, Version 2.0. }

uses
   Winapi.Windows, Winapi.Messages, Win.ComObj, Win.ComObjWrapper;

type
  TSFGAOF = ULONG;
  TPROPERTYKEY = packed record
    fmtid: TGUID;
    pid: DWORD;
  end;
  TSIATTRIBFLAGS = (
    SIATTRIBFLAGS_AND = $1,
    SIATTRIBFLAGS_OR = $2,
    SIATTRIBFLAGS_APPCOMPAT = $3,
    SIATTRIBFLAGS_MASK = $3,
    SIATTRIBFLAGS_ALLITEMS = $4000
  );
  TGETPROPERTYSTOREFLAGS = (
    GPS_DEFAULT = $00000000,
    GPS_HANDLERPROPERTIESONLY = $00000001,   // only include properties directly from the file's property handler
    GPS_READWRITE = $00000002,   // Writable stores will only include handler properties
    GPS_TEMPORARY = $00000004,   // A read/write store that only holds properties for the lifetime of the IShellItem object
    GPS_FASTPROPERTIESONLY = $00000008,
    GPS_OPENSLOWITEM = $00000010,
    GPS_DELAYCREATION = $00000020,
    GPS_BESTEFFORT = $00000040,
    GPS_NO_OPLOCK = $00000080,   // some data sources protect the read property store with an oplock, this disables that
    GPS_PREFERQUERYPROPERTIES = $00000100,   // For file system WDS results, only retrieve properties from the indexer
    GPS_EXTRINSICPROPERTIES = $00000200,   // include properties from the file's secondary stream
    GPS_EXTRINSICPROPERTIESONLY = $00000400,   // only include properties from the file's secondary stream
    GPS_MASK_VALID = $000007FF
  );
  TSIGDN = (
    SIGDN_NORMALDISPLAY = 0,
    SIGDN_PARENTRELATIVEPARSING = Int32($80018001),
    SIGDN_DESKTOPABSOLUTEPARSING = Int32($80028000),
    SIGDN_PARENTRELATIVEEDITING = Int32($80031001),
    SIGDN_DESKTOPABSOLUTEEDITING = Int32($8004c000),
    SIGDN_FILESYSPATH = Int32($80058000),
    SIGDN_URL = Int32($80068000),
    SIGDN_PARENTRELATIVEFORADDRESSBAR = Int32($8007c001),
    SIGDN_PARENTRELATIVE = Int32($80080001),
    SIGDN_PARENTRELATIVEFORUI = Int32($80094001)
  );
  TSICHINTF = (
    SICHINT_DISPLAY = 0,
    SICHINT_ALLFIELDS = Int32($80000000),
    SICHINT_CANONICAL = $10000000,
    SICHINT_TEST_FILESYSPATH_IF_NOT_EQUAL = $20000000
  );
  TDESKTOP_WALLPAPER_POSITION = (
    DWPOS_CENTER = 0,
    DWPOS_TILE = 1,
    DWPOS_STRETCH = 2,
    DWPOS_FIT = 3,
    DWPOS_FILL = 4,
    DWPOS_SPAN = 5
  );
  TDESKTOP_SLIDESHOW_OPTIONS = (
    DSO_SHUFFLEIMAGES = $1
  );
  TDESKTOP_SLIDESHOW_STATE = (
    DSS_ENABLED = $1,
    DSS_SLIDESHOW = $2,
    DSS_DISABLED_BY_REMOTE_SESSION = $4
  );
  TDESKTOP_SLIDESHOW_DIRECTION = (
    DSD_FORWARD = 0,
    DSD_BACKWARD = 1
  );
  IBindCtx = interface(IUnknown)
    ['{0000000e-0000-0000-C000-000000000046}']
  end;
  IShellItem = interface(IUnknown) // @todo safecall
    ['{43826d1e-e718-42ee-bc55-a1e261c37bfe}']
    function BindToHandler(pbc: IBindCtx; const bhid: TGUID; const riid: TGUID; out ppv): HResult; stdcall;
    function GetParent(out ppsi: IShellItem): HResult; stdcall;
    function GetDisplayName(sigdnName: TSIGDN; out ppszName: LPWSTR): HResult; stdcall;
    function GetAttributes(sfgaoMask: TSFGAOF; out psfgaoAttribs: TSFGAOF): HResult; stdcall;
    function Compare(psi: IShellItem; hint: TSICHINTF; out piOrder: int32): HResult; stdcall;
  end;
  PIShellItem = ^IShellItem;
  IEnumShellItems = interface(IUnknown) // @todo safecall
    ['{70629033-e363-4a28-a567-0db78006e6d7}']
    function Next(celt: ULONG; out rgelt: PIShellItem; out pceltFetched: ULONG): HResult; stdcall;
    function Skip(celt: ULONG): HResult; stdcall;
    function Reset(): HResult; stdcall;
    function Clone(out ppenum: IEnumShellItems): HResult; stdcall;
  end;
  IShellItemArray = interface(IUnknown) // @todo safecall
    ['{b63ea76d-1f85-456f-a19c-48159efa858b}']
    function BindToHandler(pbc: IBindCtx; const bhid: TGUID; const riid: TGUID; out ppvOut): HResult; stdcall;
    function GetPropertyStore(flags: TGETPROPERTYSTOREFLAGS; const riid: TGUID; out ppv): HResult; stdcall;
    function GetPropertyDescriptionList(const keyType: TPROPERTYKEY; const riid: TGUID; out ppv): HResult; stdcall;
    function GetAttributes(AttribFlags: TSIATTRIBFLAGS; sfgaoMask: TSFGAOF; out psfgaoAttribs: TSFGAOF): HResult; stdcall;
    function GetCount(out pdwNumItems: DWORD): HResult; stdcall;
    function GetItemAt(dwIndex: DWORD; out ppsi: IShellItem): HResult; stdcall;
    function EnumItems(out ppenumShellItems: IEnumShellItems): HResult; stdcall;
  end;
  IDesktopWallpaper = interface(IUnknown)
    ['{B92B56A9-8B55-4E14-9A89-0199BBB6F93B}']
    procedure SetWallpaper(monitorID: LPCWSTR; wallpaper: LPCWSTR); safecall;
    function GetWallpaper(monitorID: LPCWSTR): LPWSTR; safecall;
    function GetMonitorDevicePathAt(monitorIndex: UINT): LPWSTR; safecall;
    function GetMonitorDevicePathCount(): UINT; safecall;
    function GetMonitorRECT(monitorID: LPCWSTR): TRECT; safecall;
    procedure SetBackgroundColor(color: TCOLORREF); safecall;
    function GetBackgroundColor(): TCOLORREF; safecall;
    procedure SetPosition(position: TDESKTOP_WALLPAPER_POSITION); safecall;
    function GetPosition(): TDESKTOP_WALLPAPER_POSITION; safecall;
    procedure SetSlideshow(items: IShellItemArray); safecall;
    function GetSlideshow(): IShellItemArray; safecall;
    procedure SetSlideshowOptions(options: TDESKTOP_SLIDESHOW_OPTIONS; slideshowTick: UINT); safecall;
    procedure GetSlideshowOptions(out options: TDESKTOP_SLIDESHOW_OPTIONS; out slideshowTick: UINT); safecall;
    procedure AdvanceSlideshow(monitorID: LPCWSTR; direction: TDESKTOP_SLIDESHOW_DIRECTION); safecall;
    function GetStatus(): TDESKTOP_SLIDESHOW_STATE; safecall;
    procedure Enable(enable: boolean); safecall;
  end;

const
  IID_IDesktopWallpaper: TGUID = '{B92B56A9-8B55-4E14-9A89-0199BBB6F93B}';
  IID_IShellItemArray: TGUID = '{b63ea76d-1f85-456f-a19c-48159efa858b}';
  IID_IEnumShellItems: TGUID = '{70629033-e363-4a28-a567-0db78006e6d7}';
  CLSID_DesktopWallpaper: TGUID = '{C2CF3110-460E-4fc1-B9D0-8A1C0C9CC4BD}';

implementation

end.
