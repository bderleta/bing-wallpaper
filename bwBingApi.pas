unit bwBingApi;

interface

uses
  Winapi.Windows, System.JSON, System.Generics.Collections, IdIOHandler,
  System.SysUtils, System.Classes,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP;

type
  TBingApi = class;
  TBingImage = class(TObject)
    protected
      FOrigin: TBingApi;
      FStartDate: TDate;
      FEndDate: TDate;
      FUrl: string;
      FUrlBase: string;
      FCopyright: string;
      FCopyrightLink: string;
      FCopyrightText: string;
      FTitle: string;
      FQuiz: string;
      FWp: Boolean;  // ?
      FHash: string;
      FDrk: Integer; // ?
      FTop: Integer; // ?
      FBot: Integer; // ?
      function ParseDate(AValue: string): TDate;
    public
      constructor Create(AOrigin: TBingApi; ASource: TJSONObject);
      function GetLocation: string;
      property Url: string read FUrl;
      property UrlBase: string read FUrlBase;
      property Copyright: string read FCopyright;
      property CopyrightLink: string read FCopyrightLink;
      property CopyrightText: string read FCopyrightText;
      property Title: string read FTitle;
      property Quiz: string read FQuiz;
  end;
  TBingImageList = TObjectList<TBingImage>;
  TBingApi = class
    const
      ListUrlTemplate = 'https://bingwallpaper.microsoft.com/api/BWC/getHPImages?screenWidth=%u&screenHeight=%u&env=live';
    protected
      FClient: TIdHTTP;
      FList: TBingImageList;
      FScreenWidth: Cardinal;
      FScreenHeight: Cardinal;
      FImageStoreLocation: string;
      function SslVerifyPeer(Certificate: TIdX509; AOk: Boolean; ADepth, AError: Integer): Boolean;
    public
      constructor Create(const AScreenWidth, AScreenHeight: Cardinal; AImageStoreLocation: string);
      destructor Destroy; override;
      procedure Update;
      property Images: TBingImageList read FList;
  end;

implementation

constructor TBingImage.Create;
begin
  FOrigin := AOrigin;
  FStartDate := ParseDate(ASource.GetValue<TJSONString>('startdate').Value);
  FEndDate := ParseDate(ASource.GetValue<TJSONString>('enddate').Value);
  FUrl := ASource.GetValue<TJSONString>('url').Value;
  FUrlBase := ASource.GetValue<TJSONString>('urlbase').Value;
  FCopyright := ASource.GetValue<TJSONString>('copyright').Value;
  FCopyrightLink := ASource.GetValue<TJSONString>('copyrightlink').Value;
  FCopyrightText := ASource.GetValue<TJSONString>('copyrighttext').Value;
  FTitle := ASource.GetValue<TJSONString>('title').Value;
  FQuiz := ASource.GetValue<TJSONString>('quiz').Value;
  FHash := ASource.GetValue<TJSONString>('hsh').Value;
  FWp := ASource.GetValue<TJSONBool>('wp').AsBoolean;
  FDrk := ASource.GetValue<TJSONNumber>('drk').AsInt;
  FTop := ASource.GetValue<TJSONNumber>('top').AsInt;
  FBot := ASource.GetValue<TJSONNumber>('bot').AsInt;
end;

function TBingImage.ParseDate;
begin
  Result := EncodeDate(
    StrToInt(Copy(AValue, 1, 4)),
    StrToInt(Copy(AValue, 5, 2)),
    StrToInt(Copy(AValue, 7, 2))
  );
end;

function TBingImage.GetLocation: string;
var
  FStream: TFileStream;
begin
  // @todo Dynamically determine file type
  Result := (FOrigin.FImageStoreLocation + FHash + '.jpg');
  if not FileExists(Result) then begin
    FStream := TFileStream.Create(Result, fmCreate);
    FOrigin.FClient.Get(FUrl, FStream);
    FStream.Free;
  end;
end;

procedure TBingApi.Update;
var
  Body: TJSONObject;
  Images: TJSONArray;
  Image: TJSONValue;
  ListUrl: string;
begin
  ListUrl := Format(Self.ListUrlTemplate, [FScreenWidth, FScreenHeight]);
  Body := TJSONObject.ParseJSONValue(FClient.Get(ListUrl)) as TJSONObject;
  Images := Body.GetValue<TJSONArray>('images');
  FList.Clear;
  for Image in Images do begin
    FList.Add(TBingImage.Create(Self, Image as TJSONObject));
  end;
end;

constructor TBingApi.Create;
begin
  FImageStoreLocation := IncludeTrailingPathDelimiter(AImageStoreLocation);
  FList := TBingImageList.Create(True);
  FClient := TIdHTTP.Create(nil);
  FClient.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(FClient);
  with FClient.IOHandler as TIdSSLIOHandlerSocketOpenSSL do begin
    SSLOptions.SSLVersions := [sslvTLSv1_2];
    SSLOptions.VerifyMode := [sslvrfPeer];
    SSLOptions.Mode := sslmClient;
    SSLOptions.RootCertFile := 'cacert.pem';
    SSLOptions.CertFile := 'cacert.pem';
    SSLOptions.VerifyDepth := MaxInt;
    OnVerifyPeer := SslVerifyPeer;
  end;
end;

function TBingApi.SslVerifyPeer(Certificate: TIdX509; AOk: Boolean; ADepth, AError: Integer): Boolean;
begin
  Result := AOk;
end;

destructor TBingApi.Destroy;
begin
  FList.Free;
  FClient.Free;
end;

end.
