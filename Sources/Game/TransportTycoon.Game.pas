unit TransportTycoon.Game;

interface

uses
  Classes,
  SysUtils,
  TransportTycoon.Map,
  TransportTycoon.Races,
  TransportTycoon.Calendar,
  TransportTycoon.Company,
  TransportTycoon.Vehicles,
  TransportTycoon.Finances,
  TransportTycoon.Construct;

type
  TGameSpeedEnum = (spSlow, spNormal, spFast, spDebug);

const
  GameSpeedStr: array [TGameSpeedEnum] of string = ('Slow', 'Normal',
    'Fast', 'Debug');

const
  GameSpeedValue: array [TGameSpeedEnum] of Byte = (50, 25, 10, 0);

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
    FCount: Byte;
    FIsPause: Boolean;
    FIsGame: Boolean;
    FConstruct: TConstruct;
    FSpeed: TGameSpeedEnum;
    FLockScreen: Boolean;
    FIsOrder: Boolean;
    FRace: TRaceEnum;
    procedure ForceDirs;
  public const
    MaxLoan = 200000;
    LoanMoney = 10000;
    StartMoney = MaxLoan div 2;
    Version = '0.4';
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
    property Construct: TConstruct read FConstruct;
    property IsPause: Boolean read FIsPause write FIsPause;
    property IsGame: Boolean read FIsGame write FIsGame;
    property IsOrder: Boolean read FIsOrder write FIsOrder;
    property Speed: TGameSpeedEnum read FSpeed;
    property Race: TRaceEnum read FRace write FRace;
    procedure Clear;
    procedure Step;
    function GetPath(ASubDir: string): string;
    procedure ModifyMoney(const AMoney: Integer); overload;
    procedure ModifyMoney(const AValueEnum: TValueEnum;
      const AMoney: Integer); overload;
    procedure LoadSettings;
    procedure SaveSettings;
    function CanRepay: Boolean;
    procedure Repay;
    function CanBorrow: Boolean;
    procedure Borrow;
    procedure NextSpeed;
    procedure PrevSpeed;
    procedure NextRace;
    procedure PrevRace;
    procedure Save;
    procedure Load;
  end;

var
  Game: TGame;

implementation

uses
  Math,
  IniFiles;

constructor TGame.Create;
var
  LParam: Integer;
begin
  FRace := reHuman;
  FIsOrder := False;
  FIsDebug := False;
  for LParam := 1 to ParamCount do
  begin
    if (LowerCase(ParamStr(LParam)) = '-debug')
{$IFDEF DEBUG}
{$IF CompilerVersion > 16}
{$WARN SYMBOL_PLATFORM OFF}
      or (DebugHook > 0)
{$IFEND}
{$ENDIF}
    then
      FIsDebug := True;
  end;
  FCount := 0;
  FLockScreen := False;
  FSpeed := spNormal;
  FCalendar := TCalendar.Create;
  FCompany := TCompany.Create;
  FFinances := TFinances.Create;
  FIsPause := True;
  FMap := TMap.Create;
  FMap.Gen(mtRandom);
  FVehicles := TVehicles.Create;
  FConstruct := TConstruct.Create;
  ForceDirs;
end;

destructor TGame.Destroy;
begin
  FreeAndNil(FMap);
  FreeAndNil(FConstruct);
  FreeAndNil(FVehicles);
  FreeAndNil(FFinances);
  FreeAndNil(FCompany);
  FreeAndNil(FCalendar);
  inherited Destroy;
end;

function TGame.GetPath(ASubDir: string): string;
begin
  Result := ExtractFilePath(ParamStr(0));
  Result := IncludeTrailingPathDelimiter(Result + ASubDir);
end;

procedure TGame.LoadSettings;
var
  LIniFile: TMemIniFile;
begin
  LIniFile := TMemIniFile.Create(GetPath('') + 'Settings.ini', TEncoding.UTF8);
  try
    Game.Map.MapSize := TMapSize(LIniFile.ReadInteger('Main', 'MapSize', 0));
    Game.Map.SeaLevel := TMapSeaLevel(LIniFile.ReadInteger('Main',
      'SeaLevel', 0));
    Game.Map.NoOfTowns := LIniFile.ReadInteger('Main', 'NoOfTowns', 1);
    Game.Calendar.Year := EnsureRange(LIniFile.ReadInteger('Main', 'Year',
      StartYear), StartYear, FinishYear);
    Game.Map.Rivers := TMapRivers(LIniFile.ReadInteger('Main', 'Rivers', 0));
    Game.Map.NoOfInd := TMapNoOfInd(LIniFile.ReadInteger('Main', 'NoOfInd', 0));
    Game.Race := TRaceEnum(LIniFile.ReadInteger('Main', 'Race', 0));
  finally
    FreeAndNil(LIniFile);
  end;
