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
  vCodeResp  : integer;
  vJsonResp : string;
  vRepOnline : TOnline;
  listaLayout : TArray<TLayout>;
  x : integer;
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

  vRepOnline := TOnline.FromJSON(vJsonResp);


  SetLength(listaLayout, vRepOnline.empresas.Count);
  //listaLayout.Create;


    for x := 0 to vRepOnline.empresas.Count-1 do
    begin

      listaLayout[x]                := TLayout.Create(HorzScrollBox1);
      listaLayout[x].Parent         := HorzScrollBox1;
      listaLayout[x].Align          := TAlignLayout.left;
      listaLayout[x].Margins.Left   := 20;
      listaLayout[x].Margins.Bottom := 20;


      frmCard.PopulaDados(vRepOnline.empresas[x]);
      listaLayout[x].AddObject(frmCard.layStatusCard);
      HorzScrollBox1.AddObject(listaLayout[x]);




    end;


end;

procedure TFrmMain.FormCreate(Sender: TObject);
var
  vDic : TDictionary<string, string>;
  vKey : string;
begin
  FURL := RetornaValorIni('CONFIG', 'HOST',  '127.0.0.1');

  vDic := TDictionary<string, string>.Create;
  try
    cbbEmpresa.Items.Clear;

    RetornaValorSessaoIni('EMPRESAS', vDic);



    for vKey in vDic.Keys do
      cbbEmpresa.Items.Add(vKey + ' - ' + vdic.Items[vKey]);

  finally
    vDic.Free;
  end;





end;


end.
