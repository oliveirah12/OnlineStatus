unit Commun.RestApi;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.SysUtils,
  REST.Types,
  REST.Client,
  REST.Utils,
  REST.Response.Adapter,
  REST.Authenticator.Simple,
  REST.Authenticator.Basic,
  REST.Authenticator.OAuth;

type

IRestAPI = interface
  ['{3CBF095E-EF4B-4D73-AF58-685506BCF836}']
  function Execute(out vResponse: string; out vCode : Integer) : IRestAPI; overload;
  function Execute(out vClass: TObject; vProp : string = '') : IRestAPI; overload;
  function SetBody(vBody : string) : IRestAPI;
  function SetEncoded(vEncode : Boolean) : IRestAPI;
  function SetUrl(vUrlBase, vResource : string) : IRestAPI;
  function SetParamsHeader(vKey, vValue: string) : IRestAPI;
  function SetParamsRequest(vKey, vValue: string) : IRestAPI;
  function SetParamsForm(vKey, vValue : string) : IRestAPI;
  function SetParamsQueryString(vKey, vValue: string) : IRestAPI;
end;

type

TRestAPI = class(TInterfacedObject, IRestAPI)
  private
    FRestClient   : TRESTClient;
    FRestRequest  : TRESTRequest;
    FRestResponse : TRESTResponse;

    FBaseUrl  : string;
    FResource : string;
    FBody     : string;
    //FContentType : string;
    FEncoded  : Boolean;
    FParamsRequest : TDictionary<string,string>;
    FParamsHeaders : TDictionary<string,string>;
    FParamsForm    : TDictionary<string,string>;

    FQueryString : TList<TPair<string,string>>;
    function GetMethod(vMethod: string): TRESTRequestMethod;

    procedure ParamsHeader;
    procedure ParamsRequest;
    procedure ParamsQueryString;
    procedure ParamsForm;
    procedure ParamsBody;
  public
    constructor Create;
    destructor Destroy; override;

    class function New: TRestAPI;

    function Execute(out vResponse: string; out vCode : Integer) : IRestAPI; overload;
    function Execute(out vClass: TObject; vProp : string = '' ) : IRestAPI; overload;
    function SetBody(vBody : string) : IRestAPI;
    function SetEncoded(vEncode : Boolean) : IRestAPI;
    function SetUrl(vUrlBase, vResource : string) : IRestAPI;
    function SetParamsHeader(vKey, vValue: string) : IRestAPI;
    function SetParamsRequest(vKey, vValue: string) : IRestAPI;
    function SetParamsForm(vKey, vValue : string) : IRestAPI;
    function SetParamsQueryString(vKey, vValue: string) : IRestAPI;
end;


implementation

uses
  System.StrUtils,
  System.JSON,
  IPPeerClient, XSuperObject, System.Rtti, System.TypInfo;


{ TRestAPI }

constructor TRestAPI.Create;
begin
  FRestClient   := TRESTClient.Create(nil);
  FRestRequest  := TRESTRequest.Create(nil);
  FRestResponse := TRESTResponse.Create(nil);

  FRestRequest.Client   := FRestClient;
  FRestRequest.Response := FRestResponse;

  FRestClient.RaiseExceptionOn500 := False;
  FRestRequest.SynchronizedEvents := False;

  FBody := '';
  FEncoded := False;
  FParamsRequest := TDictionary<string,string>.Create;
  FParamsHeaders := TDictionary<string,string>.Create;
  FQueryString   := TList<TPair<string,string>>.Create;
  FParamsForm    := TDictionary<string,string>.Create;
end;

destructor TRestAPI.Destroy;
begin
  FreeAndNil(FParamsRequest);
  FreeAndNil(FParamsHeaders);
  FreeAndNil(FQueryString);
  FreeAndNil(FParamsForm);

  FreeAndNil(FRestResponse);
  FreeAndNil(FRestRequest);
  FreeAndNil(FRestClient);

  inherited;
end;


function TRestAPI.Execute(out vResponse: string;
  out vCode : Integer): IRestAPI;
begin
  try
    FRestClient.BaseURL       := FBaseUrl;

    if not FResource.IsEmpty then
      FRestRequest.Resource := FResource;

    ParamsRequest;

    FRestRequest.Params.Clear;

    ParamsHeader;

    ParamsQueryString;

    ParamsForm;

    ParamsBody;

    FRestRequest.Execute;

    vResponse := FRestResponse
                  .Content
                    .Replace('.000-04:00','')
                    .Replace('.000-03:00',''); // TEncoding.ASCII.GetBytes(vRestResponse.Content);

    vCode := FRestResponse.StatusCode;
  except
    on ex : Exception do
    begin
      vResponse := ex.Message;
      vCode     := FRestResponse.StatusCode;
    end;
  end;

end;


