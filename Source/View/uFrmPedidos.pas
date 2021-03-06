unit uFrmPedidos;

interface

uses
  Winapi.Windows,
  Winapi.Messages,

  System.SysUtils,
  System.Variants,
  System.Classes,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.Grids,
  Vcl.DBGrids,
  Vcl.Buttons,
  Vcl.ExtCtrls,

  Data.DB,
  Datasnap.DBClient,

  FireDAC.Comp.Client,
  FireDAC.Stan.Param,

  Service.Produtos,
  Service.Clientes,
  Service.Pedidos,
  Service.ItensPedidos,

  Controller.Biblioteca,

  uFrmConsulta,
  uDMPedidos;

type
  TFrmPedidos = class(TForm)
    PnlPrincipal: TPanel;
    GbxPrincipal: TGroupBox;
    PnlBotoes: TPanel;
    PnlCancelar: TPanel;
    BntCancelar: TSpeedButton;
    PnlConfirma: TPanel;
    BntConfirma: TSpeedButton;
    PnlGrid: TPanel;
    GrdProdutos: TDBGrid;
    PnlLocalizar: TPanel;
    LblVlUnitario: TLabel;
    LblMult: TLabel;
    LblIgual: TLabel;
    LblTotal: TLabel;
    PnlValores: TPanel;
    PnlVaLiTotal: TPanel;
    LblValiToral: TLabel;
    LblValorTotal: TLabel;
    BufTemp: TClientDataSet;
    DtsBufTemp: TDataSource;
    EdtCodigo: TEdit;
    LblCodigo: TLabel;
    LblDescricao: TLabel;
    EdtDescricao: TEdit;
    LblQuant: TLabel;
    EdtQuant: TEdit;
    EdtValorUnitario: TEdit;
    EdtValorTotal: TEdit;
    BtnIncluir: TButton;
    GbxDadosClientes: TGroupBox;
    LblCodigoCliente: TLabel;
    EdtCodCliente: TEdit;
    EdtDescricaoCliente: TEdit;
    LblDescricaoCliente: TLabel;
    BntPesquisarCliente: TButton;
    PnlAlterar: TPanel;
    BntAlterar: TSpeedButton;
    PnlExcluir: TPanel;
    BntExcluir: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EdtCodigoExit(Sender: TObject);
    procedure EdtQuantExit(Sender: TObject);
    procedure BtnIncluirClick(Sender: TObject);
    procedure BntPesquisarClienteClick(Sender: TObject);
    procedure BntAlterarClick(Sender: TObject);
    procedure BntExcluirClick(Sender: TObject);
    procedure BntConfirmaClick(Sender: TObject);
    procedure BntCancelarClick(Sender: TObject);
    procedure GrdProdutosDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure GrdProdutosKeyPress(Sender: TObject; var Key: Char);
    procedure GrdProdutosKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    vEstadodoCadastro:string;
    vCodigoProduto:Integer;
    vCodigoPedido:Integer;
    function  Sequenciar:Integer;
    procedure SelecionarProduto(Codigo:Integer);
    procedure LimparCampos(todos:boolean=false);
    procedure LimparBufDataSet;
    procedure ConfigurarCampos;
    procedure NomeiaTituloGrid;
    procedure GravarProdutoBufTemp;
    procedure AtualizaTotal;
    procedure PopulaBufTemp;
    procedure ApagaItensPedido;
  public

  end;

var
  FrmPedidos: TFrmPedidos;

implementation

{$R *.dfm}

{$region 'Se??o Privade'}
function TFrmPedidos.Sequenciar: Integer;
begin
   if bufTemp.IsEmpty then begin
     Result:=1
   end
   else
    begin
     bufTemp.Last;
     result:=bufTemp.FieldByName('Item').AsInteger+1;
   end;
end;

procedure TFrmPedidos.SelecionarProduto(Codigo: Integer);
var oProduto: TProdutos;
begin
  try
    oProduto:= TProdutos.Create(DMPedidos.FDConexao);

      if oProduto.Selecionar(Codigo)= False then
        begin
         MessageDlgCheck('O produto n?o Existe', mtWarning, [mbOk], 0, mrOk, True);
         EdtCodigo.SetFocus;
         LimparCampos;
        abort;
        end;
   vCodigoProduto := oProduto.codigo;
   EdtDescricao.Text:=oProduto.descricao;
   EdtValorUnitario.Text:=FormatFloat('R$ ###,##0.00',oProduto.precovenda);
   EdtQuant.Text:='1';
   EdtValorTotal.Text := (FormatFloat('R$ ###,##0.00',oProduto.precovenda * StrToFloat(EdtQuant.Text)));
  finally
    if Assigned(oProduto) then
      FreeAndNil(oProduto);
  end;

