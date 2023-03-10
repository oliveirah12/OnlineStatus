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
    Card1: TLayout;
    rec_card1: TRectangle;
    rec_sigla_card1: TRectangle;
    lblDataSincCard1: TLabel;
    lblSiglaCard1: TLabel;
    rec_enviado_card1: TRectangle;
    lblEnviadoCard1: TLabel;
    lblDataEnviadoCard1: TLabel;
    rec_recebido_card1: TRectangle;
    lblRecebidoCard1: TLabel;
    lblDataRecebidoCard1: TLabel;
    rec_mensagem_card1: TRectangle;
    lblAlertaCard1: TLabel;
    lblDataAlertaCard1: TLabel;
    rec_pendente_card1: TRectangle;
    lblPendenteCard1: TLabel;
    lsvPendenteCard1: TListView;
    rec_erro_card1: TRectangle;
    lblErroCard1: TLabel;
    lblDataErroCard1: TLabel;
    Card2: TLayout;
    rec_card2: TRectangle;
    rec_sigla_card2: TRectangle;
    lblDataSincCard2: TLabel;
    lblSiglaCard2: TLabel;
    rec_enviado_card2: TRectangle;
    lblEnviadoCard2: TLabel;
    lblDataEnviadoCard2: TLabel;
    rec_recebido_card2: TRectangle;
    lblRecebidoCard2: TLabel;
    lblDataRecebidoCard2: TLabel;
    rec_mensagem_card2: TRectangle;
    lblAlertaCard2: TLabel;
    lblDataAlertaCard2: TLabel;
    rec_pendente_card2: TRectangle;
    lblPendenteCard2: TLabel;
    lsvPendenteCard2: TListView;
    rec_erro_card2: TRectangle;
    lblErroCard2: TLabel;
    lblDataErroCard2: TLabel;
    Card3: TLayout;
    rec_card_3: TRectangle;
    rec_sigla_card3: TRectangle;
    lblDataSincCard3: TLabel;
    lblSiglaCard3: TLabel;
    rec_enviado_card3: TRectangle;
    lblEnviadoCard3: TLabel;
    lblDataEnviadoCard3: TLabel;
    rec_recebido_card3: TRectangle;
    lblRecebidoCard3: TLabel;
    lblDataRecebidoCard3: TLabel;
    rec_mensagem_card3: TRectangle;
    lblAlertaCard3: TLabel;
    lblDataAlertaCard3: TLabel;
    rec_pendente_card3: TRectangle;
    lblPendenteCard3: TLabel;
    lsvPendenteCard3: TListView;
    rec_erro_card3: TRectangle;
    lblErroCard3: TLabel;
    lblDataErroCard3: TLabel;
    Card4: TLayout;
    rec_card_4: TRectangle;
    rec_sigla_card4: TRectangle;
    lblDataSincCard4: TLabel;
    lblSiglaCard4: TLabel;
    rec_enviado_card4: TRectangle;
    lblEnviadoCard4: TLabel;
    lblDataEnviadoCard4: TLabel;
    rec_recebido_card4: TRectangle;
    lblRecebidoCard4: TLabel;
    lblDataRecebidoCard4: TLabel;
    rec_mensagem_card4: TRectangle;
    lblAlertaCard4: TLabel;
    lblDataAlertaCard4: TLabel;
    rec_pendente_card4: TRectangle;
    lblPendenteCard4: TLabel;
    lsvPendenteCard4: TListView;
    rec_erro_card4: TRectangle;
    lblErroCard4: TLabel;
    lblDataErroCard4: TLabel;
    Card5: TLayout;
    rec_card_5: TRectangle;
    rec_sigla_card5: TRectangle;
    lblDataSincCard5: TLabel;
    lblSiglaCard5: TLabel;
    rec_enviado_card5: TRectangle;
    lblEnviadoCard5: TLabel;
    lblDataEnviadoCard5: TLabel;
    rec_recebido_card5: TRectangle;
    lblRecebidoCard5: TLabel;
    lblDataRecebidoCard5: TLabel;
    rec_mensagem_card5: TRectangle;
    lblAlertaCard5: TLabel;
    lblDataAlertaCard5: TLabel;
    rec_pendente_card5: TRectangle;
    lblPendenteCard5: TLabel;
    lsvPendenteCard5: TListView;
    rec_erro_card5: TRectangle;
    lblErroCard5: TLabel;
    lblDataErroCard5: TLabel;
    procedure btnConsultarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure limparScroll();
  private
    FURL : string;
  public
    procedure PopulaDados(PDados : TOnlineEmpresa; numero : string);
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
  x : integer;
  card : TLayout;
  rectangle : TRectangle;
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

  if HorzScrollBox1.Content.ChildrenCount > 0 then
    limparScroll();









  for x := 0 to vRepOnline.empresas.Count - 1 do
  begin
    PopulaDados(vRepOnline.empresas[x], (x + 1).ToString);

    try

        TLayout(FindComponent('Card' + (x + 1).ToString)).Visible := True;

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

      Card1.visible := false;
      Card2.visible := false;
      Card3.visible := false;
      Card4.visible := false;
      Card5.visible := false;

    finally
      vDic.Free;
    end;





end;


procedure TFrmMain.PopulaDados(PDados: TOnlineEmpresa; numero : string);
var
  item : TListViewItem;
  pendente : TOnlinePendente;
  lista : TListView;
begin
  if not Assigned(PDados) then
    Exit;

  TLabel(FindComponent('lblSiglaCard' + numero)).Text    := PDados.sigla;
  TLabel(FindComponent('lblDataSincCard' + numero)).Text := formatDateTime('dd/mm/yyyy HH:NN:SS', PDados.datasinc);

  TLabel(FindComponent('lblEnviadoCard' + numero)).Text  := 'Enviado : ' + PDados.enviados.qtd.ToString;
  TLabel(FindComponent('lblDataEnviadoCard' + numero)).Text := formatDateTime('dd/mm/yyyy HH:NN:SS', PDados.enviados.data);

  TLabel(FindComponent('lblRecebidoCard' + numero)).Text  := 'Recebido : ' + PDados.recebidos.qtd.ToString;
  TLabel(FindComponent('lblDataRecebidoCard' + numero)).Text := formatDateTime('dd/mm/yyyy HH:NN:SS', PDados.recebidos.data);

  TLabel(FindComponent('lblAlertaCard' + numero)).Text  := 'Alerta : ' + PDados.mensagens.qtd.ToString;
  TLabel(FindComponent('lblDataAlertaCard' + numero)).Text := formatDateTime('dd/mm/yyyy HH:NN:SS', PDados.mensagens.data);

  TLabel(FindComponent('lblErroCard' + numero)).Text := 'Erro : ' + PDados.erros.qtd.ToString;
  TLabel(FindComponent('lblDataErroCard' + numero)).Text := formatDateTime('dd/mm/yyyy HH:NN:SS', PDados.erros.data);

  lista := TListView(FindComponent('lsvPendenteCard' + numero));

  lista.Items.Clear;
  TLabel(FindComponent('lblPendenteCard' + numero)).Text := 'Pendente: ' + PDados.pendentes.Count.ToString;


  for pendente in PDados.pendentes do
  begin
    item := lista.Items.Add;
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
