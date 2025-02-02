unit uFireBirdTesztGUI;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids, Vcl.DBGrids, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.Phys, FireDAC.Phys.IBBase, FireDAC.Phys.FB, FireDAC.VCLUI.Wait, Vcl.StdCtrls, FireDAC.UI.Intf,
  FireDAC.Stan.Def,  FireDAC.Stan.Pool, FireDAC.Phys.FBDef, Vcl.ComCtrls;

type
  TForm1 = class(TForm)
    FDConnection1: TFDConnection;
    FDQuery1: TFDQuery;
    FDTable1: TFDTable;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    btnLoadData: TButton;
    btAdd: TButton;
    btnDelete: TButton;
    btnSave: TButton;
    btnCancel: TButton;
    OpenDialog1: TOpenDialog;
    StatusBar1: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure btnLoadDataClick(Sender: TObject);
    procedure btAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
    procedure SetupDatabase;
    procedure CreateTableIfNotExists;
    procedure InsertSampleData;
    procedure LoadData;
    function BrowseImportData: string;
    function GetDatabasePath: string;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses System.Generics.Collections;
{$R *.dfm}

function TForm1.BrowseImportData: string;
begin
  OpenDialog1.Filter := 'CSV (*.csv)|*.csv';
  Result := '';
  if OpenDialog1.Execute then
  begin
    if FileExists(OpenDialog1.FileName) then
    begin
      Result := OpenDialog1.FileName;
    end
    else
    begin
      ShowMessage('A fájl nem létezik!');
    end;
  end;
end;

procedure TForm1.btAddClick(Sender: TObject);
begin
  FDTable1.Append;
  FDTable1.FieldByName('LASTNAME').AsString := 'Teszt';
  FDTable1.FieldByName('FIRSTNAME').AsString := 'Bárki';
  FDTable1.FieldByName('PERSONCARDID').AsString := '32r45htrztk';
  FDTable1.FieldByName('ADDRESSCARDID').AsString := 'ewrtz544';
  FDTable1.FieldByName('ADDRESSTYPE').AsString := 'IDEIGLENES';
  FDTable1.FieldByName('POSTCODE').AsString := '1039';
  FDTable1.FieldByName('CITY').AsString := 'BUDAPEST';
  FDTable1.FieldByName('STREET').AsString := 'Nincs ilyen utca';
  FDTable1.FieldByName('HOUSENUMBER').AsString := '2999/A';
  FDTable1.FieldByName('CONTACTTYPE').AsString := 'EMAIL';
  FDTable1.FieldByName('CONTACT').AsString := 'valami@email.hu';
end;

procedure TForm1.btnCancelClick(Sender: TObject);
begin
  if FDTable1.UpdatesPending then
  begin
    FDTable1.CancelUpdates; // Minden nem mentett módosítás elvetése
    StatusBar1.Panels[0].Text := 'Changes have been dropped.';
  end
  else
    StatusBar1.Panels[0].Text := 'There is nothing to save.';
end;

procedure TForm1.btnDeleteClick(Sender: TObject);
begin
  if not FDTable1.IsEmpty then
  begin
    if True then
    begin
      FDTable1.Delete;
      StatusBar1.Panels[0].Text := 'Person deleted!'
    end;
  end;
end;

procedure TForm1.btnLoadDataClick(Sender: TObject);
begin
  LoadData;
end;

procedure TForm1.btnSaveClick(Sender: TObject);
var sc: integer;
begin
  if FDTable1.UpdatesPending then // Ha van függõben lévõ módosítás
  begin
    try
      sc := FDTable1.ApplyUpdates(0); // Az összes módosítás végleges mentése
      if sc = 0 then
        StatusBar1.Panels[0].Text := 'Save successful!'
      else
      begin
        StatusBar1.Panels[0].Text := 'Changes save failed!';
        LoadData;
      end;
    except
      on E: Exception do
      begin
        ShowMessage('An error occured: ' + E.Message);
        FDTable1.CancelUpdates; // Sikertelen mentés esetén elvetjük a módosításokat
      end;
    end;
  end
  else
    ShowMessage('There is nothing to save.');