end;

procedure TFrmPedidos.LimparCampos(todos: boolean);
begin
 EdtCodigo.Text:= EmptyStr;
 EdtDescricao.Text:=EmptyStr;
 EdtQuant.Text:='1';
 EdtValorUnitario.Text:='0';
 EdtValorTotal.Text:='0';

 if todos then
   begin
    LblValorTotal.Caption:='0.00';
    EdtCodCliente.Text:=EmptyStr;
    EdtDescricaoCliente.Text:=EmptyStr;
   end;
end;

procedure TFrmPedidos.LimparBufDataSet;
begin
  bufTemp.First;
  while not bufTemp.Eof do
    bufTemp.Delete;
end;

procedure TFrmPedidos.ConfigurarCampos;
begin
  GrdProdutos.Columns.Add();
  GrdProdutos.Columns[0].FieldName:='Item';
  GrdProdutos.Columns[0].Width:=50;

  GrdProdutos.Columns.Add();
  GrdProdutos.Columns[1].FieldName:='codigo';
  GrdProdutos.Columns[1].Width:=100;

  GrdProdutos.Columns.Add();
  GrdProdutos.Columns[2].FieldName:='Descricao';
  GrdProdutos.Columns[2].Width:=250;

  GrdProdutos.Columns.Add();
  GrdProdutos.Columns[3].FieldName:='Quantidade';
  GrdProdutos.Columns[3].Width:=80;

  GrdProdutos.Columns.Add();
  GrdProdutos.Columns[4].FieldName:='valorUnitario';
  GrdProdutos.Columns[4].Width:=100;

  GrdProdutos.Columns.Add();
  GrdProdutos.Columns[5].FieldName:='valorTotal';
  GrdProdutos.Columns[5].Width:=100;

  GrdProdutos.Columns.Add();
  GrdProdutos.Columns[6].FieldName:='itemcodigo';
  GrdProdutos.Columns[6].Visible:=False;
end;

procedure TFrmPedidos.NomeiaTituloGrid;
begin
  bufTemp.Fields[0].DisplayLabel:='N? Iten';
  bufTemp.Fields[1].DisplayLabel:='Codigo';
  bufTemp.Fields[1].Alignment   := taRightJustify;
  bufTemp.Fields[2].DisplayLabel:='Descri??o';
  bufTemp.Fields[3].DisplayLabel:='Quantidade';
  bufTemp.Fields[4].DisplayLabel:='vl Unitario';
  TNumericField(bufTemp.Fields[4]).DisplayFormat := 'R$ ###,##0.00';
  bufTemp.Fields[5].DisplayLabel:='vl Total';
  TNumericField(bufTemp.Fields[5]).DisplayFormat := 'R$ ###,##0.00';
end;

procedure TFrmPedidos.GravarProdutoBufTemp;
var iProximo:Integer;
    dValorTotal:Double;
