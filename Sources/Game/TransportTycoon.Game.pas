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

type
  TSlot = 0 .. 9;

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
    FSlotStr: array [TSlot] of string;
    FFullscreen: Boolean;
    FCanClose: Boolean;
    FYear: Word;
    procedure ForceDirs;
  public const
    MaxLoan = 200000;
    LoanMoney = 10000;
    StartMoney = MaxLoan div 2;
    Version = '0.4';
    EmptySlotStr = 'EMPTY SLOT';
  public
    constructor Create;
    destructor Destroy; override;
    property Money: Integer read FMoney;
    property Loan: Integer read FLoan;
    property Company: TCompany read FCompany;
    property Finances: TFinances read FFinances write FFinances;
    property Vehicles: TVehicles read FVehicles;
    property Calendar: TCalendar read FCalendar;
    property Year: Word read FYear write FYear;
    property Map: TMap read FMap;
    property IsDebug: Boolean read FIsDebug;
    property Turn: Integer read FTurn;
    property Construct: TConstruct read FConstruct;
    property IsPause: Boolean read FIsPause write FIsPause;
    property IsGame: Boolean read FIsGame write FIsGame;
    property IsOrder: Boolean read FIsOrder write FIsOrder;
    property Speed: TGameSpeedEnum read FSpeed;
    property Race: TRaceEnum read FRace write FRace;
    property Fullscreen: Boolean read FFullscreen write FFullscreen;
    property CanClose: Boolean read FCanClose write FCanClose;
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
    procedure ScanSaveDir;
    procedure Save(const ASlot: Byte);
    procedure Load(const ASlot: Byte);
    function GetSlotStr(const ASlot: Byte): string;
    function GetFileName(const ASlot: Byte): string;
    function GetSlotName(const ASlot: Byte): string;
    function IsSlotFileExists(const ASlot: Byte): Boolean;
    procedure Refresh;
  end;

var
  Game: TGame;

implementation

uses
  Math,
  Dialogs,
  IniFiles,
  System.JSON,
  BearLibTerminal,
  Neon.Core.Persistence,
  Neon.Core.Persistence.JSON,
  TransportTycoon.Scenes,
  TransportTycoon.Industries;

constructor TGame.Create;
var
  LParam: Integer;
begin
  FCanClose := False;
  FRace := reHuman;
  FIsOrder := False;
  FIsDebug := False;
  FFullscreen := False;
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

function TGame.GetFileName(const ASlot: Byte): string;
begin
  Result := GetPath(Format('Saves\%d', [ASlot])) + 'game.json';
end;

function TGame.GetPath(ASubDir: string): string;
begin
  Result := ExtractFilePath(ParamStr(0));
  Result := IncludeTrailingPathDelimiter(Result + ASubDir);
end;

function TGame.GetSlotName(const ASlot: Byte): string;
var
  LIniFile: TMemIniFile;
  LYear: Integer;
  LCompanyName, LDate: string;
begin
  Result := '';
  LIniFile := TMemIniFile.Create(GetFileName(ASlot), TEncoding.UTF8);
  try
    LDate := LIniFile.ReadString('Game', 'Date', DateTimeToStr(Date));
    LYear := LIniFile.ReadInteger('Calendar', 'Year', StartYear);
    LCompanyName := LIniFile.ReadString('Company', 'Name', '');
    Result := Format('%s / %d / %s', [LCompanyName, LYear, LDate]);
  finally
    FreeAndNil(LIniFile);
  end;

end;

function TGame.GetSlotStr(const ASlot: Byte): string;
begin
  Result := FSlotStr[ASlot];
end;

procedure TGame.LoadSettings;
var
  LIniFile: TMemIniFile;
