unit UMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.ListBox, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  FMX.Objects, FMX.Layouts, FMX.Ani;

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
  UfrmCard,
  Entities.Online;


{$R *.fmx}

procedure TFrmMain.btnConsultarClick(Sender: TObject);
var
  vCodigoEmpresa : string;
  x : TOnline;
  t1, t2, t3, t4 : TLayout;
begin
  vCodigoEmpresa := '';

  if cbbEmpresa.Items.Count > 0 then
    if cbbEmpresa.Selected <> nil then
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
    ShowMessage('Erro ao consultar api! Erro: ' + vJsonResp);
    Exit;
  end;

  var vRepOnline := TOnline.FromJSON(vJsonResp);

  t1 := TLayout.Create(HorzScrollBox1);

  t1.Parent := HorzScrollBox1;


  for var vEmpresa in vRepOnline.empresas do
    begin

    end;


  frmCard := TfrmCard.Create(self);

  frmCard.PopulaDados(vRepOnline.empresas[0]);

  HorzScrollBox1.AddObject(frmCard);
  frmCard.Show;

  ShowMessage(vJsonResp);







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