end;

procedure TGame.ModifyMoney(const AValueEnum: TValueEnum;
  const AMoney: Integer);
begin
  Finances.ModifyValue(AValueEnum, Abs(AMoney));
  FMoney := FMoney + AMoney;
end;

procedure TGame.NextRace;
begin
  if (FRace = reElf) then
    FRace := reHuman
  else
    Inc(FRace);
end;

procedure TGame.PrevRace;
begin
  if (FRace = reHuman) then
    FRace := reElf
  else
    Dec(FRace);
end;

procedure TGame.NextSpeed;
var
  LHighSpeed: TGameSpeedEnum;
begin
  if FIsDebug then
    LHighSpeed := High(TGameSpeedEnum)
  else
    LHighSpeed := Pred(High(TGameSpeedEnum));
  if (FSpeed = LHighSpeed) then
  begin
    FSpeed := Low(TGameSpeedEnum);
    Exit;
  end;
  Inc(FSpeed);
end;

procedure TGame.PrevSpeed;
var
  LHighSpeed: TGameSpeedEnum;
begin
  if FIsDebug then
    LHighSpeed := High(TGameSpeedEnum)
  else
    LHighSpeed := Pred(High(TGameSpeedEnum));
  if (FSpeed = Low(TGameSpeedEnum)) then
  begin
    FSpeed := LHighSpeed;
    Exit;
  end;
  Dec(FSpeed);
end;

function TGame.CanRepay: Boolean;
begin
  Result := (FLoan >= LoanMoney) and (FMoney >= LoanMoney);
end;

procedure TGame.Repay;
begin
  if CanRepay then
  begin
    FLoan := FLoan - LoanMoney;
    FMoney := FMoney - LoanMoney;
  end
end;

procedure TGame.ModifyMoney(const AMoney: Integer);
begin
  FMoney := FMoney + AMoney;
end;

procedure TGame.Load;
begin

end;

procedure TGame.ForceDirs;
var
  LSlot: Integer;
begin
  ForceDirectories(GetPath('Saves'));
  for LSlot := 0 to 9 do
    ForceDirectories(GetPath(Format('Saves/%d', [LSlot])));
end;

procedure TGame.Save;
begin

end;

procedure TGame.SaveSettings;
var
  LIniFile: TMemIniFile;
begin
  LIniFile := TMemIniFile.Create(GetPath('') + 'Settings.ini', TEncoding.UTF8);
  try
    LIniFile.WriteInteger('Main', 'MapSize', Ord(Game.Map.MapSize));
    LIniFile.WriteInteger('Main', 'SeaLevel', Ord(Game.Map.SeaLevel));
    LIniFile.WriteInteger('Main', 'NoOfTowns', Game.Map.NoOfTowns);
    LIniFile.WriteInteger('Main', 'Year', Game.Calendar.Year);
    LIniFile.WriteInteger('Main', 'Rivers', Ord(Game.Map.Rivers));
    LIniFile.WriteInteger('Main', 'NoOfInd', Ord(Game.Map.NoOfInd));
    LIniFile.WriteInteger('Main', 'Race', Ord(Game.Race));
    LIniFile.UpdateFile;
  finally
    FreeAndNil(LIniFile);
  end;
end;

procedure TGame.Step;
begin
  if not IsGame or IsPause then
    Exit;
  Inc(FTurn);
  Inc(FCount);
  if (FCount >= 3) then
  begin
    FCount := 0;
    FCalendar.Step;
  end;
  FVehicles.Step;
end;

function TGame.CanBorrow: Boolean;
begin
  Result := Loan < MaxLoan;
end;

procedure TGame.Borrow;
begin
  if CanBorrow then
  begin
    FLoan := FLoan + 10000;
    FMoney := FMoney + 10000;
  end;
end;

procedure TGame.Clear;
begin
  FTurn := 0;
  FIsGame := True;
  FIsOrder := False;
  FConstruct.Clear;
  FMoney := StartMoney;
  FLoan := StartMoney;
  FFinances.Clear;
  FFinances.SetYear(Calendar.Year);
  FMap.Gen;
  FVehicles.Clear;
  FCompany.Clear;
end;

end.
