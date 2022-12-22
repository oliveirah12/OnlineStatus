unit frmCard;

interface

uses
  System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects,
  FMX.Layouts,Entities.Online;

type
  TForm2 = class(TForm)
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
  private
    FDadosOnline : TOnlineEmpresa;
  public
    procedure PopulaDados(PDados : TOnlineEmpresa);

  end;

var
  Form2: TForm2;

implementation

uses
  System.SysUtils;

{$R *.fmx}

{ TForm2 }

procedure TForm2.PopulaDados(PDados: TOnlineEmpresa);
var
  item : TListViewItem;
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

  for var pendente in PDados.pendentes do
  begin
    item := lsvPendente.Items.Add;
    item.Detail := pendente.tipoarquivo;
    item.Objects.FindObjectT<TListItemText>('txtQtdLog').Text := pendente.qtd.ToString;
    item.Objects.FindObjectT<TListItemText>('txtLog').Text := pendente.tipoarquivo;
  end;

end;

end.
