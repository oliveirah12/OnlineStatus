unit UMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.ListBox, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  FMX.Objects, FMX.Layouts;

type
  TFrmMain = class(TForm)
    cbbEmpresa: TComboBox;
    btnConsultar: TButton;
    Layout1: TLayout;
    Line1: TLine;
    HorzScrollBox1: THorzScrollBox;
    Layout2: TLayout;
    procedure btnConsultarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FURL : string;
  public
    { Public declarations }
  end;

  //teste


var
  FrmMain: TFrmMain;

const
  DASHBOARD = '/dashboard';

implementation

uses
  System.Generics.Collections,
  XSuperObject,
  Commun.RestApi,
  Commun.Utils,
  Entities.Online;

{$R *.fmx}

procedure TFrmMain.btnConsultarClick(Sender: TObject);
var
  vCodigoEmpresa : string;
begin
  vCodigoEmpresa := '';

  if cbbEmpresa.Items.Count > 0 then
    if cbbEmpresa.Selected.IsSelected then
      vCodigoEmpresa := cbbEmpresa.Selected.Text.Split(['-'])[0].Trim;

  if vCodigoEmpresa.trim.IsEmpty then
  begin
    ShowMessage('Empresa não selecionada');
    Exit;
  end;


  var vCodeResp := 0;
  var vJsonResp := '';

  TRestAPI.New
    .SetUrl(FURL + DASHBOARD,'')
    .SetParamsHeader('empresa',vCodigoEmpresa)
    .SetParamsHeader('Authorization', 'Basic Y25lc2lzdGVtYXM6Y25lQDEyMDg5NjEzNjY=')
    .Execute(vJsonResp, vCodeResp);

  if vCodeResp <> 200 then
  begin
    ShowMessage('Erro ao consutar api! Erro: ' + vJsonResp);
    Exit;
  end;

  var vRepOnline := TOnline.FromJSON(vJsonResp);



end;

procedure TFrmMain.FormCreate(Sender: TObject);
var
  vDic : TDictionary<string, string>;
begin
  FURL := RetornaValorIni('CONFIG', 'HOST',  '127.0.0.1');

  vDic := TDictionary<string, string>.Create;
  try
    cbbEmpresa.Items.Clear;

    RetornaValorSessaoIni('EMPRESAS', vDic);

    for var vKey in vDic.Keys do
      cbbEmpresa.Items.Add(vKey + ' - ' + vdic.Items[vKey]);

  finally
    vDic.Free;
  end;





end;

end.