function TRestAPI.Execute(out vClass: TObject; vProp : string) : IRestAPI;
var
  vResp : string;
  vCode : Integer;
  vObj     : ISuperObject;
  vObjArr  : ISuperArray;
  Contexto  : TRttiContext;
  Instancia : TRttiInstanceType;
  vValue     : TValue;
begin
  Result := Self;

  Self.Execute(vResp, vCode);

  if vCode <> 200 then
    raise Exception.Create('Error ' + vResp);

  vResp := vResp.Replace('.000-04:00','')
                .Replace('.000-03:00','');

  Contexto := TRttiContext.Create;
  try
    Instancia := (Contexto.GetType(TObject) as TRttiInstanceType);

    //vValue     := Instancia.GetMethod('Create').Invoke(Instancia.metaClassType, []);
                 // .Invoke(Instancia.metaClassType, [self]);

    Instancia.metaClassType.FromJSON(vResp);
//    FEntity := vvalue.AsType<T>;

  finally
    Contexto.Free;
  end;

  if vProp <> '' then
  begin
    vObj := SO(vResp);
    vObjArr := vObj.A['objects'];

    if vObjArr.Length = 0 then
      Exit;
  end;


end;

function TRestAPI.GetMethod(vMethod: string): TRESTRequestMethod;
begin
  case AnsiIndexStr(vMethod.ToUpper, ['GET','POST','PUT','DELETE','PATH']) of
    0 : Result := rmGET;
    1 : Result := rmPOST;
    2 : Result := rmPUT;
    3 : Result := rmDELETE;
    4 : Result := rmPATCH
  else
    Result := rmGET;
  end;
end;

class function TRestAPI.New: TRestAPI;
begin
  Result := Self.Create;

end;

procedure TRestAPI.ParamsBody;
var
  vCont : Integer;
//  vContentType : TRESTContentType;
begin
  if (not FBody.Trim.IsEmpty) then
  begin
    vCont := FRestRequest.Params.Count;
    FRestRequest.Body.ClearBody;

//    vContentType := TRESTContentType(
//        GetEnumValue(
//          TypeInfo(TRESTContentType),
//          FRestClient.ContentType
//        )
//      );     vCont := FRestRequest.Params.Count;

    FRestRequest.Params.AddItem;
    FRestRequest.Params[vCont].ContentType := ctAPPLICATION_JSON;
    FRestRequest.Params[vCont].Kind        := pkREQUESTBODY;
    FRestRequest.Params[vCont].name        := 'body';
    FRestRequest.Params[vCont].Value       := FBody;

    if not FEncoded then
      FRestRequest.Params[vCont].Options   := [poDoNotEncode];
  end;
end;

procedure TRestAPI.ParamsForm;
var
 // vContentType : TRESTContentType;
  vCont : Integer;
  vKey  : string;
  vValue: string;
begin
  vCont := FRestRequest.Params.Count;

  for vKey in FParamsForm.Keys do
  begin
    vValue := FParamsForm.Items[vKey];

//    vContentType := TRESTContentType(
//      GetEnumValue(
//        TypeInfo(TRESTContentType),
//        FRestClient.ContentType
//      )
//    );

    FRestRequest.Params.AddItem;
    //FRestRequest.Params[vCont].ContentType := vContentType;
    FRestRequest.Params[vCont].Kind        := pkGETorPOST;
    FRestRequest.Params[vCont].name        := vkey;
    FRestRequest.Params[vCont].value       := vValue;

    if not FEncoded then
      FRestRequest.Params[vCont].Options := [poDoNotEncode];

    Inc(vCont);
  end;


//  FRestRequest.Params.AddItem.name  := 'consumer_key'; // param name
//  FRestRequest.Params.AddItem.Value := '8ab99b171294787578371c2c9204e669e35086b053d0361d1b10d63dc219ffd1';
//  FRestRequest.Params.AddItem.Kind  := pkGETorPOST;
//  FRestRequest.Params.AddItem.ContentType := ctNone;
//  FRestRequest.Params.AddItem.Options := [poDoNotEncode];
//
//  FRestRequest.Params.AddItem.name  := 'consumer_secret'; // param name
//  FRestRequest.Params.AddItem.Value := '111e3f7af264ec103d26f9a865fcb5b980ae74dedc748fa9a3c9ee696727d1d7';
//  FRestRequest.Params.AddItem.Kind  := pkGETorPOST;
//  FRestRequest.Params.AddItem.ContentType := ctNone;
//  FRestRequest.Params.AddItem.Options := [poDoNotEncode];
//
//  FRestRequest.Params.AddItem.name  := 'code'; // param name
//  FRestRequest.Params.AddItem.Value := '4cda47055e02fa7f082ac3eea36558ff0d9ec938d4cf005c058a8bae0f1a6eed';
//  FRestRequest.Params.AddItem.Kind  := pkGETorPOST;
//  FRestRequest.Params.AddItem.ContentType := ctNone;
//  FRestRequest.Params.AddItem.Options := [poDoNotEncode];
end;

