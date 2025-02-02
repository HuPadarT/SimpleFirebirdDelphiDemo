object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object DBGrid1: TDBGrid
    Left = 0
    Top = 0
    Width = 624
    Height = 361
    Align = alTop
    DataSource = DataSource1
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object btnLoadData: TButton
    Left = 434
    Top = 367
    Width = 88
    Height = 25
    Caption = 'Load Data'
    TabOrder = 1
    OnClick = btnLoadDataClick
  end
  object btAdd: TButton
    Left = 0
    Top = 367
    Width = 98
    Height = 25
    Caption = 'Add new person'
    TabOrder = 2
    OnClick = btAddClick
  end
  object btnDelete: TButton
    Left = 528
    Top = 367
    Width = 88
    Height = 25
    Caption = 'Delete person'
    TabOrder = 3
    OnClick = btnDeleteClick
  end
  object btnSave: TButton
    Left = 104
    Top = 367
    Width = 98
    Height = 25
    Caption = 'Save changes'
    TabOrder = 4
    OnClick = btnSaveClick
  end
  object btnCancel: TButton
    Left = 208
    Top = 367
    Width = 73
    Height = 25
    Caption = 'Cancel'
    TabOrder = 5
    OnClick = btnCancelClick
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 408
    Width = 624
    Height = 33
    Panels = <
      item
        Width = 50
      end>
    ExplicitTop = 406
  end
  object FDConnection1: TFDConnection
    Left = 24
    Top = 376
  end
  object FDQuery1: TFDQuery
    Connection = FDConnection1
    Left = 208
    Top = 376
  end
  object FDTable1: TFDTable
    CachedUpdates = True
    Connection = FDConnection1
    Left = 128
    Top = 376
  end
  object FDPhysFBDriverLink1: TFDPhysFBDriverLink
    Left = 336
    Top = 376
  end
  object DataSource1: TDataSource
    DataSet = FDTable1
    Left = 424
    Top = 376
  end
  object OpenDialog1: TOpenDialog
    Left = 184
    Top = 104
  end
end
