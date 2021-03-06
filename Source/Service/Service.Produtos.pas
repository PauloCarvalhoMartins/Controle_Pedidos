unit Service.Produtos;


interface

Uses
 System.Classes,
 System.SysUtils,
 Vcl.Controls,
 Vcl.ExtCtrls,
 Vcl.Dialogs,

 Data.DB,

 FireDAC.Stan.Intf,
 FireDAC.Stan.Option,
 FireDAC.Stan.Param,
 FireDAC.Stan.Error,
 FireDAC.DatS,
 FireDAC.Phys.Intf,
 FireDAC.DApt.Intf,
 FireDAC.Stan.Async,
 FireDAC.DApt,
 FireDAC.Comp.DataSet,
 FireDAC.Comp.Client;

type
  TProdutos = class

  private
    F_ConexaoDB:TFDConnection;
    F_codigo:Integer;
    F_descricao:String;
    F_precovenda:Double;

  public
    constructor Create(aConexao:TFDConnection);
    destructor Destroy; override;
    function Selecionar(id:integer):Boolean;

  protected
    property ConexaoDB :TFDConnection   read F_ConexaoDB     write F_ConexaoDB;

  published
    property codigo:Integer     read F_codigo write F_codigo;
    property descricao:String   read F_descricao write F_descricao;
    property precovenda:Double  read F_precovenda write F_precovenda;

end;

implementation

{TProdutos}

{$region 'Constructor and Destructor'}
constructor TProdutos.Create(aConexao:TFDConnection);
begin
  ConexaoDB:=aConexao;
end;

destructor TProdutos.Destroy;
begin
  inherited;
end;
{$endRegion}

{$region 'CRUD'}
function TProdutos.Selecionar(id:integer): Boolean;
var QProduto:TFDQuery;
begin
  try
    Result:=true;
    QProduto:=TFDQuery.Create(nil);
    QProduto.Connection:=ConexaoDB;
    QProduto.SQL.Clear;
    QProduto.SQL.Add(' SELECT '+
                '      codigo '+
                '      ,descricao '+
                '      ,precovenda '+
                ' FROM produtos' +
                ' WHERE codigo=:id ');
    QProduto.ParamByName('Id').AsInteger:=id;
    QProduto.Open;
    Self.F_codigo := QProduto.FieldByName('codigo').AsInteger;
    Self.F_descricao := QProduto.FieldByName('descricao').AsString;
    Self.F_precovenda := QProduto.FieldByName('precovenda').AsFloat;
  finally
   if Assigned(QProduto) then
      FreeAndNil(QProduto);
  end;
end;
{$endRegion}
end.
