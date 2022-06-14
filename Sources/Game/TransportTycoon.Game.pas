unit TransportTycoon.Game;

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
  public const
    MaxLoan = 200000;
    StartMoney = MaxLoan div 2;
    Version = '0.1';
  public
    IsClearLand: Boolean;
    IsPause: Boolean;
    IsGame: Boolean;
    Turn: Integer;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Step;
    function GetPath(SubDir: string): string;
    property Money: Integer read FMoney;
    procedure ModifyMoney(const AMoney: Integer); overload;
    procedure ModifyMoney(const ValueEnum: TValueEnum;
      const AMoney: Integer); overload;
    property Loan: Integer read FLoan;
    property Company: TCompany read FCompany;
    property Finances: TFinances read FFinances write FFinances;
    property Vehicles: TVehicles read FVehicles;
    property Calendar: TCalendar read FCalendar;
    property Map: TMap read FMap;
    procedure LoadSettings;
    procedure SaveSettings;
  end;

var
  Game: TGame;

implementation

uses
  IniFiles;

constructor TGame.Create;
begin
  FCalendar := TCalendar.Create;
  FCompany := TCompany.Create;
  FFinances := TFinances.Create;
  IsClearLand := False;
  IsPause := True;
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
    Game.Map.SeaLevel := TMapSeaLevel(IniFile.ReadInteger('Main', 'SeaLevel', 0));
    Game.Map.NoOfTowns := IniFile.ReadInteger('Main', 'NoOfTowns', 1);
  finally
    FreeAndNil(IniFile);
  end;
end;

procedure TGame.ModifyMoney(const ValueEnum: TValueEnum; const AMoney: Integer);
begin
  Finances.ModifyValue(ValueEnum, Abs(AMoney));
  FMoney := FMoney + AMoney;
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
    IniFile.UpdateFile;
  finally
    FreeAndNil(IniFile);
  end;
end;

procedure TGame.Step;
begin
  if not IsGame or IsPause then
    Exit;
  Inc(Turn);
  FCalendar.Step;
  FVehicles.Step;
end;

procedure TGame.Clear;
begin
  Turn := 0;
  IsGame := True;
  IsClearLand := False;
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
