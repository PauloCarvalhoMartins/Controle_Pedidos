object DMPedidos: TDMPedidos
  OldCreateOrder = False
  Height = 211
  Width = 214
  object FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink
    VendorLib = 'C:\Projetos\1Click\ConPedido\Lib\libmysql.dll'
    Left = 88
    Top = 88
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 88
    Top = 152
  end
  object FDConexao: TFDConnection
    Params.Strings = (
      'Database=ConPedido'
      'User_Name=Teste'
      'Password=123456'
      'DriverID=MySQL')
    LoginPrompt = False
    Left = 88
    Top = 24
  end
end