begin
  LIniFile := TMemIniFile.Create(GetPath('') + 'Settings.ini', TEncoding.UTF8);
  try
    // Window
    Game.Fullscreen := LIniFile.ReadBool('Window', 'Fullscreen', False);
    // Calendar
    Game.Calendar.Day := EnsureRange(LIniFile.ReadInteger('Calendar', 'Day',
      1), 1, 31);
    Game.Calendar.Month := EnsureRange(LIniFile.ReadInteger('Calendar', 'Month',
      1), 1, 12);
    Game.Calendar.Year := EnsureRange(LIniFile.ReadInteger('Calendar', 'Year',
      StartYear), StartYear, FinishYear);
    // Main
    Game.Map.MapSize := TMapSize(LIniFile.ReadInteger('Main', 'MapSize', 0));
    Game.Map.SeaLevel := TMapSeaLevel(LIniFile.ReadInteger('Main',
      'SeaLevel', 0));
    Game.Map.NoOfTowns := LIniFile.ReadInteger('Main', 'NoOfTowns', 1);
    Game.Map.Rivers := TMapRivers(LIniFile.ReadInteger('Main', 'Rivers', 0));
    Game.Map.NoOfInd := TMapNoOfInd(LIniFile.ReadInteger('Main', 'NoOfInd', 0));
    Game.Race := TRaceEnum(LIniFile.ReadInteger('Main', 'Race', 0));
    Game.Refresh;
  finally
    FreeAndNil(LIniFile);
  end;
end;

procedure TGame.SaveSettings;
var
  LIniFile: TMemIniFile;
begin
  LIniFile := TMemIniFile.Create(GetPath('') + 'Settings.ini', TEncoding.UTF8);
  try
    // Window
    LIniFile.WriteBool('Window', 'Fullscreen', Fullscreen);
    // Calendar
    LIniFile.WriteInteger('Calendar', 'Day', Game.Calendar.Day);
    LIniFile.WriteInteger('Calendar', 'Month', Game.Calendar.Month);
    LIniFile.WriteInteger('Calendar', 'Year', Game.Calendar.Year);
    // Main
    LIniFile.WriteInteger('Main', 'MapSize', Ord(Game.Map.MapSize));
    LIniFile.WriteInteger('Main', 'SeaLevel', Ord(Game.Map.SeaLevel));
    LIniFile.WriteInteger('Main', 'NoOfTowns', Game.Map.NoOfTowns);
    LIniFile.WriteInteger('Main', 'Rivers', Ord(Game.Map.Rivers));
    LIniFile.WriteInteger('Main', 'NoOfInd', Ord(Game.Map.NoOfInd));
    LIniFile.WriteInteger('Main', 'Race', Ord(Game.Race));
    LIniFile.UpdateFile;
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

procedure TGame.Refresh;
begin
  if Self.Fullscreen then
    terminal_set('window: fullscreen=true')
  else
    terminal_set('window: fullscreen=false');
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

procedure TGame.Load(const ASlot: Byte);
var
  LIniFile: TMemIniFile;
  LConstructEnum: TConstructEnum;
  LValue: Integer;
  LYear: Word;
  LStringList: TStringList;
  LJSON: TJSONValue;
  LConfig: INeonConfiguration;
