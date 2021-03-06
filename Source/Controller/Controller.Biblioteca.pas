unit Controller.Biblioteca;

interface

Uses
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.Dialogs;

type
 TEstadoDoCadastro = (ecInserir, ecAlterar, ecNenhum);
 function MessageDlgCheck(Msg: string; AType: TMsgDlgType;
     AButtons: TMsgDlgButtons; IndiceHelp: Integer; DefButton: TMOdalResult;
     Portugues: Boolean): Word;
 function TiraEspeciais(text:string): String;

implementation

function MessageDlgCheck(Msg: string; AType: TMsgDlgType; AButtons:
  TMsgDlgButtons;IndiceHelp: LongInt; DefButton: TMOdalResult; Portugues: Boolean): Word;
var
  I: Integer;
  Mensagem: TForm;
begin
  Mensagem := CreateMessageDialog(Msg, AType, Abuttons);
  Mensagem.HelpContext := IndiceHelp;
  with Mensagem do
  begin
    for i := 0 to ComponentCount - 1 do
    begin
      if (Components[i] is TButton) then
      begin
        if (TButton(Components[i]).ModalResult = DefButton) then
        begin
          ActiveControl := TWincontrol(Components[i]);
        end;
      end;
    end;
    if Portugues then
    begin
      if Atype = mtConfirmation then
        Caption := 'Confirma??o'
      else if AType = mtWarning then
        Caption := 'Aviso'
      else if AType = mtError then
        Caption := 'Erro'
      else if AType = mtInformation then
        Caption := 'Informa??o';
    end;
  end;
  if Portugues then
  begin
    TButton(Mensagem.FindComponent('YES')).Caption := '&Sim';
    TButton(Mensagem.FindComponent('NO')).Caption := '&N?o';
    TButton(Mensagem.FindComponent('CANCEL')).Caption := '&Cancelar';
    TButton(Mensagem.FindComponent('ABORT')).Caption := '&Abortar';
    TButton(Mensagem.FindComponent('RETRY')).Caption := '&Repetir';
    TButton(Mensagem.FindComponent('IGNORE')).Caption := '&Ignorar';
    TButton(Mensagem.FindComponent('ALL')).Caption := '&Todos';
    TButton(Mensagem.FindComponent('HELP')).Caption := 'A&juda';
    TButton(Mensagem.FindComponent('YesToAll')).Caption := '&Sim';
    TButton(Mensagem.FindComponent('NoToAll')).Caption := '&N?o';
  end;
  Result := Mensagem.ShowModal;
  Mensagem.Free;
end;

function TiraEspeciais(text: string): String;
var aux:string;
    i:integer;
begin
Aux := '';
for i :=1 to Length(text) do
    begin
    if(copy(text,i,1)<>'R')and(copy(text,i,1)<>'$')and(copy(text,i,1)<>'%')then
      begin
      Aux := Aux + copy(text,i,1);
      end;
    end;
Result := Aux;
end;

end.