procedure TRestAPI.ParamsHeader;
var
//  vContentType : TRESTContentType;
  vCont : Integer;
  vKey  : string;
  vValue: string;
begin
  vCont := FRestRequest.Params.Count;
  for vKey in FParamsHeaders.Keys do
  begin
    vValue := FParamsHeaders.Items[vKey];

//    vContentType := TRESTContentType(
//      GetEnumValue(
//        TypeInfo(TRESTContentType),
//        FRestClient.ContentType
//      )
//    );

    FRestRequest.Params.AddItem;
    //FRestRequest.Params[vCont].ContentType := vContentType;
    FRestRequest.Params[vCont].Kind        := pkHTTPHEADER;
    FRestRequest.Params[vCont].name        := vkey;
    FRestRequest.Params[vCont].value       := vValue;

    if not FEncoded then
      FRestRequest.Params[vCont].Options := [poDoNotEncode];

    Inc(vCont);
  end;
end;

procedure TRestAPI.ParamsQueryString;
var
  vCont : Integer;
  vKey  : string;
  vValue: string;
begin
  for vCont := 0 to Pred(FQueryString.Count) do
  begin
    vkey   := FQueryString[vCont].Key;
    vValue := FQueryString[vCont].Value;

    FRestRequest.Params.AddItem;
    FRestRequest.Params[vCont].name  := vkey;
    FRestRequest.Params[vCont].value := vValue;

  end;
end;

procedure TRestAPI.ParamsRequest;
var
  vKey : string;
begin
  FRestClient.Params.Clear;

  FRestClient.Accept        := 'application/json, text/plain; q=0.9, text/html;q=0.8,';
  FRestClient.ContentType   := 'application/json';//; charset=utf-8';
  FRestClient.AcceptCharSet := 'utf-8, *;q=0.8';
  FRestClient.UserAgent     := 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.96 Safari/537.36';


  for vkey in FParamsRequest.Keys do
  begin
    if vkey.ToUpper.Contains('METHOD') then
      FRestRequest.Method := GetMethod(FParamsRequest.Items[vkey]);

    if vkey.ToUpper.Contains('ACCEPT') then
      FRestRequest.Accept := FParamsRequest.Items[vkey];

    if vkey.ToUpper.Contains('CONTENTTYPE') then
      FRestClient.ContentType := FParamsRequest.Items[vkey];

    if vkey.ToUpper.Contains('ACCEPTCHARSET') then
      FRestClient.AcceptCharset := FParamsRequest.Items[vkey];
  end;
end;

function TRestAPI.SetBody(vBody: string): IRestAPI;
begin
  Result := Self;

  FBody := vBody;
end;


function TRestAPI.SetEncoded(vEncode: Boolean): IRestAPI;
begin
  Result := Self;
  FEncoded := vEncode;
end;

function TRestAPI.SetParamsForm(vKey, vValue: string): IRestAPI;
var
  vK : string;
  vExist : Boolean;
begin
  Result := Self;

  if FParamsForm.Count > 0 then
  begin
    vExist := False;

    for vK in FParamsForm.Keys do
      vExist := vK = vKey;

    if not vExist then
      FParamsForm.Add(vKey, vValue);
  end
  else
    FParamsForm.Add(vKey, vValue);
end;

function TRestAPI.SetParamsHeader(vKey, vValue: string): IRestAPI;
var
  vK : string;
  vExist : Boolean;
begin
  Result := Self;

  if FParamsHeaders.Count > 0 then
  begin
    vExist := False;

    for vK in FParamsHeaders.Keys do
      vExist := vK = vKey;

    if not vExist then
      FParamsHeaders.Add(vKey, vValue);
  end
  else
    FParamsHeaders.Add(vKey, vValue);
end;

function TRestAPI.SetParamsQueryString(vKey, vValue: string): IRestAPI;
begin
  Result := Self;

  FQueryString.Add(TPair<string,string>.Create(vKey, vValue));
end;

function TRestAPI.SetParamsRequest(vKey, vValue: string): IRestAPI;
var
  vK : string;
  vExist : Boolean;
begin
  Result := Self;

  if FParamsRequest.Count > 0 then
  begin
    vExist := False;

    for vK in FParamsRequest.Keys do
      vExist := vK = vKey;

    if not vExist then
      FParamsRequest.Add(vKey, vValue);
  end
  else
    FParamsRequest.Add(vKey, vValue);

end;

function TRestAPI.SetUrl(vUrlBase, vResource: string): IRestAPI;
begin
  Result := self;
  FBaseUrl  := vUrlBase;
  FResource := vResource;
end;

end.