begin
  LStringList := TStringList.Create;
  LStringList.WriteBOM := False;
  try
    LStringList.LoadFromFile(GetFileName(ASlot), TEncoding.UTF8);
    LJSON := TJSONObject.ParseJSONValue(LStringList.Text);
    try
      LConfig := TNeonConfiguration.Default;
      TNeon.JSONToObject(Self, LJSON, LConfig);
      ShowMessage('Loaded!');
    finally
      LJSON.Free;
    end;
  finally
    LStringList.Free;
  end;
  { Exit;
    LIniFile := TMemIniFile.Create(GetFileName(ASlot), TEncoding.UTF8);
    try
    // Company
    FCompany.TownIndex := LIniFile.ReadInteger('Company', 'TownIndex', 0);
    // Calendar
    FCalendar.Day := LIniFile.ReadInteger('Calendar', 'Day', 1);
    FCalendar.WeekDay := LIniFile.ReadInteger('Calendar', 'WeekDay', 1);
    FCalendar.Month := LIniFile.ReadInteger('Calendar', 'Month', 1);
    FCalendar.Year := LIniFile.ReadInteger('Calendar', 'Year', StartYear);
    // Game
    FTurn := LIniFile.ReadInteger('Game', 'Turn', 0);
    FLoan := LIniFile.ReadInteger('Game', 'Loan', StartMoney);
    FMoney := LIniFile.ReadInteger('Game', 'Money', StartMoney);
    FYear := LIniFile.ReadInteger('Game', 'Year', StartYear);
    // Statistics
    for LConstructEnum := Succ(Low(TConstructEnum)) to High(TConstructEnum) do
    begin
    if (TransportTycoon.Map.Construct[LConstructEnum].StatName <> '') then
    begin
    LValue := LIniFile.ReadInteger('Statistics',
    TransportTycoon.Map.Construct[LConstructEnum].StatName, 0);
    Game.Company.Stat.SetStat(LConstructEnum, LValue);
    end;
    end;
    // Finances
    Finances.Clear;
    for LYear := StartYear to FinishYear do
    begin
    // Income
    Game.Finances.SetValue(ttRoadVehicleIncome, LYear,
    LIniFile.ReadInteger(LYear.ToString, 'RoadVehicleIncome', 0));
    Game.Finances.SetValue(ttTrainIncome, LYear,
    LIniFile.ReadInteger(LYear.ToString, 'TrainIncome', 0));
    Game.Finances.SetValue(ttShipIncome, LYear,
    LIniFile.ReadInteger(LYear.ToString, 'ShipIncome', 0));
    Game.Finances.SetValue(ttAircraftIncome, LYear,
    LIniFile.ReadInteger(LYear.ToString, 'AircraftIncome', 0));
    // Running Costs
    Game.Finances.SetValue(ttRoadVehicleRunningCosts, LYear,
    LIniFile.ReadInteger(LYear.ToString, 'RoadVehicleRunningCosts', 0));
    Game.Finances.SetValue(ttTrainRunningCosts, LYear,
    LIniFile.ReadInteger(LYear.ToString, 'TrainRunningCosts', 0));
    Game.Finances.SetValue(ttShipRunningCosts, LYear,
    LIniFile.ReadInteger(LYear.ToString, 'ShipRunningCosts', 0));
    Game.Finances.SetValue(ttAircraftRunningCosts, LYear,
    LIniFile.ReadInteger(LYear.ToString, 'AircraftRunningCosts', 0));
    // Loan Interest
    Game.Finances.SetValue(ttLoanInterest, LYear,
    LIniFile.ReadInteger(LYear.ToString, 'LoanInterest', 0));
    Game.Finances.SetValue(ttConstruction, LYear,
    LIniFile.ReadInteger(LYear.ToString, 'Construction', 0));
    Game.Finances.SetValue(ttNewVehicles, LYear,
    LIniFile.ReadInteger(LYear.ToString, 'NewVehicles', 0));
    end;
    for LYear := FYear to FCalendar.Year do
    FFinances.SetYear(LYear);
    // Industries

    //
    //
    //
  }
  Scenes.SetScene(scOpenGameDoneMenu);
  { finally
    FreeAndNil(LIniFile);
    end; }
end;

procedure TGame.Save(const ASlot: Byte);
var
  LIniFile: TMemIniFile;
  LConstructEnum: TConstructEnum;
  LIndCount, LIndustry, LVehicle, LOrder: Integer;
  LIndustryName, LVehicleName, LOrderName: string;
  LYear: Word;
  LRace: TRaceEnum;
  LStringList: TStringList;
  LJSON: TJSONValue;
