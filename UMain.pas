unit UMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.ListBox, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  FMX.Objects, FMX.Layouts, FMX.Ani, Entities.Online;

type
  TFrmMain = class(TForm)
    cbbEmpresa: TComboBox;
    btnConsultar: TButton;
    Layout1: TLayout;
    Line1: TLine;
    HorzScrollBox1: THorzScrollBox;
    layStatusCard: TLayout;
    rec_card: TRectangle;
    rec_sigla: TRectangle;
    lblDataSinc: TLabel;
    lblSigla: TLabel;
    rec_enviado: TRectangle;
    lblEnviado: TLabel;
    lblDataEnviado: TLabel;
    rec_recebido: TRectangle;
    lblRecebido: TLabel;
    lblDataRecebido: TLabel;
    rec_mensagem: TRectangle;
    lblAlerta: TLabel;
    lblDataAlerta: TLabel;
    rec_pendente: TRectangle;
    lblPendente: TLabel;
    lsvPendente: TListView;
    rec_erro: TRectangle;
    lblErro: TLabel;
    lblDataErro: TLabel;
    procedure btnConsultarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure limparScroll();
  private
    FURL : string;
  public
    procedure PopulaDados(PDados : TOnlineEmpresa);
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
  UfrmCard;



{$R *.fmx}
{$R *.Windows.fmx MSWINDOWS}

procedure TFrmMain.btnConsultarClick(Sender: TObject);
var
  vCodigoEmpresa : string;
  vCodeResp  : integer;
  vJsonResp : string;
  vRepOnline : TOnline;
  listaLayout : array[0..5] of TLayout;
  x : integer;
  card : TLayout;
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

  if HorzScrollBox1.Content.ChildrenCount > 1 then
    limparScroll();


  for x := 0 to vRepOnline.empresas.Count - 1  do
  begin
    PopulaDados(vRepOnline.empresas[x]);
    card := TLayout(layStatusCard.Clone(HorzScrollBox1));

    try
      card.Parent := HorzScrollBox1;
      card.Align := TAlignLayout.left;
      card.Margins.Left := 20;
      card.Margins.Bottom := 20;
      card.Visible := true;
      HorzScrollBox1.AddObject(card);
    except
      card.Free;
      raise;
    end;
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


procedure TFrmMain.PopulaDados(PDados: TOnlineEmpresa);
var
  item : TListViewItem;
  pendente : TOnlinePendente;
begin
  if not Assigned(PDados) then
    Exit;

  lblSigla.Text    := PDados.sigla;
  lblDataSinc.Text := formatDateTime('dd/mm/yyyy HH:NN:SS', PDados.datasinc);

  lblEnviado.Text  := 'Enviado : ' + PDados.enviados.qtd.ToString;
  lblDataEnviado.Text := formatDateTime('dd/mm/yyyy HH:NN:SS', PDados.enviados.data);

  lblRecebido.Text  := 'Recebido : ' + PDados.recebidos.qtd.ToString;
  lblDataRecebido.Text := formatDateTime('dd/mm/yyyy HH:NN:SS', PDados.recebidos.data);

  lblAlerta.Text  := 'Alerta : ' + PDados.mensagens.qtd.ToString;
  lblDataAlerta.Text := formatDateTime('dd/mm/yyyy HH:NN:SS', PDados.mensagens.data);

  lblErro.Text  := 'Erro : ' + PDados.erros.qtd.ToString;
  lblDataErro.Text := formatDateTime('dd/mm/yyyy HH:NN:SS', PDados.erros.data);

  lsvPendente.Items.Clear;
  lblPendente.Text := 'Pendente: ' + PDados.pendentes.Count.ToString;



  for pendente in PDados.pendentes do
  begin
    item := lsvPendente.Items.Add;
    item.Detail := pendente.tipoarquivo;
    item.Objects.FindObjectT<TListItemText>('txtQtdLog').Text := pendente.qtd.ToString;
    item.Objects.FindObjectT<TListItemText>('txtLog').Text := pendente.tipoarquivo;
  end;

end;

procedure TFrmMain.limparScroll();
  var
    i : Integer;
  begin
    for i := HorzScrollBox1.Content.ChildrenCount - 1 downto 1 do
    HorzScrollBox1.Content.Children[i].Free;
  end;

end.