begin
   if (StrToFloat(TiraEspeciais(EdtValorUnitario.Text))<=0) or (StrToFloat(EdtQuant.Text)<=0)
      or (EdtCodigo.Text=EmptyStr) then
       begin
         EdtCodigo.SetFocus;
         Exit;
       end;

   if strtoint(EdtQuant.Text)=0 then
     EdtQuant.Text:='1';

   iProximo:=Sequenciar;
   if vEstadodoCadastro <> 'Alterar'  then
    begin
     bufTemp.Append;
     bufTemp.FieldByName('Item').AsInteger:=iProximo;
     bufTemp.FieldByName('codigo').AsInteger:=StrToInt(EdtCodigo.Text);
     bufTemp.FieldByName('descricao').AsString:=EdtDescricao.Text;
     bufTemp.FieldByName('quantidade').AsFloat:=StrToFloat(EdtQuant.Text);
     bufTemp.FieldByName('valorUnitario').AsFloat:=StrToFloat(TiraEspeciais(EdtValorUnitario.Text));
     bufTemp.FieldByName('valorTotal').AsFloat:= bufTemp.FieldByName('quantidade').AsFloat * bufTemp.FieldByName('valorUnitario').AsFloat;
     bufTemp.Post;
    end
    else
    begin
     bufTemp.Edit;
     bufTemp.FieldByName('Item').AsInteger:=iProximo;
     bufTemp.FieldByName('codigo').AsInteger:=StrToInt(EdtCodigo.Text);
     bufTemp.FieldByName('descricao').AsString:=EdtDescricao.Text;
     bufTemp.FieldByName('quantidade').AsFloat:=StrToFloat(EdtQuant.Text);
     bufTemp.FieldByName('valorUnitario').AsFloat:=StrToFloat(TiraEspeciais(EdtValorUnitario.Text));
     bufTemp.FieldByName('valorTotal').AsFloat:= bufTemp.FieldByName('quantidade').AsFloat * bufTemp.FieldByName('valorUnitario').AsFloat;
     bufTemp.Post;
    end;

   LimparCampos;
   GrdProdutos.Refresh;

   try
     bufTemp.DisableControls;
     bufTemp.First;
     dValorTotal:=0;
     while not bufTemp.EOF do begin
       dValorTotal:=dValorTotal+bufTemp.FieldByName('valorTotal').AsFloat;
       bufTemp.Next;
     end;
   finally
     bufTemp.Last;
     bufTemp.EnableControls;
     LblValorTotal.Caption:=FormatFloat('R$ ###,##0.00',dValorTotal);
   end;
end;

procedure TFrmPedidos.AtualizaTotal;
 var
  dValorTotal:Double;
begin
   try
     bufTemp.DisableControls;
     bufTemp.First;
     dValorTotal:=0;
     while not bufTemp.EOF do begin
       dValorTotal:=dValorTotal+bufTemp.FieldByName('valorTotal').AsFloat;
       bufTemp.Next;
     end;
   finally
     bufTemp.Last;
     bufTemp.EnableControls;
     LblValorTotal.Caption:=FormatFloat('R$ #0.00',dValorTotal);
   end;
end;

procedure TFrmPedidos.PopulaBufTemp;
var
  Qry: TFDQuery;
  iProximo: Integer;
  oProduto: TProdutos;
begin
  try
    Qry := TFDQuery.Create(nil);
    Qry.Connection := DMPedidos.FDConexao;
    Qry.SQL.Clear;
    Qry.SQL.Add('SELECT * FROM ItensPedidos ' +
                'WHERE NumPedido=:id order by codigo');
    Qry.ParamByName('Id').AsInteger := vCodigoPedido;
    Qry.Open;
    Qry.First;
    while not Qry.Eof do
    begin
      iProximo:=Sequenciar;
      BufTemp.Append;
      BufTemp.FieldByName('item').AsInteger := iProximo;
      BufTemp.FieldByName('Codigo').Asinteger:=
                      Qry.FieldByName('codproduto').AsInteger;
      BufTemp.FieldByName('Quantidade').AsFloat :=
                      Qry.FieldByName('Quantidade').AsInteger;
      BufTemp.FieldByName('valorUnitario').AsFloat :=
                      Qry.FieldByName('VlUnitario').AsInteger;
      BufTemp.FieldByName('valorTotal').AsFloat :=
                      Qry.FieldByName('VlTotal').AsInteger;
      BufTemp.FieldByName('itemcodigo').AsFloat :=
                      Qry.FieldByName('Codigo').AsInteger;
        try
          begin
            oProduto := TProdutos.Create(DMPedidos.FDConexao);
            if oProduto.Selecionar(Qry.FieldByName('codproduto').AsInteger) then
               BufTemp.FieldByName('Descricao').AsString := oProduto.descricao;
          end;
        finally
          if Assigned(oProduto) then
            FreeAndNil(oProduto);
        end;
      BufTemp.Post;
      Qry.next
    end;
  finally
    if Assigned(Qry) then
      FreeAndNil(Qry);
  end;
end;

procedure TFrmPedidos.ApagaItensPedido;
var
  Qry: TFDQuery;
  oItenPedido:TItenPedido;