end;

procedure TForm1.SetupDatabase;
var
  DBPath: string;
  TempConn: TFDConnection;
begin
  DBPath := GetDatabasePath;

  // Ha az adatbázis nem létezik, akkor létrehozzuk
  if not FileExists(DBPath) then
  begin
    TempConn := TFDConnection.Create(nil);
    try
      TempConn.Params.Clear;
      TempConn.Params.Add('DriverID=FB');
      TempConn.Params.Add('Database=' + DBPath);
      TempConn.Params.Add('User_Name=SYSDBA');
      TempConn.Params.Add('Password=masterkey');
      TempConn.Params.Add('Server=');
      TempConn.Params.Add('Protocol=Local');
      TempConn.Params.Add('CreateDatabase=Yes'); // FONTOS: Ez itt mûködik, de a fõ kapcsolatban NEM!
      TempConn.Connected := True;
    finally
      TempConn.Free;
    end;
  end;

  FDConnection1.Close;
  FDConnection1.Params.Clear;
  FDConnection1.Params.Add('DriverID=FB');
  FDConnection1.Params.Add('Database=' + DBPath);
  FDConnection1.Params.Add('User_Name=SYSDBA');
  FDConnection1.Params.Add('Password=masterkey');
  // az embedded db miatt
  FDConnection1.Params.Add('Server=');
  FDConnection1.Params.Add('Protocol=Local');

  FDConnection1.Connected := True;

  CreateTableIfNotExists;
end;

procedure TForm1.CreateTableIfNotExists;
begin
  FDQuery1.SQL.Clear;
  FDQuery1.SQL.Text :=
    'SELECT COUNT(*) FROM RDB$RELATIONS WHERE RDB$RELATION_NAME = ''PERSON''';
  FDQuery1.Open;

  if FDQuery1.Fields[0].AsInteger = 0 then
  begin
    // auto increment mezõ létrehozása
    FDQuery1.SQL.Text := 'CREATE GENERATOR GEN_PERSON_ID';
    try
      FDQuery1.Execute();
    except
      on e:Exception do

        raise Exception.Create('ERROR 4:' + sLineBreak + E.Message);
    end;
    FDQuery1.SQL.Clear;
    FDQuery1.SQL.Text :=
      'CREATE TABLE PERSON (ID INTEGER NOT NULL, ' +
      'LastName VARCHAR(50) NOT NULL, FirstName VARCHAR(50) NOT NULL, PersonCardId VARCHAR(15) NOT NULL,' +
      'AddressCardId VARCHAR(15) NOT NULL, AddressType VARCHAR(15) NOT NULL, Postcode VARCHAR(10), ' +
      'City VARCHAR(50), Street VARCHAR(250), HouseNumber VARCHAR(20), ContactType VARCHAR(250) NOT NULL, ' +
      'Contact VARCHAR(250), ' +
      'CONSTRAINT PK_PERSON PRIMARY KEY (ID))';
    try
      FDQuery1.Execute();
    except
      on e:Exception do
        raise Exception.Create('ERROR 1:' + sLineBreak + E.Message);
    end;
    FDQuery1.SQL.Clear;
    FDQuery1.SQL.Text := 'CREATE OR ALTER TRIGGER PERSON_BI FOR PERSON ' +
      'ACTIVE BEFORE INSERT POSITION 0 ' +
      'AS ' +
      'BEGIN ' +
      '  IF (NEW.ID IS NULL) THEN ' +
      '  NEW.ID = NEXT VALUE FOR GEN_PERSON_ID; ' +
      'END';
    try
      FDQuery1.Execute();
    except
      on e:Exception do
        raise Exception.Create('ERROR 2:' + sLineBreak + E.Message);
    end;

    // Mintaadatok feltöltése
    InsertSampleData;
  end;

  FDQuery1.Close;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  SetupDatabase;
  LoadData;