begin
  LStringList := TStringList.Create;
  LStringList.WriteBOM := False;
  try
    LJSON := TNeon.ObjectToJSON(Self);
    try
      LStringList.Text := TNeon.Print(LJSON, True);
      LStringList.SaveToFile(GetFileName(ASlot), TEncoding.UTF8);
      ShowMessage('Saved!');
    finally
      LJSON.Free;
    end;
  finally
    LStringList.Free;
  end;
  Exit;
  LIniFile := TMemIniFile.Create(GetFileName(ASlot), TEncoding.UTF8);
  try
    // Game
    LIniFile.WriteString('Game', 'Date', DateTimeToStr(Date));
    LIniFile.WriteInteger('Game', 'Turn', Game.Turn);
    LIniFile.WriteInteger('Game', 'Loan', Game.Loan);
    LIniFile.WriteInteger('Game', 'Money', Game.Money);
    LIniFile.WriteInteger('Game', 'Year', StartYear);
    // Calendar
    LIniFile.WriteInteger('Calendar', 'Day', Game.Calendar.Day);
    LIniFile.WriteInteger('Calendar', 'WeekDay', Game.Calendar.WeekDay);
    LIniFile.WriteInteger('Calendar', 'Month', Game.Calendar.Month);
    LIniFile.WriteInteger('Calendar', 'Year', Game.Calendar.Year);
    // Company
    LIniFile.WriteString('Company', 'Name', UpperCase(Game.Company.Name));
    LIniFile.WriteInteger('Company', 'TownIndex', Game.Company.TownIndex);
    // Statistics
    for LConstructEnum := Succ(Low(TConstructEnum)) to High(TConstructEnum) do
    begin
      if (Game.Company.Stat.GetStat(LConstructEnum) <> 0) and
        (TransportTycoon.Map.Construct[LConstructEnum].StatName <> '') then
      begin
        LIniFile.WriteInteger('Statistics', TransportTycoon.Map.Construct
          [LConstructEnum].StatName, Game.Company.Stat.GetStat(LConstructEnum));
      end;
    end;
    // Finances
    for LYear := StartYear to FinishYear do
    begin
      // Income
      LIniFile.WriteInteger(LYear.ToString, 'RoadVehicleIncome',
        Game.Finances.Value(ttRoadVehicleIncome, LYear));
      LIniFile.WriteInteger(LYear.ToString, 'TrainIncome',
        Game.Finances.Value(ttTrainIncome, LYear));
      LIniFile.WriteInteger(LYear.ToString, 'ShipIncome',
        Game.Finances.Value(ttShipIncome, LYear));
      LIniFile.WriteInteger(LYear.ToString, 'AircraftIncome',
        Game.Finances.Value(ttAircraftIncome, LYear));
      // Running Costs
      LIniFile.WriteInteger(LYear.ToString, 'RoadVehicleRunningCosts',
        Game.Finances.Value(ttRoadVehicleRunningCosts, LYear));
      LIniFile.WriteInteger(LYear.ToString, 'TrainRunningCosts',
        Game.Finances.Value(ttTrainRunningCosts, LYear));
      LIniFile.WriteInteger(LYear.ToString, 'ShipRunningCosts',
        Game.Finances.Value(ttShipRunningCosts, LYear));
      LIniFile.WriteInteger(LYear.ToString, 'AircraftRunningCosts',
        Game.Finances.Value(ttAircraftRunningCosts, LYear));
      // Loan Interest
      LIniFile.WriteInteger(LYear.ToString, 'LoanInterest',
        Game.Finances.Value(ttLoanInterest, LYear));
      LIniFile.WriteInteger(LYear.ToString, 'Construction',
        Game.Finances.Value(ttConstruction, LYear));
      LIniFile.WriteInteger(LYear.ToString, 'NewVehicles',
        Game.Finances.Value(ttNewVehicles, LYear));
    end;
    // Aircrafts
    for LVehicle := 0 to Vehicles.AircraftCount - 1 do
      with Vehicles do
      begin
        LVehicleName := 'Aircraft' + IntToStr(LVehicle + 1);
        with Aircraft[LVehicle] do
        begin
          LIniFile.WriteString(LVehicleName, 'Name', Name);
          LIniFile.WriteInteger(LVehicleName, 'X', X);
          LIniFile.WriteInteger(LVehicleName, 'Y', Y);
          LIniFile.WriteInteger(LVehicleName, 'AP', AP);
          LIniFile.WriteInteger(LVehicleName, 'MaxAP', MaxAP);
          LIniFile.WriteInteger(LVehicleName, 'Station', LastStationId);
          LIniFile.WriteInteger(LVehicleName, 'Vehicle', VehicleID);
          LIniFile.WriteInteger(LVehicleName, 'Profit', Profit);
          LIniFile.WriteInteger(LVehicleName, 'LastProfit', LastProfit);
          LIniFile.WriteInteger(LVehicleName, 'Cargo', CargoAmount);
          LIniFile.WriteInteger(LVehicleName, 'MaxCargo', MaxCargoAmount);
          with Aircraft[LVehicle].Orders do
          begin
            LIniFile.WriteInteger(LVehicleName, 'OrderIndex', OrderIndex);
            LIniFile.WriteInteger(LVehicleName, 'OrderCount', Count);
            for LOrder := 0 to Count - 1 do
            begin
              LOrderName := LVehicleName + 'Order' + IntToStr(LOrder + 1);
              LIniFile.WriteString(LOrderName, 'Name', Order[LOrder].Name);
              LIniFile.WriteInteger(LOrderName, 'X', Order[LOrder].X);
              LIniFile.WriteInteger(LOrderName, 'Y', Order[LOrder].Y);
            end;
          end;
        end;
      end;
    // Ships
    for LVehicle := 0 to Vehicles.ShipCount - 1 do
      with Vehicles do
      begin
        LVehicleName := 'Ship' + IntToStr(LVehicle + 1);
        with Ship[LVehicle] do
        begin
          LIniFile.WriteString(LVehicleName, 'Name', Name);
          LIniFile.WriteInteger(LVehicleName, 'X', X);
          LIniFile.WriteInteger(LVehicleName, 'Y', Y);
          LIniFile.WriteInteger(LVehicleName, 'AP', AP);
          LIniFile.WriteInteger(LVehicleName, 'MaxAP', MaxAP);
          LIniFile.WriteInteger(LVehicleName, 'Station', LastStationId);
          LIniFile.WriteInteger(LVehicleName, 'Vehicle', VehicleID);
          LIniFile.WriteInteger(LVehicleName, 'Profit', Profit);
          LIniFile.WriteInteger(LVehicleName, 'LastProfit', LastProfit);
          LIniFile.WriteInteger(LVehicleName, 'Cargo', CargoAmount);
          LIniFile.WriteInteger(LVehicleName, 'MaxCargo', MaxCargoAmount);
          with Orders do
          begin
            LIniFile.WriteInteger(LVehicleName, 'OrderIndex', OrderIndex);
            LIniFile.WriteInteger(LVehicleName, 'OrderCount', Count);
            for LOrder := 0 to Count - 1 do
            begin
              LOrderName := LVehicleName + 'Order' + IntToStr(LOrder + 1);
              LIniFile.WriteString(LOrderName, 'Name', Order[LOrder].Name);
              LIniFile.WriteInteger(LOrderName, 'X', Order[LOrder].X);
              LIniFile.WriteInteger(LOrderName, 'Y', Order[LOrder].Y);
            end;
          end;
        end;
      end;
    // Road Vehicles
    for LVehicle := 0 to Vehicles.RoadVehicleCount - 1 do
      with Vehicles do
      begin
        LVehicleName := 'RoadVehicle' + IntToStr(LVehicle + 1);
        with RoadVehicle[LVehicle] do
        begin
          LIniFile.WriteString(LVehicleName, 'Name', Name);
          LIniFile.WriteInteger(LVehicleName, 'X', X);
          LIniFile.WriteInteger(LVehicleName, 'Y', Y);
          LIniFile.WriteInteger(LVehicleName, 'AP', AP);
          LIniFile.WriteInteger(LVehicleName, 'MaxAP', MaxAP);
          LIniFile.WriteInteger(LVehicleName, 'Station', LastStationId);
          LIniFile.WriteInteger(LVehicleName, 'Vehicle', VehicleID);
          LIniFile.WriteInteger(LVehicleName, 'Profit', Profit);
          LIniFile.WriteInteger(LVehicleName, 'LastProfit', LastProfit);
          LIniFile.WriteInteger(LVehicleName, 'Cargo', CargoAmount);
          LIniFile.WriteInteger(LVehicleName, 'MaxCargo', MaxCargoAmount);
          with Orders do
          begin
            LIniFile.WriteInteger(LVehicleName, 'OrderIndex', OrderIndex);
            LIniFile.WriteInteger(LVehicleName, 'OrderCount', Count);
            for LOrder := 0 to Count - 1 do
            begin
              LOrderName := LVehicleName + 'Order' + IntToStr(LOrder + 1);
              LIniFile.WriteString(LOrderName, 'Name', Order[LOrder].Name);
              LIniFile.WriteInteger(LOrderName, 'X', Order[LOrder].X);
              LIniFile.WriteInteger(LOrderName, 'Y', Order[LOrder].Y);
            end;
          end;
        end;
      end;
    // Industries
    LIndCount := Length(Game.Map.Industry);
    LIniFile.WriteInteger('Industries', 'IndustriesCount', LIndCount);
    for LIndustry := 0 to LIndCount - 1 do
    begin
      LIndustryName := 'Industry' + IntToStr(LIndustry + 1);
      LIniFile.WriteString(LIndustryName, 'Name',
        Game.Map.Industry[LIndustry].Name);
      LIniFile.WriteInteger(LIndustryName, 'X', Game.Map.Industry[LIndustry].X);
      LIniFile.WriteInteger(LIndustryName, 'Y', Game.Map.Industry[LIndustry].Y);
      LIniFile.WriteString(LIndustryName, 'Type',
        IndustryTypeStr[Game.Map.Industry[LIndustry].IndustryType]);
      if Game.Map.Industry[LIndustry].IndustryType = inTown then
      begin
        LIniFile.WriteInteger(LIndustryName, 'Houses',
          TTownIndustry(Game.Map.Industry[LIndustry]).Houses);
        LIniFile.WriteInteger(LIndustryName, 'Population',
          TTownIndustry(Game.Map.Industry[LIndustry]).Population);
        LIniFile.WriteString(LIndustryName, 'Race',
          GameRaceStr[TTownIndustry(Game.Map.Industry[LIndustry]).TownRace]);
        for LRace := Low(TRaceEnum) to High(TRaceEnum) do
        begin
          LIniFile.WriteInteger(LIndustryName, GameRaceStr[LRace],
            TTownIndustry(Game.Map.Industry[LIndustry]).GetRacePop(LRace));
        end;
        LIniFile.WriteInteger(LIndustryName, 'Airport',
          TTownIndustry(Game.Map.Industry[LIndustry]).Airport.Level);
        LIniFile.WriteInteger(LIndustryName, 'Dock',
          TTownIndustry(Game.Map.Industry[LIndustry]).Dock.Level);
        LIniFile.WriteInteger(LIndustryName, 'BS',
          TTownIndustry(Game.Map.Industry[LIndustry]).BusStation.Level);
        LIniFile.WriteInteger(LIndustryName, 'TLB',
          TTownIndustry(Game.Map.Industry[LIndustry]).TruckLoadingBay.Level);
        LIniFile.WriteInteger(LIndustryName, 'HQ',
          TTownIndustry(Game.Map.Industry[LIndustry]).HQ.Level);
      end;
    end;
    //
    //
    //
    LIniFile.UpdateFile;
  finally
    FreeAndNil(LIniFile);
  end;
end;

procedure TGame.ForceDirs;
var
  LSlot: Integer;
begin
  ForceDirectories(GetPath('Saves'));
  for LSlot := 0 to 9 do
    ForceDirectories(GetPath(Format('Saves/%d', [LSlot])));
end;

procedure TGame.ScanSaveDir;
var
  LSlot: TSlot;
begin
  for LSlot := Low(TSlot) to High(TSlot) do
    if Game.IsSlotFileExists(LSlot) then
      FSlotStr[LSlot] := GetSlotName(LSlot)
    else
      FSlotStr[LSlot] := 'EMPTY SLOT';
end;

function TGame.IsSlotFileExists(const ASlot: Byte): Boolean;
begin
  Result := SysUtils.FileExists(GetFileName(ASlot));
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
  FYear := Calendar.Year;
  FCompany.Clear;
  FMap.Gen;
  FVehicles.Clear;
end;

end.
