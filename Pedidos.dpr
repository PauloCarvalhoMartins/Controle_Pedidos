program Pedidos;

uses
  Vcl.Forms,
  uFrmPedidos in 'Source\View\uFrmPedidos.pas' {FrmPedidos},
  uDMPedidos in 'Source\Providers\uDMPedidos.pas' {DMPedidos: TDataModule},
  Service.Clientes in 'Source\Service\Service.Clientes.pas',
  Service.Produtos in 'Source\Service\Service.Produtos.pas',
  Service.Pedidos in 'Source\Service\Service.Pedidos.pas',
  Service.ItensPedidos in 'Source\Service\Service.ItensPedidos.pas',
  Controller.Biblioteca in 'Source\Controller\Controller.Biblioteca.pas',
  uFrmConsulta in 'Source\View\uFrmConsulta.pas' {FrmConsulta};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmPedidos, FrmPedidos);
  Application.Run;
end.
