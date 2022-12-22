unit Commun.Utils;

interface

uses
  System.Generics.Collections, System.Classes;


  function ConexaoInternet(vUrlAPI : string): Boolean;
  Function StrZero(intvalor,intComprimento: integer):string;
  function GetStrHashMD5(Str: String): String;
  function GetFileHashMD5(FileName: WideString): String;
  function RetornaValorDicionario(vChave: string; vDic : TDictionary<string,Variant>): Variant;
  procedure GeraLog(vLog:string);
  function GetHash(vSiglaEmpresa,vPathArq : string; vEncodeConteudo: Boolean = True): string;
  procedure LimparMemoriaProcesso;
  procedure RegistroWindows(chave, campo, valor: string);
  procedure RetornaValorSessaoIni(const vSessao : string;
    vDictionary : TDictionary<string,string>);
  function RetornaValorIni(const vChave, vCampo, vValorPadrao : string) : string;


implementation

uses
  System.Hash,
  Winapi.WinInet,
  Winapi.Windows,
  System.SysUtils,
  System.StrUtils,
  System.Math,
  System.IniFiles,
  Vcl.Forms,
  System.NetEncoding,
  System.Win.Registry;


function ConexaoInternet(vUrlAPI : string): Boolean;
var estado : Dword;
begin
  try
    //pingar o ip da api pra ver se tem conexao seria melhor...
   // Result := RemoteConnection;
    Result := False;

    if not InternetGetConnectedState(@estado, 0) then
      Result := False
    else
    begin
      if (estado and INTERNET_CONNECTION_LAN <> 0) OR
         (estado and INTERNET_CONNECTION_MODEM <> 0) or
         (Estado and INTERNET_CONNECTION_PROXY <> 0) then
      begin
        Result := InternetCheckConnection(PWideChar(vUrlAPI),  1,  0);
       // Result := True;
      end;
    end;
  except
    Result := False
  end;
end;

Function StrZero(intvalor,intComprimento: integer):string;
var
  StrValor,StrZeros,StrRetorno:string;
  inttamanho,intContador: integer;
begin
  strvalor := InttoStr(intValor);
  inttamanho := length(trim(strvalor));
  strzeros:='';
  for intContador := 1 to intComprimento do
    strzeros := strzeros+'0';
  strRetorno := copy(trim(strzeros)+trim(strvalor),inttamanho+1,intComprimento);
  Result := strRetorno;
end;

function GetStrHashMD5(Str: String): String;
var
  HashMD5: THashMD5;
begin
    HashMD5 := THashMD5.Create;
    HashMD5.GetHashString(Str);
    result := HashMD5.GetHashString(Str);
end;

function GetFileHashMD5(FileName: WideString): String;
var
  HashMD5: THashMD5;
  Stream: TStream;
  Readed: Integer;
  Buffer: PByte;
  BufLen: Integer;
begin
  HashMD5 := THashMD5.Create;
  BufLen := 16 * 1024;
  Buffer := AllocMem(BufLen);
  try
    Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    try
      while Stream.Position < Stream.Size do
      begin
        Readed := Stream.Read(Buffer^, BufLen);
        if Readed > 0 then
        begin
          HashMD5.update(Buffer^, Readed);
        end;
      end;
    finally
      Stream.Free;
    end;
  finally
    FreeMem(Buffer)
  end;
  result := HashMD5.HashAsString;
end;

function RetornaValorDicionario(vChave: string; vDic : TDictionary<string,Variant>): Variant;
var
  vKey : string;
begin
  Result := '';

  if not Assigned(vDic) then
    raise Exception.Create('Dicionário não instanciado');

  if vDic.Count = 0 then
    Exit;

  if not vDic.ContainsKey(vChave) then
    Exit;

  for vKey in vDic.Keys do
  begin
    if vKey.Equals(vChave)  then
    begin
      vDic.TryGetValue(vChave, Result);
      Break;
    end;
  end;
end;

function RetornaValorIni(const vChave, vCampo, vValorPadrao : string): string;
var
  Ini : TIniFile;
  arquivo : string;