end;

function TForm1.GetDatabasePath: string;
begin
  Result := ExtractFilePath(ParamStr(0)) + 'DataDb.fdb';
end;

procedure TForm1.InsertSampleData;
var FileContent: TStringList;
    Lines: TArray<string>;
    Line, FileName: string;
    Parts: TStringList;
    Headers: TDictionary<string, Integer>;
begin
  FileName := BrowseImportData;
  FileContent := TStringList.Create;
  try
    Headers := TDictionary<string, Integer>.Create;
    try
      Parts := TStringList.Create();
      try
        FileContent.LoadFromFile(FileName, TEncoding.UTF8);
        Lines := FileContent.Text.Split([sLineBreak], TStringSplitOptions.ExcludeEmpty);

        if Length(Lines) < 2 then // van legalább 2 sora (fejléc és 1 rekord)
        begin
          StatusBar1.Panels[0].Text := 'The file contains too few lines.';
          Exit;
        end;

        Line := Lines[0]; // fejléc
        Parts.Delimiter := ';';
        Parts.StrictDelimiter := true;
        Parts.DelimitedText := Line;
        if Parts.Count < 11 then // meg van minden mezõ?
        begin
          StatusBar1.Panels[0].Text := 'Not enough fields in the row.';
          Exit;
        end;
        for var i := 0 to Parts.Count-1 do
          Headers.Add(Trim(Parts[i]), i); // Mezõnév -> Index párok

        FDQuery1.SQL.Text := 'INSERT INTO Person (LastName,FirstName,PersonCardId,AddressCardId,' +
          'AddressType,Postcode,City,Street,HouseNumber,ContactType,Contact) VALUES (:pLName,:pFName,' +
          ':pCId,:apAId,:pAddressType,:pPostcode,:pCity,:pStreet,:pHouseNumber,:pContactType,:pContact);';

        for var i := 1 to High(Lines) do
        begin
          Line := Lines[i];
          if Line = '' then Continue;
          Parts.DelimitedText := Line;

          if Parts.Count >= Headers.Count then  // Ellenõrizzük, hogy van-e elég oszlop
          begin
            try
              FDQuery1.Params.ParamByName('pLName').AsString := Parts[Headers['Vezeteknev']];
              FDQuery1.Params.ParamByName('pFName').AsString := Parts[Headers['Keresztnev']];
              FDQuery1.Params.ParamByName('pCId').AsString := Parts[Headers['SzemelyiAzon']];
              FDQuery1.Params.ParamByName('apAId').AsString := Parts[Headers['LakcimAzon']];
              FDQuery1.Params.ParamByName('pAddressType').AsString := Parts[Headers['CimTipus']];
              FDQuery1.Params.ParamByName('pPostcode').AsString := Parts[Headers['IranyitoSzam']];
              FDQuery1.Params.ParamByName('pCity').AsString := Parts[Headers['Telepules']];
              FDQuery1.Params.ParamByName('pStreet').AsString := Parts[Headers['Utca']];
              FDQuery1.Params.ParamByName('pHouseNumber').AsString := Parts[Headers['Hazszam']];
              FDQuery1.Params.ParamByName('pContactType').AsString := Parts[Headers['ElerhetosegTipus']];
              FDQuery1.Params.ParamByName('pContact').AsString := Parts[Headers['Elerhetoseg']];
              FDQuery1.ExecSQL;
            except
              on E: Exception do
                ShowMessage('An error occured: ' + E.Message);
            end;
          end;
        end;
      finally
        Parts.Free;
      end;
    finally
      Headers.Free;
    end;
  finally
    FileContent.Free;
  end;
end;

procedure TForm1.LoadData;
begin
  FDTable1.Active := False;
  FDTable1.Connection := FDConnection1;
  FDTable1.TableName := 'PERSON';
  FDTable1.Open;
end;

end.
