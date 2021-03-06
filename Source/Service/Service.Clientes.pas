unit Service.Clientes;



interface

uses
 System.Classes,
 System.SysUtils,

 Vcl.Controls,
 Vcl.ExtCtrls,
 Vcl.Dialogs,

 FireDAC.Comp.Client,
 FireDAC.Stan.Param;

type
  TCliente = class
  private
    F_ConexaoDB:TFDConnection;
    F_codigo:Integer;
    F_nome:String;
    F_cidade:String;
    F_estado:String;
  public
    constructor Create(aConexao:TFDConnection);
    destructor Destroy; override;
    function Selecionar(id:integer):Boolean;
    function VerificaVazio: Boolean;

 protected
    property ConexaoDB :TFDConnection   read F_ConexaoDB     write F_ConexaoDB;

  published
    property codigo:Integer  read F_codigo write F_codigo;
    property nome:String     read F_nome write F_nome;
    property cidade:String   read F_cidade write F_cidade;
    property estado:String   read F_estado write F_estado;

end;

implementation

{TTCliente}

{$region 'Constructor and Destructor'}
constructor TCliente.Create(aConexao:TFDConnection);
begin
  ConexaoDB:=aConexao;
end;

destructor TCliente.Destroy;
begin
  inherited;
end;
{$endRegion}

{$region 'CRUD'}
function TCliente.Selecionar(id:integer): Boolean;
var QCliente:TFDQuery;
begin
  try
    Result:=true;
    QCliente:=TFDQuery.Create(nil);
    QCliente.Connection:=ConexaoDB;
    QCliente.SQL.Clear;
    QCliente.SQL.Add(' SELECT '+
                '      codigo '+
                '      ,nome '+
                '      ,cidade '+
                '      ,estado '+
                ' FROM clientes' +
                ' WHERE codigo=:id ');
    QCliente.ParamByName('Id').AsInteger:=id;
    QCliente.Open;
    Self.F_codigo := QCliente.FieldByName('codigo').AsInteger;
    Self.F_nome := QCliente.FieldByName('nome').AsString;
    Self.F_cidade := QCliente.FieldByName('cidade').AsString;
    Self.F_estado := QCliente.FieldByName('estado').AsString;
  finally
   if Assigned(QCliente) then
      FreeAndNil(QCliente);
  end;
end;

function TCliente.VerificaVazio: Boolean;
var QCliente:TFDQuery;
begin
  try
    QCliente:=TFDQuery.Create(nil);
    QCliente.Connection:=ConexaoDB;
    QCliente.SQL.Clear;
    QCliente.SQL.Add('SELECT Codigo FROM Clientes WHERE Codigo >= 1');
    Try
      QCliente.Open;
      if QCliente.FieldByName('Codigo').AsString <> EmptyStr then
         result := true
      else
         result := false;

    Except
      Result:=false;
    End;

  finally
    if Assigned(QCliente) then
       FreeAndNil(QCliente);
  end;
end;

{$endRegion}
end.