begin
  try
    Qry := TFDQuery.Create(nil);
    Qry.Connection := DMPedidos.FDConexao;
    Qry.SQL.Clear;
    Qry.SQL.Add('Select * FROM itenspedidos '+
                'WHERE NumPedido=:Id');
    Qry.ParamByName('Id').AsInteger := vCodigoPedido;
    Qry.Open;
    Qry.First;
    while not Qry.Eof do
    begin
     oItenPedido := TItenPedido.Create(DMPedidos.FDConexao);
     if oItenPedido.Selecionar(Qry.FieldByName('codigo').AsInteger) then
        oItenPedido.Apagar;
     Qry.next
    end;

  finally
    if Assigned(oItenPedido) then
      FreeAndNil(oItenPedido);
    if Assigned(Qry) then
      FreeAndNil(Qry);
  end;
end;
{$endRegion}

procedure TFrmPedidos.FormCreate(Sender: TObject);
begin
DMPedidos:=TDMPedidos.Create(self);

GrdProdutos.Options:=[dgTitles,
                      dgIndicator,
                      dgColumnResize,
                      dgColLines,
                      dgRowLines,
                      dgTabs,
                      dgRowSelect,
                      dgAlwaysShowSelection,
                      dgCancelOnExit,
                      dgTitleClick];

bufTemp.FieldDefs.Add('item',ftInteger,0);
bufTemp.FieldDefs.Add('codigo',ftInteger,0);
bufTemp.FieldDefs.Add('descricao',ftString,50);
bufTemp.FieldDefs.Add('quantidade',ftFloat,0);
bufTemp.FieldDefs.Add('valorUnitario',ftFloat,0);
bufTemp.FieldDefs.Add('valorTotal',ftFloat);
bufTemp.FieldDefs.Add('itemcodigo',ftInteger,0);

bufTemp.CreateDataset;
dtsbufTemp.DataSet:=bufTemp;
grdProdutos.DataSource:=dtsbufTemp;
end;

procedure TFrmPedidos.FormShow(Sender: TObject);
begin
with DMPedidos.FDConexao do
     Connected:=True;

 NomeiaTituloGrid;
 ConfigurarCampos;
 EdtCodigo.SetFocus;
end;

procedure TFrmPedidos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 if Assigned(DMPedidos) then
       FreeAndNil(DMPedidos);
end;

procedure TFrmPedidos.EdtCodigoExit(Sender: TObject);
begin
  if EdtCodigo.Text <> EmptyStr  then
   SelecionarProduto(StrToInt(EdtCodigo.Text));
end;

procedure TFrmPedidos.EdtQuantExit(Sender: TObject);
begin
  if EdtCodigo.Text <> EmptyStr  then
     //EdtValorTotal.Text:= (FormatFloat('R$ #0.00',StrToFloat(EdtValorUnitario.Text) * StrToFloat(EdtQuant.Text)));
end;

procedure TFrmPedidos.BtnIncluirClick(Sender: TObject);
begin
  GravarProdutoBufTemp;
  LimparCampos;
  EdtCodigo.SetFocus;
end;

procedure TFrmPedidos.BntPesquisarClienteClick(Sender: TObject);
var oClientes: TCliente;
begin
 try
  oClientes:=TCliente.Create(DMPedidos.FDConexao);
  FrmConsulta:=TFrmConsulta.Create(Self);
  if oClientes.VerificaVazio then
    begin
      FrmConsulta.Titulofrm:='Consulta Cadastros de Clientes';
      FrmConsulta.SqlText  :='Select Codigo, nome, Codigo From Clientes';
      FrmConsulta.Titulo1  :='Codigo';
      FrmConsulta.Titulo2  :='Descri??o';
      FrmConsulta.Campo1   :='Codigo';
      FrmConsulta.Campo2   :='Nome';
      FrmConsulta.Tamanho1 := 100;
      FrmConsulta.Tamanho2 := 250;

      FrmConsulta.ShowModal;

      if FrmConsulta.bCancelou then
      try
        begin
           if oClientes.Selecionar(StrToInt(FrmConsulta.Resultado)) then
             begin
               EdtCodCliente.Text           := IntToStr(oClientes.codigo);
               EdtDescricaoCliente.Text     := oClientes.nome;
             end;
        end;
      finally

      end;

    end
    else
    MessageDlgCheck('Tabela de Clientes Vazia ou Inexistente',mtWarning, [mbOk], 0, mrOk, True);
  finally
    if Assigned(oClientes) then
      FreeAndNil(oClientes);

    if Assigned(FrmConsulta) then
       FrmConsulta.Release;
  end
