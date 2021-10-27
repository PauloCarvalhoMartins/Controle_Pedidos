unit uFrmConsulta;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  Buttons,
  Mask,
  DBCtrls,
  ExtCtrls,
  Vcl.Grids,
  Vcl.DBGrids,

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
  FireDAC.Comp.Client,

  Controller.Biblioteca,

  uDMPedidos;

type
  TFrmConsulta = class(TForm)
    PnlPrincipal: TPanel;
    PnlBotoes: TPanel;
    PnlCancelar: TPanel;
    BntCancelar: TSpeedButton;
    PnlConfirma: TPanel;
    BntConfirma: TSpeedButton;
    PnlPesquisa: TPanel;
    IgView: TImage;
    GroupBoxpesq: TGroupBox;
    GrdListagem: TDBGrid;
    DsListagem: TDataSource;
    EdtPesquisar: TEdit;
    QryListagem: TFDQuery;
    procedure BntConfirmaClick(Sender: TObject);
    procedure BntCancelarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GrdListagemDblClick(Sender: TObject);
    procedure GrdListagemDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure GrdListagemKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure GrdListagemTitleClick(Column: TColumn);
    procedure EdtPesquisarChange(Sender: TObject);
  private
    { Private declarations }
    SelectOriginal:string;
    IndiceAtual:string;
    procedure BloqueiaCTRL_DEL_DBGrid(var Key: Word; Shift: TShiftState);
    procedure ExibirLabelIndice(aCampo: string; aLabel: TGroupBox);
    procedure LimparEdits;
    procedure ConfigurarCampos;
    procedure NomeiaTituloGrid;
    function  RetornarCampoTraduzido(Campo: string): string;
  public
    { Public declarations }
    TituloFrm:String;
    SqlText  :String;
    Titulo1  :String;
    Titulo2  :String;
    Campo1   :String;
    Campo2   :String;
    Tamanho1 :integer;
    Tamanho2 :Integer;
    Resultado:String;
    bCancelou: Boolean;
  end;

var
  FrmConsulta: TFrmConsulta;

implementation

{$R *.dfm}


{ TFrmDialogo }

procedure TFrmConsulta.BloqueiaCTRL_DEL_DBGrid(var Key: Word;
  Shift: TShiftState);
begin
  if (Shift = [ssCtrl]) and (Key = 46) then
      Key := 0;
end;

procedure TFrmConsulta.ExibirLabelIndice(aCampo: string; aLabel: TGroupBox);
begin
 aLabel.Caption:='Pesquisar por ' + RetornarCampoTraduzido(aCampo)+':';
end;

procedure TFrmConsulta.LimparEdits;
Var i:Integer;
begin
  for i := 0 to ComponentCount -1 do begin
    if (Components[i] is TLabeledEdit) then
      TLabeledEdit(Components[i]).Text:=EmptyStr
    else if (Components[i] is TEdit) then
      TEdit(Components[i]).Text:=''
    else if (Components[i] is TDBLookupComboBox) then
      TDBLookupComboBox(Components[i]).KeyValue:=Null
    else if (Components[i] is TMemo) then
      TMemo(Components[i]).Text:=''
    else if (Components[i] is TMaskEdit) then
      TMaskEdit(Components[i]).Text:=''
    else if (Components[i] is TImage) then begin
      if TImage(Components[i]).Tag=1 then begin
         TImage(Components[i]).Picture.Assign(nil);
      end;
    end;
  end;
end;

procedure TFrmConsulta.NomeiaTituloGrid;
begin
 qryListagem.Fields[0].DisplayLabel:=Titulo1;
 qryListagem.Fields[1].DisplayLabel:=Titulo2;
end;

procedure TFrmConsulta.ConfigurarCampos;
begin
  grdListagem.Columns.Add();
  grdListagem.Columns[0].FieldName:=Campo1;
  grdListagem.Columns[0].Width:= Tamanho1;

  grdListagem.Columns.Add();
  grdListagem.Columns[1].FieldName:=Campo2;
  grdListagem.Columns[1].Width:= Tamanho2;
end;

function TFrmConsulta.RetornarCampoTraduzido(Campo: string): string;
var i:Integer;
begin
  for I := 0 to QryListagem.FieldCount-1 do begin
    if LowerCase(QryListagem.Fields[i].FieldName) = LowerCase(Campo) then begin
       Result:=QryListagem.Fields[i].DisplayLabel;
       Break;
    end;
  end;
end;

procedure TFrmConsulta.FormCreate(Sender: TObject);
begin
 QryListagem.Connection:=DMPedidos.FDConexao;

 grdListagem.Options:=[dgTitles,
                       dgIndicator,
                       dgColumnResize,
                       dgColLines,
                       dgRowLines,
                       dgTabs,
                       dgRowSelect,
                       dgAlwaysShowSelection,
                       dgCancelOnExit,
                       dgTitleClick];
end;

procedure TFrmConsulta.FormShow(Sender: TObject);
begin
 FrmConsulta.Caption:=TituloFrm;
 QryListagem.SQL.Text:= SqlText;
 IndiceAtual:=Campo1;

  if QryListagem.SQL.Text<>EmptyStr then
    begin
      SelectOriginal:=QryListagem.SQL.Text;
      QryListagem.Open;
      NomeiaTituloGrid;
      ConfigurarCampos;
      QryListagem.IndexFieldNames:=IndiceAtual;
      ExibirLabelIndice(IndiceAtual, GroupBoxPesq);
    end;
end;

procedure TFrmConsulta.BntCancelarClick(Sender: TObject);
begin
  LimparEdits;
  bCancelou:=False;
  Close;
end;

procedure TFrmConsulta.BntConfirmaClick(Sender: TObject);
begin
  Resultado:=QryListagem.Fields[2].AsString;
  LimparEdits;
  bCancelou:=True;
  Close;
end;


procedure TFrmConsulta.GrdListagemDblClick(Sender: TObject);
begin
BntConfirma.Click;
end;

procedure TFrmConsulta.GrdListagemDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
if not odd(DsListagem.DataSet.RecNo) then
  if not (gdSelected in State) then
    begin
     grdListagem.Canvas.Brush.Color:=$00FFEFDF;
     grdListagem.Canvas.FillRect(Rect);
     grdListagem.DefaultDrawDataCell(rect,Column.Field,State);
    end;
end;

procedure TFrmConsulta.GrdListagemKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
BloqueiaCTRL_DEL_DBGrid(Key, Shift);
end;

procedure TFrmConsulta.GrdListagemTitleClick(Column: TColumn);
begin
 IndiceAtual                :=Column.FieldName;
 QryListagem.IndexFieldNames:=IndiceAtual;
 ExibirLabelIndice(IndiceAtual, GroupBoxPesq);
end;

procedure TFrmConsulta.EdtPesquisarChange(Sender: TObject);
begin
 QryListagem.Locate(IndiceAtual, TMaskEdit(Sender).Text,[loPartialKey])
end;
end.
