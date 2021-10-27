unit Service.Pedidos;

interface

uses
 System.Classes,
 System.SysUtils,

 Vcl.Controls,
 Vcl.ExtCtrls,
 Vcl.Dialogs,

 FireDAC.Comp.Client,
 FireDAC.Stan.Param,

 Controller.Biblioteca;

type
  TPedidos = class

  private
    F_ConexaoDB:TFDConnection;
    F_numpedido:Integer;
    F_dtemissao:TDate;
    F_codcliente:Integer;
    F_vltotal:Double;

  public
    constructor Create(aConexao:TFDConnection);
    destructor Destroy; override;
    function Inserir:Boolean;
    function Atualizar:Boolean;
    function Apagar:Boolean;
    function Selecionar(id:Integer):Boolean;
    function SelecionarCodigo:Integer;

  protected
    property ConexaoDB :TFDConnection   read F_ConexaoDB   write F_ConexaoDB;

  published
    property numpedido:Integer   read F_numpedido write F_numpedido;
    property dtemissao:TDate     read F_dtemissao write F_dtemissao;
    property codcliente:Integer  read F_codcliente write F_codcliente;
    property vltotal:Double      read F_vltotal write F_vltotal;

end;

implementation

{TPedidos}

{$region 'Constructor and Destructor'}
constructor TPedidos.Create(aConexao:TFDConnection);
begin
  ConexaoDB := aConexao;
end;

destructor TPedidos.Destroy;
begin
  inherited;
end;
{$endRegion}

{$region 'CRUD'}
function TPedidos.Inserir: Boolean;
var QPedido:TFDQuery;
begin
  try
    Result:=true;
    QPedido:=TFDQuery.Create(nil);
    QPedido.Connection:=ConexaoDB;
    QPedido.SQL.Clear;
    QPedido.SQL.Add(' INSERT INTO pedidos ('+
                '      numpedido '+
                '      ,dtemissao'+
                '      ,codcliente'+
                '      ,vltotal'+
                ')');
    QPedido.SQL.Add(' VALUES ('+
                '       :numpedido '+
                '      ,:dtemissao '+
                '      ,:codcliente '+
                '      ,:vltotal '+
                ')');
    QPedido.ParamByName('numpedido').AsInteger  := Self.F_numpedido;
    QPedido.ParamByName('dtemissao').AsDateTime := Self.F_dtemissao;
    QPedido.ParamByName('codcliente').AsInteger := Self.F_codcliente;
    QPedido.ParamByName('vltotal').AsFloat := Self.F_vltotal;
    try
      QPedido.ExecSQL;
    except
      Result:=false;
    end;
  finally
   if Assigned(QPedido) then
      FreeAndNil(QPedido);
  end;
end;

function TPedidos.Atualizar: Boolean;
var QPedido:TFDQuery;
begin
  try
    Result:=true;
    QPedido:=TFDQuery.Create(nil);
    QPedido.Connection:=ConexaoDB;
    QPedido.SQL.Clear;
    QPedido.SQL.Add(' UPDATE pedidos'+
                '    SET dtemissao=:dtemissao '+
                '       ,codcliente=:codcliente '+
                '       ,vltotal=:vltotal '+
                '      WHERE numpedido=:numpedido ');
    QPedido.ParamByName('numpedido').AsInteger  := Self.F_numpedido;
    QPedido.ParamByName('dtemissao').AsDateTime := Self.F_dtemissao;
    QPedido.ParamByName('codcliente').AsInteger := Self.F_codcliente;
    QPedido.ParamByName('vltotal').AsFloat := Self.F_vltotal;
    try
      QPedido.ExecSQL;
    except
      Result:=false;
    end;
  finally
   if Assigned(QPedido) then
      FreeAndNil(QPedido);
  end;
end;

function TPedidos.Apagar: Boolean;
var QPedido:TFDQuery;
begin
  try
    Result:=true;
    QPedido:=TFDQuery.Create(nil);
    QPedido.Connection:=ConexaoDB;
    QPedido.SQL.Clear;
    QPedido.SQL.Add('DELETE FROM pedidos'+
                '      WHERE numpedido=:numpedido ');
    QPedido.ParamByName('numpedido').AsInteger := Self.F_numpedido;
    try
      QPedido.ExecSQL;
    except
      Result:=false;
    end;
  finally
   if Assigned(QPedido) then
      FreeAndNil(QPedido);
  end;
end;

function TPedidos.Selecionar(id: Integer): Boolean;
var QPedido:TFDQuery;
begin
  try
    Result:=true;
    QPedido:=TFDQuery.Create(nil);
    QPedido.Connection:=ConexaoDB;
    QPedido.SQL.Clear;
    QPedido.SQL.Add(' SELECT '+
                '      numpedido '+
                '      ,dtemissao '+
                '      ,codcliente '+
                '      ,vltotal '+
                ' FROM pedidos' +
                ' WHERE numpedido=:id ');
    QPedido.ParamByName('Id').AsInteger:=id;
    QPedido.Open;
    Self.F_numpedido  := QPedido.FieldByName('numpedido').AsInteger;
    Self.F_dtemissao  := QPedido.FieldByName('dtemissao').AsDateTime;
    Self.F_codcliente := QPedido.FieldByName('codcliente').AsInteger;
    Self.F_vltotal    := QPedido.FieldByName('vltotal').AsFloat;
  finally
   if Assigned(QPedido) then
      FreeAndNil(QPedido);
  end;

end;

function TPedidos.SelecionarCodigo:Integer;
var QPedido:TFDQuery;
begin
  try
    QPedido:=TFDQuery.Create(nil);
    QPedido.Connection:=ConexaoDB;
    QPedido.SQL.Clear;
    QPedido.SQL.Add(' SELECT '+
                '      numpedido '+
                ' FROM pedidos' +
                ' ORDER BY numpedido DESC LIMIT 1');
    QPedido.Open;
    Result:= QPedido.FieldByName('numpedido').AsInteger;
  finally
   if Assigned(QPedido) then
      FreeAndNil(QPedido);
  end;
end;
{$endRegion}
end.