end;

procedure TFrmPedidos.BntAlterarClick(Sender: TObject);
var
 oPedido: TPedidos;
 oCliente:TCliente;
// iProximo:Integer;
begin
 try
  oPedido:=TPedidos.Create(DMPedidos.FDConexao);
  FrmConsulta:=TFrmConsulta.Create(Self);
      FrmConsulta.Titulofrm:='Consulta Pedidos';
      FrmConsulta.SqlText  :='Select NumPedido, dtEmissao, NumPedido From Pedidos';
      FrmConsulta.Titulo1  :='N? Pedido';
      FrmConsulta.Titulo2  :='Data de Emiss?o';
      FrmConsulta.Campo1   :='numpedido';
      FrmConsulta.Campo2   :='dtEmissao';
      FrmConsulta.Tamanho1 := 100;
      FrmConsulta.Tamanho2 := 250;

      FrmConsulta.ShowModal;

      if FrmConsulta.bCancelou then
      try
        begin
           if oPedido.Selecionar(StrToInt(FrmConsulta.Resultado)) then
             begin
               vCodigoPedido:=oPedido.numpedido;
               EdtCodCliente.Text   := IntToStr(oPedido.codcliente);
               LblValorTotal.Caption:= FormatFloat('R$ #0.00',oPedido.vltotal);
                  try
                    begin
                      oCliente := TCliente.Create(DMPedidos.FDConexao);
                      if oCliente.Selecionar(oPedido.codcliente) then
                          EdtDescricaoCliente.Text := oCliente.nome;
                    end;
                  finally
                    if Assigned(oCliente) then
                      FreeAndNil(oCliente);
                  end;
              PopulaBufTemp;
             vEstadodoCadastro:='Alterar';
             end;
        end;
      finally
       GrdProdutos.Refresh;
      end;
  finally
    if Assigned(oPedido) then
      FreeAndNil(oPedido);

    if Assigned(FrmConsulta) then
       FrmConsulta.Release;
 end

end;

procedure TFrmPedidos.BntExcluirClick(Sender: TObject);
var
 oPedido: TPedidos;
begin
 try
  oPedido:=TPedidos.Create(DMPedidos.FDConexao);
  FrmConsulta:=TFrmConsulta.Create(Self);
      FrmConsulta.Titulofrm:='Consulta Pedidos';
      FrmConsulta.SqlText  :='Select NumPedido, codcliente, NumPedido From Pedidos';
      FrmConsulta.Titulo1  :='N? Pedido';
      FrmConsulta.Titulo2  :='CodCliente';
      FrmConsulta.Campo1   :='numpedido';
      FrmConsulta.Campo2   :='';
      FrmConsulta.Tamanho1 := 100;
      FrmConsulta.Tamanho2 := 250;

      FrmConsulta.ShowModal;

      if FrmConsulta.bCancelou then
      try
        begin
           if oPedido.Selecionar(StrToInt(FrmConsulta.Resultado)) then
             begin
                vCodigoPedido:=oPedido.numpedido;
                ApagaItensPedido;
                oPedido.Apagar;
             end;
        end;
      finally

      end;
  finally
    if Assigned(oPedido) then
      FreeAndNil(oPedido);

    if Assigned(FrmConsulta) then
       FrmConsulta.Release;
 end;
end;

procedure TFrmPedidos.BntConfirmaClick(Sender: TObject);
var
 oPedido: TPedidos;
 oItenPedido: TItenPedido;
 vCodPedido: Integer;
