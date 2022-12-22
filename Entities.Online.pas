unit Entities.Online;

interface

uses
  System.Generics.Collections;

type

TOnlineStatusBase = class
  private
    Fqtd  : Integer;
    Fdata : TDateTime;
  public
    property qtd  : Integer read Fqtd write Fqtd;
    property data : TDateTime read Fdata write Fdata;
end;

TOnlinePendente = class
  private
    Fqtd         : Integer;
    Ftipoarquivo : string;
  public
    property qtd         : Integer read Fqtd write Fqtd;
    property tipoarquivo : string read Ftipoarquivo write Ftipoarquivo;
end;



TOnlineEmpresa = class
  private
    Fsigla     : string;
    FdataSync  : TDateTime;
    Fenviados  : TOnlineStatusBase;
    Frecebidos : TOnlineStatusBase;
    Ferros     : TOnlineStatusBase;
    Fmensagens : TOnlineStatusBase;
    Fpendentes : TObjectList<TOnlinePendente>;
  public
    constructor Create;
    destructor Destroy; override;

    property sigla     : string read Fsigla write Fsigla;
    property datasinc  : TDateTime read FdataSync write FdataSync;
    property enviados  : TOnlineStatusBase read Fenviados write Fenviados;
    property recebidos : TOnlineStatusBase read Frecebidos write Frecebidos;
    property erros     : TOnlineStatusBase read Ferros write Ferros;
    property mensagens : TOnlineStatusBase read Fmensagens write Fmensagens;
    property pendentes : TObjectList<TOnlinePendente> read Fpendentes write Fpendentes;
end;

TOnline = class
  private
    FcodigoEmpresa : string;
    Fempresas : TObjectList<TOnlineEmpresa>;
  public
    constructor Create;
    destructor Destroy; override;

    property codigoempresa : string read FcodigoEmpresa write FcodigoEmpresa;
    property empresas      : TObjectList<TOnlineEmpresa> read Fempresas write Fempresas;
end;

implementation

uses
  System.SysUtils;

{ TOnlineEmpresa }

constructor TOnlineEmpresa.Create;
begin
  Fenviados  := TOnlineStatusBase.Create;
  Frecebidos := TOnlineStatusBase.Create;
  Ferros     := TOnlineStatusBase.Create;
  Fmensagens := TOnlineStatusBase.Create;
  Fpendentes := TObjectList<TOnlinePendente>.Create;
end;

destructor TOnlineEmpresa.Destroy;
begin
  FreeandNil(Fenviados);
  FreeandNil(Frecebidos);
  FreeandNil(Ferros);
  FreeandNil(Fmensagens);
  FreeandNil(Fpendentes);

  inherited;
end;

{ TOnline }

constructor TOnline.Create;
begin
  Fempresas := TObjectList<TOnlineEmpresa>.Create;
end;

destructor TOnline.Destroy;
begin
  FreeAndNil(Fempresas);

  inherited;
end;

end.
