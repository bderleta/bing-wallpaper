program BingWallpaper;

uses
  Vcl.Forms,
  bwMainForm in 'bwMainForm.pas' {MainForm},
  bwBingApi in 'bwBingApi.pas',
  bwShObjIdl in 'bwShObjIdl.pas',
  bwDesktopWallpaper in 'bwDesktopWallpaper.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