begin
 try
   if EdtCodCliente.Text = EmptyStr then
     begin
      MessageDlgCheck('O Cliente n?o pode ser vazio', mtWarning, [mbOk], 0, mrOk, True);
      Abort;
     end
   else
     begin
     oPedido:=TPedidos.Create(DMPedidos.FDConexao);
     oPedido.dtemissao := Now;
     oPedido.codcliente:= StrToInt(EdtCodCliente.Text);
     oPedido.vltotal   := StrToFloat(TiraEspeciais(LblValorTotal.Caption));

       if vEstadodoCadastro <> 'Alterar' then
        begin
         if (oPedido.Inserir) then
         try
          vCodPedido:= oPedido.SelecionarCodigo;
          bufTemp.DisableControls;
          bufTemp.First;
          oItenPedido:=TItenPedido.Create(DMPedidos.FDConexao);
          while not bufTemp.EOF do
           begin
             oItenPedido.numpedido :=vCodPedido;
             oItenPedido.codproduto:=bufTemp.FieldByName('codigo').AsInteger;
             oItenPedido.quantidade:=bufTemp.FieldByName('quantidade').AsInteger;
             oItenPedido.vlunitario:=bufTemp.FieldByName('valorUnitario').AsFloat;
             oItenPedido.vltotal   :=bufTemp.FieldByName('valorTotal').AsFloat;
             oItenPedido.Inserir;
             BufTemp.Next;
           end;

         finally
          if Assigned(oItenPedido) then
             FreeAndNil(oItenPedido);
          if Assigned(oPedido) then
             FreeAndNil(oPedido);
          MessageDlgCheck('O Pedido Finalizado com Sucesso', mtWarning, [mbOk], 0, mrOk, True);
          LimparCampos(True);
          LimparBufDataSet;
          vEstadodoCadastro:='Nenhum';
          EdtCodigo.SetFocus;
          //GrdProdutos.Refresh;
         end;
        end
       else
        begin
         if (oPedido.Atualizar) then
         try
          //vCodPedido:= oPedido.SelecionarCodigo;
          bufTemp.DisableControls;
          bufTemp.First;
          oItenPedido:=TItenPedido.Create(DMPedidos.FDConexao);
          while not bufTemp.EOF do
           begin
             if oItenPedido.Selecionar(bufTemp.FieldByName('itemcodigo').AsInteger) then
               begin
               oItenPedido.codproduto:=bufTemp.FieldByName('codigo').AsInteger;
               oItenPedido.quantidade:=bufTemp.FieldByName('quantidade').AsInteger;
               oItenPedido.vlunitario:=bufTemp.FieldByName('valorUnitario').AsFloat;
               oItenPedido.vltotal   :=bufTemp.FieldByName('valorTotal').AsFloat;
               oItenPedido.Atualizar;
               BufTemp.Next;
               end;
           end;
         finally
          if Assigned(oPedido) then
             FreeAndNil(oPedido);
          if Assigned(oItenPedido) then
             FreeAndNil(oItenPedido);
             LimparBufDataSet;
         end;
        end;
     end;

 finally
  BufTemp.Close;
  BufTemp.Open;
  NomeiaTituloGrid;
 end;

end;

procedure TFrmPedidos.BntCancelarClick(Sender: TObject);
begin
Close;
end;

procedure TFrmPedidos.GrdProdutosDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  if not odd(DtsBufTemp.DataSet.RecNo) then
  if not (gdSelected in State) then
    begin
     GrdProdutos.Canvas.Brush.Color:=$00FFEFDF;
     GrdProdutos.Canvas.FillRect(Rect);
     GrdProdutos.DefaultDrawDataCell(rect,Column.Field,State);
    end;
end;

procedure TFrmPedidos.GrdProdutosKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
 begin
   EdtCodigo.Text        :=IntToStr(bufTemp.FieldByName('codigo').AsInteger);
   EdtDescricao.Text     :=bufTemp.FieldByName('Descricao').AsString;
   EdtQuant.Text         :=IntToStr(bufTemp.FieldByName('quantidade').AsInteger);
   EdtValorUnitario.Text :=FloatToStr(bufTemp.FieldByName('valorUnitario').AsFloat);
   EdtValorTotal.Text    :=FloatToStr(bufTemp.FieldByName('valorTotal').AsFloat);
 end;
end;

procedure TFrmPedidos.GrdProdutosKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if DtsBufTemp.DataSet.Active and not DtsBufTemp.DataSet.IsEmpty then
 begin
  if key = vk_delete then
   if MessageDlgCheck('Confirma exclus?o do ' + 'registro atual??',
                 mtConfirmation, [mbYes,mbNo],0,mryes,True) = mrYes then
     begin
      BufTemp.Delete;
      AtualizaTotal;
      LimparCampos;
      EdtCodigo.SetFocus;
     end
    else
     EdtCodigo.SetFocus;
 end
else
 begin
   MessageDlgCheck('Tabela sem Registro', mtInformation, [mbOk], 0, mrOk,True);
   EdtCodigo.SetFocus;
 end;
end;

initialization
  ReportMemoryLeaksOnShutdown:= True;
end.
