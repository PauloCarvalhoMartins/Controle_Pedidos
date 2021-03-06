unit Service.ItensPedidos;

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
  TItenPedido = class

  private
    F_ConexaoDB:TFDConnection;
    F_codigo:Integer;
    F_numpedido:Integer;
    F_codproduto:Integer;
    F_quantidade:Integer;
    F_vlunitario:Double;
    F_vltotal:Double;
  public
    constructor Create(aConexao:TFDConnection);
    destructor Destroy; override;
    function Inserir:Boolean;
    function Atualizar:Boolean;
    function Apagar:Boolean;
    function Selecionar(id:Integer):Boolean;

  protected
    property ConexaoDB :TFDConnection   read F_ConexaoDB   write F_ConexaoDB;

  published
    property codigo:Integer     read F_codigo write F_codigo;
    property numpedido:Integer  read F_numpedido write F_numpedido;
    property codproduto:Integer read F_codproduto write F_codproduto;
    property quantidade:Integer read F_quantidade write F_quantidade;
    property vlunitario:Double  read F_vlunitario write F_vlunitario;
    property vltotal:Double     read F_vltotal write F_vltotal;

end;

implementation

{TItenPedido}

{$region 'Constructor and Destructor'}
constructor TItenPedido.Create(aConexao:TFDConnection);
begin
  ConexaoDB:=aConexao;
end;

destructor TItenPedido.Destroy;
begin
  inherited;
end;
{$endRegion}

{$region 'CRUD'}
function TItenPedido.Inserir: Boolean;
var Qry:TFDQuery;
begin
  try
    Result:=true;
    Qry:=TFDQuery.Create(nil);
    Qry.Connection:=ConexaoDB;
    Qry.SQL.Clear;
    Qry.SQL.Add(' INSERT INTO itenspedidos ('+
                '      codigo'+
                '      ,numpedido'+
                '      ,codproduto'+
                '      ,quantidade'+
                '      ,vlunitario'+
                '      ,vltotal'+
                ')');
    Qry.SQL.Add(' VALUES ('+
                '      :codigo '+
                '      ,:numpedido '+
                '      ,:codproduto '+
                '      ,:quantidade '+
                '      ,:vlunitario '+
                '      ,:vltotal '+
                ')');
    Qry.ParamByName('codigo').AsInteger := Self.F_codigo;
    Qry.ParamByName('numpedido').AsInteger := Self.F_numpedido;
    Qry.ParamByName('codproduto').AsInteger := Self.F_codproduto;
    Qry.ParamByName('quantidade').AsInteger := Self.F_quantidade;
    Qry.ParamByName('vlunitario').AsFloat := Self.F_vlunitario;
    Qry.ParamByName('vltotal').AsFloat := Self.F_vltotal;
    try
      Qry.ExecSQL;
    except
      Result:=false;
    end;
  finally
   if Assigned(Qry) then
      FreeAndNil(Qry);
  end;
end;

function TItenPedido.Atualizar: Boolean;
var Qry:TFDQuery;
begin
  try
    Result:=true;
    Qry:=TFDQuery.Create(nil);
    Qry.Connection:=ConexaoDB;
    Qry.SQL.Clear;
    Qry.SQL.Add(' UPDATE itenspedidos'+
                '    SET numpedido=:numpedido '+
                '       ,codproduto=:codproduto '+
                '       ,quantidade=:quantidade '+
                '       ,vlunitario=:vlunitario '+
                '       ,vltotal=:vltotal '+
                '      WHERE codigo=:codigo ');
    Qry.ParamByName('codigo').AsInteger := Self.F_codigo;
    Qry.ParamByName('numpedido').AsInteger := Self.F_numpedido;
    Qry.ParamByName('codproduto').AsInteger:= Self.F_codproduto;
    Qry.ParamByName('quantidade').AsInteger := Self.F_quantidade;
    Qry.ParamByName('vlunitario').AsFloat := Self.F_vlunitario;
    Qry.ParamByName('vltotal').AsFloat := Self.F_vltotal;
    try
      Qry.ExecSQL;
    except
      Result:=false;
    end;
  finally
   if Assigned(Qry) then
      FreeAndNil(Qry);
  end;
end;

function TItenPedido.Apagar: Boolean;
var Qry:TFDQuery;
begin
  try
    Result:=true;
    Qry:=TFDQuery.Create(nil);
    Qry.Connection:=ConexaoDB;
    Qry.SQL.Clear;
    Qry.SQL.Add('DELETE FROM itenspedidos'+
                '      WHERE codigo=:codigo ');
    Qry.ParamByName('codigo').AsInteger := Self.F_codigo;
    try
      Qry.ExecSQL;
    except
      Result:=false;
    end;
  finally
   if Assigned(Qry) then
      FreeAndNil(Qry);
  end;
end;

function TItenPedido.Selecionar(id:integer): Boolean;
var Qry:TFDQuery;
begin
  try
    Result:=true;
    Qry:=TFDQuery.Create(nil);
    Qry.Connection:=ConexaoDB;
    Qry.SQL.Clear;
    Qry.SQL.Add(' SELECT '+
                '      codigo '+
                '      ,numpedido '+
                '      ,codproduto '+
                '      ,quantidade '+
                '      ,vlunitario '+
                '      ,vltotal '+
                ' FROM itenspedidos' +
                ' WHERE codigo=:id ');
    Qry.ParamByName('Id').AsInteger:=id;
    Qry.Open;
    Self.F_codigo := Qry.FieldByName('codigo').AsInteger;
    Self.F_numpedido := Qry.FieldByName('numpedido').AsInteger;
    Self.F_codproduto := Qry.FieldByName('codproduto').AsInteger;
    Self.F_quantidade := Qry.FieldByName('quantidade').AsInteger;
    Self.F_vlunitario := Qry.FieldByName('vlunitario').AsFloat;
    Self.F_vltotal := Qry.FieldByName('vltotal').AsFloat;
  finally
   if Assigned(Qry) then
      FreeAndNil(Qry);
  end;
end;
{$endRegion}
end.
