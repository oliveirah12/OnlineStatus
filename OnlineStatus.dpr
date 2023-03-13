program OnlineStatus;

uses
  System.StartUpCopy,
  FMX.Forms,
  UMain in 'UMain.pas' {FrmMain},
  UfrmCard in 'UfrmCard.pas' {frmCard},
  Commun.RestApi in 'commun\Commun.RestApi.pas',
  Commun.Utils in 'commun\Commun.Utils.pas',
  XSuperJSON in 'lib\XSuperObject\XSuperJSON.pas',
  XSuperObject in 'lib\XSuperObject\XSuperObject.pas',
  Entities.Online in 'Entities.Online.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.CreateForm(TfrmCard, frmCard);
  Application.Run;
end.