begin
  arquivo  := ExtractFileName(ParamStr(0)).Replace('.exe','');
  arquivo  := ExtractFilePath(ParamSTR(0)) + 'Cfg_' + arquivo + '.ini';

  Ini      := TIniFile.Create(arquivo);
  try
    if FileExists(arquivo) then
      Result := Ini.ReadString(vChave, vCampo, vValorPadrao)
    else
      Ini.WriteString(vChave, vCampo, vValorPadrao);

  finally
    FreeAndNil(Ini);
  end;
end;

procedure GeraLog(vLog:string);
var
  F          : TextFile;
  vNomeArq   : String;
  vLocalArq  : String;
  vHora      : String;
  vDataAgora : TDateTime;
begin
  try
    Sleep(RandomRange(30, 200));
    vDataAgora := Now;

    //cria o arquivo na pasta do online
    vNomeArq:='LOG_ONLINE.TXT';
    vLocalArq:=ExtractFilePath(Application.ExeName)+vNomeArq;

    if FileExists(vLocalArq) then
    begin
      if FileDateToDateTime(FileAge(vLocalArq)) <= (vDataAgora-7) then
      begin
        try
          RenameFile(vLocalArq,
                   ExtractFilePath(Application.ExeName) +
                   'LOG_ONLINE_' + formatdatetime('ddmmyyhhnnss', (vDataAgora-7)) +
                   '_ATE_' + formatdatetime('ddmmyyhhnnss', vDataAgora));
        except
        end;
      end;
    end;


    AssignFile(F,vLocalArq);
    try
      if FileExists(vLocalArq) then
      begin
        Reset(F);
        Append(F);
      end
      else
        Rewrite(F);
      //
      vHora := FormatDateTime('dd/mm/yyyy hh:mm:ss',vDataAgora);
      //
      //Writeln(F,vHora+'  -  '+vRotina+'  -  '+vErro);
      Writeln(F,vHora+'  -  '+ vLog);
    finally
      CloseFile(F);
    end;
  except
    on E: Exception do
      Exit;
  end;
end;


function GetHash(vSiglaEmpresa,vPathArq : string; vEncodeConteudo: Boolean): string;
var
  vNomeArq : string;
  vConteudo : string;
  vArq : TStringList;
begin
  Result := '';

  vArq := TStringList.Create;
  try
    vNomeArq := ExtractFileName(vPathArq);
    vArq.LoadFromFile(vPathArq);

    vConteudo := vArq.Text;

    Result := GetStrHashMD5(vSiglaEmpresa) + '*' +
              GetStrHashMD5(vNomeArq) + '*' +
              GetStrHashMD5(
                 IfThen(vEncodeConteudo,
                   TNetEncoding.Base64.Encode(vConteudo),
                   vConteudo
                 )
              );

  finally
    FreeAndNil(vArq);
  end;
end;


procedure LimparMemoriaProcesso;
var
  MainHandle : THandle;
begin
  try
    MainHandle := OpenProcess(PROCESS_ALL_ACCESS, false, GetCurrentProcessID) ;
    SetProcessWorkingSetSize(MainHandle, $FFFFFFFF, $FFFFFFFF) ;
    CloseHandle(MainHandle) ;
  except
  end;

  Application.ProcessMessages;
end;

procedure RegistroWindows(chave, campo, valor: string);
var
  Reg : TRegistry;
Begin
  Reg := TRegistry.Create(KEY_READ or KEY_WRITE);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey(chave, false) then
    begin
      Reg.WriteString(campo, valor);
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;


procedure RetornaValorSessaoIni(const vSessao : string;
  vDictionary : TDictionary<string,string>);
var
  Ini     : TIniFile;
  arquivo : string;
begin
  arquivo := ExtractFileName(ParamStr(0)).Replace('.exe','');
  arquivo := ExtractFilePath(ParamSTR(0)) + 'Cfg_' + arquivo + '.ini';

  if FileExists(arquivo) then
  begin
    Ini := TIniFile.Create(arquivo);
    try
      if Ini.SectionExists(vSessao) then
      begin
        var vKeyList := TStringList.Create;
        try
          Ini.ReadSection(vSessao, vKeyList);

          for var vKey in vKeyList do
            vDictionary.Add(vKey, ini.ReadString(vSessao, vkey,''));

        finally
          vKeyList.Free;
        end;
      end;
    finally
      FreeAndNil(Ini);
    end;
  end;
end;

end.

