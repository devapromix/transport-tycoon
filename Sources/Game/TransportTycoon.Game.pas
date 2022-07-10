﻿unit TransportTycoon.Game;

interface

uses
  Classes,
  SysUtils,
  TransportTycoon.Map,
  TransportTycoon.Calendar,
  TransportTycoon.Company,
  TransportTycoon.Vehicles,
  TransportTycoon.Finances;

type
  TGame = class(TObject)
  private
    FMoney: Integer;
    FFinances: TFinances;
    FLoan: Integer;
    FCompany: TCompany;
    FVehicles: TVehicles;
    FMap: TMap;
    FCalendar: TCalendar;
    FIsDebug: Boolean;
    FTurn: Integer;
    FIsPause: Boolean;
    FIsGame: Boolean;
    FIsClearLand: Boolean;
    FIsBuildCanals: Boolean;
  public const
    MaxLoan = 200000;
    StartMoney = MaxLoan div 2;
    Version = '0.2';
  public
    constructor Create;
    destructor Destroy; override;
    property Money: Integer read FMoney;
    property Loan: Integer read FLoan;
    property Company: TCompany read FCompany;
    property Finances: TFinances read FFinances write FFinances;
    property Vehicles: TVehicles read FVehicles;
    property Calendar: TCalendar read FCalendar;
    property Map: TMap read FMap;
    property IsDebug: Boolean read FIsDebug;
    property Turn: Integer read FTurn;
    property IsClearLand: Boolean read FIsClearLand write FIsClearLand;
    property IsBuildCanals: Boolean read FIsBuildCanals write FIsBuildCanals;
    property IsPause: Boolean read FIsPause write FIsPause;
    property IsGame: Boolean read FIsGame write FIsGame;
    procedure Clear;
    procedure Step;
    function GetPath(SubDir: string): string;
    procedure ModifyMoney(const AMoney: Integer); overload;
    procedure ModifyMoney(const ValueEnum: TValueEnum;
      const AMoney: Integer); overload;
    procedure LoadSettings;
    procedure SaveSettings;
    procedure Repay;
  end;

var
  Game: TGame;

implementation

uses
  Math,
  IniFiles;

constructor TGame.Create;
var
  I: Integer;
begin
  FIsDebug := False;
  for I := 1 to ParamCount do
  begin
    if (LowerCase(ParamStr(I)) = '-debug') then
      FIsDebug := True;
  end;
  FCalendar := TCalendar.Create;
  FCompany := TCompany.Create;
  FFinances := TFinances.Create;
  FIsClearLand := False;
  FIsBuildCanals := False;
  FIsPause := True;
  FMap := TMap.Create;
  FMap.Gen;
  FVehicles := TVehicles.Create;
end;

destructor TGame.Destroy;
begin
  FMap.Free;
  FVehicles.Free;
  FFinances.Free;
  FCompany.Free;
  FCalendar.Free;
  inherited Destroy;
end;

function TGame.GetPath(SubDir: string): string;
begin
  Result := ExtractFilePath(ParamStr(0));
  Result := IncludeTrailingPathDelimiter(Result + SubDir);
end;

procedure TGame.LoadSettings;
var
  IniFile: TMemIniFile;
begin
  IniFile := TMemIniFile.Create(GetPath('') + 'Settings.ini', TEncoding.UTF8);
  try
    Game.Map.Size := TMapSize(IniFile.ReadInteger('Main', 'MapSize', 0));
    Game.Map.SeaLevel := TMapSeaLevel(IniFile.ReadInteger('Main',
      'SeaLevel', 0));
    Game.Map.NoOfTowns := IniFile.ReadInteger('Main', 'NoOfTowns', 1);
    Game.Calendar.Year := EnsureRange(IniFile.ReadInteger('Main', 'Year',
      TCalendar.StartYear), TCalendar.StartYear, TCalendar.FinishYear);
    Game.Map.Rivers := TMapRivers(IniFile.ReadInteger('Main', 'Rivers', 0));
    Game.Map.NoOfInd := TMapNoOfInd(IniFile.ReadInteger('Main', 'NoOfInd', 0));
  finally
    FreeAndNil(IniFile);
  end;
end;

procedure TGame.ModifyMoney(const ValueEnum: TValueEnum; const AMoney: Integer);
begin
  Finances.ModifyValue(ValueEnum, Abs(AMoney));
  FMoney := FMoney + AMoney;
end;

procedure TGame.Repay;
begin
  if Loan >= 10000 then
    FLoan := FLoan - 10000;
end;

procedure TGame.ModifyMoney(const AMoney: Integer);
begin
  FMoney := FMoney + AMoney;
end;

procedure TGame.SaveSettings;
var
  IniFile: TMemIniFile;
begin
  IniFile := TMemIniFile.Create(GetPath('') + 'Settings.ini', TEncoding.UTF8);
  try
    IniFile.WriteInteger('Main', 'MapSize', Ord(Game.Map.Size));
    IniFile.WriteInteger('Main', 'SeaLevel', Ord(Game.Map.SeaLevel));
    IniFile.WriteInteger('Main', 'NoOfTowns', Game.Map.NoOfTowns);
    IniFile.WriteInteger('Main', 'Year', Game.Calendar.Year);
    IniFile.WriteInteger('Main', 'Rivers', Ord(Game.Map.Rivers));
    IniFile.WriteInteger('Main', 'NoOfInd', Ord(Game.Map.NoOfInd));
    IniFile.UpdateFile;
  finally
    FreeAndNil(IniFile);
  end;
end;

procedure TGame.Step;
begin
  if not IsGame or IsPause then
    Exit;
  Inc(FTurn);
  FCalendar.Step;
  FVehicles.Step;
end;

procedure TGame.Clear;
begin
  FTurn := 0;
  FIsGame := True;
  FIsClearLand := False;
  FIsBuildCanals := False;
  FMoney := StartMoney;
  FLoan := StartMoney;
  FFinances.Clear;
  FMap.Gen;
  FCompany.Clear;
  FVehicles.Clear;
end;

initialization

Game := TGame.Create;

finalization

Game.Free;

end.
