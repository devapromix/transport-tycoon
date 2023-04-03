unit TransportTycoon.Industries;

interface

uses
  TransportTycoon.MapObject,
  TransportTycoon.Stations,
  TransportTycoon.Races,
  TransportTycoon.Cargo;

const
  AirportSizeStr: array [1 .. 5] of string = ('Small Airport',
    'Commuter Airport', 'City Airport', 'Metropolitan Airport',
    'International Airport');

type
  TIndustryType = (inNone, inTown, inCoalMine, inPowerPlant, inForest,
    inSawmill);

type

  { TIndustry }

  TIndustry = class(TMapObject)
  private
    FIndustryType: TIndustryType;
    FProducesAmount: TCargoAmount;
    FProduces: TCargoSet;
    FAcceptsAmount: TCargoAmount;
    FAccepts: TCargoSet;
    FDock: TDock;
    FTruckLoadingBay: TStation;
  public
    constructor Create(const AName: string; const AX, AY: Integer);
    destructor Destroy; override;
    property Accepts: TCargoSet read FAccepts write FAccepts;
    property Produces: TCargoSet read FProduces write FProduces;
    property AcceptsAmount: TCargoAmount read FAcceptsAmount;
    property ProducesAmount: TCargoAmount read FProducesAmount;
    property IndustryType: TIndustryType read FIndustryType;
    procedure SetCargoAmount(const ACargo: TCargo; const AAmount: Integer);
    procedure DecCargoAmount(const ACargo: TCargo);
    procedure IncProducesCargoAmount(const ACargo: TCargo; AValue: Integer = 1);
    procedure IncAcceptsCargoAmount(const ACargo: TCargo; AValue: Integer = 1);
    property Dock: TDock read FDock;
    property TruckLoadingBay: TStation read FTruckLoadingBay;
    procedure Grows; virtual;
    function MaxCargo: Integer; virtual;
    function GetCargoStr(const ACargoSet: TCargoSet): string;
  end;

type

  { TPrimaryIndustry }

  TPrimaryIndustry = class(TIndustry)
    procedure Grows; override;
  end;

type

  { TSecondaryIndustry }

  TSecondaryIndustry = class(TIndustry)
    procedure Grows; override;
  end;

type

  { TTownIndustry }

  TTownIndustry = class(TPrimaryIndustry)
  private
    FHouses: Word;
    FPopulation: Integer;
    FRacePop: array [TRaceEnum] of Byte;
    FAirport: TStation;
    FHQ: TStation;
    FBusStation: TStation;
    function GrowModif: Integer;
    procedure GenRacePop(const ATownRace: TRaceEnum);
  public
    constructor Create(const ATownRace: TRaceEnum; const AX, AY: Integer);
    destructor Destroy; override;
    property Population: Integer read FPopulation;
    property Houses: Word read FHouses;
    procedure ModifyPopulation(const APopulation: Integer);
    property Airport: TStation read FAirport;
    property BusStation: TStation read FBusStation;
    property HQ: TStation read FHQ;
    class function GenName(const ATownRace: TRaceEnum): string;
    procedure Grows; override;
    function MaxCargo: Integer; override;
    function GetRacePop(const ARaceEnum: TRaceEnum): Byte;
  end;

type

  { TForestIndustry }

  TForestIndustry = class(TPrimaryIndustry)
  private
  public
    constructor Create(const AName: string; const AX, AY: Integer);
  end;

type

  { TSawmillIndustry }

  TSawmillIndustry = class(TSecondaryIndustry)
  private
  public
    constructor Create(const AName: string; const AX, AY: Integer);
  end;

type

  { TCoalMineIndustry }

  TCoalMineIndustry = class(TPrimaryIndustry)
  private
  public
    constructor Create(const AName: string; const AX, AY: Integer);
  end;

type

  { TPowerPlantIndustry }

  TPowerPlantIndustry = class(TPrimaryIndustry)
  private
  public
    constructor Create(const AName: string; const AX, AY: Integer);
  end;

implementation

uses
  Math,
  Classes,
  SysUtils,
  TransportTycoon.Game;

{ TIndustry }

constructor TIndustry.Create(const AName: string; const AX, AY: Integer);
var
  LCargo: TCargo;
begin
  inherited Create(AName, AX, AY);
  FIndustryType := inNone;
  FAccepts := [];
  FProduces := [];
  for LCargo := Succ(Low(TCargo)) to High(TCargo) do
  begin
    FAcceptsAmount[LCargo] := 0;
    FProducesAmount[LCargo] := 0;
  end;
  FDock := TDock.Create(9000);
  FTruckLoadingBay := TStation.Create(300);
end;

procedure TIndustry.SetCargoAmount(const ACargo: TCargo;
  const AAmount: Integer);
begin
  FProducesAmount[ACargo] := AAmount;
end;

procedure TIndustry.DecCargoAmount(const ACargo: TCargo);
begin
  if FProducesAmount[ACargo] > 0 then
    FProducesAmount[ACargo] := FProducesAmount[ACargo] - 1;
end;

destructor TIndustry.Destroy;
begin
  FreeAndNil(FTruckLoadingBay);
  FreeAndNil(FDock);
  inherited;
end;

function TIndustry.GetCargoStr(const ACargoSet: TCargoSet): string;
var
  LCargo: TCargo;
begin
  Result := '';
  for LCargo := Succ(Low(TCargo)) to High(TCargo) do
    if (LCargo in ACargoSet) then
      Result := Result + CargoStr[LCargo] + ' ';
  Result := Trim(Result);
  Result := StringReplace(Result, ' ', ', ', [rfReplaceAll]);
end;

procedure TIndustry.Grows;
begin

end;

procedure TIndustry.IncAcceptsCargoAmount(const ACargo: TCargo;
  AValue: Integer);
begin
  FAcceptsAmount[ACargo] := FAcceptsAmount[ACargo] + AValue;
  if FAcceptsAmount[ACargo] > MaxCargo then
    FAcceptsAmount[ACargo] := MaxCargo;
end;

procedure TIndustry.IncProducesCargoAmount(const ACargo: TCargo;
  AValue: Integer);
begin
  FProducesAmount[ACargo] := FProducesAmount[ACargo] + AValue;
  if FProducesAmount[ACargo] > MaxCargo then
    FProducesAmount[ACargo] := MaxCargo;
end;

function TIndustry.MaxCargo: Integer;
begin
  Result := 100;
end;

{ TPrimaryIndustry }

procedure TPrimaryIndustry.Grows;
var
  LCargo: TCargo;
begin
  if Dock.IsBuilding or TruckLoadingBay.IsBuilding then
  begin
    for LCargo := Succ(Low(TCargo)) to High(TCargo) do
      if (LCargo in Produces) then
        IncProducesCargoAmount(LCargo, RandomRange(4, 6));
  end;
end;

{ TSecondaryIndustry }

procedure TSecondaryIndustry.Grows;
var
  LAcceptsCargo, LProducesCargo: TCargo;
begin
  if Dock.IsBuilding or TruckLoadingBay.IsBuilding then
  begin
    for LAcceptsCargo := Succ(Low(TCargo)) to High(TCargo) do
      if (LAcceptsCargo in Accepts) then
        for LProducesCargo := Succ(Low(TCargo)) to High(TCargo) do
          if (LProducesCargo in Produces) and (FAcceptsAmount[LAcceptsCargo] > 0)
          then
          begin
            IncProducesCargoAmount(LProducesCargo,
              FAcceptsAmount[LAcceptsCargo]);
            FAcceptsAmount[LAcceptsCargo] := 0;
          end;
  end;
end;

{ TTownIndustry }

constructor TTownIndustry.Create(const ATownRace: TRaceEnum;
  const AX, AY: Integer);
var
  LTownName: string;
begin
  GenRacePop(ATownRace);
  LTownName := Self.GenName(ATownRace);
  inherited Create(LTownName, AX, AY);
  FIndustryType := inTown;
  Accepts := [cgPassengers, cgMail, cgGoods];
  Produces := [cgPassengers, cgMail];
  FPopulation := 0;
  //
  ModifyPopulation(Math.RandomRange(250, 1500));
  FAirport := TStation.Create(8000, 5);
  FBusStation := TStation.Create(250);
  FHQ := TStation.Create(250);
end;

destructor TTownIndustry.Destroy;
begin
  FreeAndNil(FHQ);
  FreeAndNil(FBusStation);
  FreeAndNil(FAirport);
  inherited;
end;

class function TTownIndustry.GenName(const ATownRace: TRaceEnum): string;
var
  LStringList: array [0 .. 1] of TStringList;
  I: Integer;
begin
  for I := 0 to 1 do
    LStringList[I] := TStringList.Create;
  LStringList[0].DelimitedText :=
    '"Eding","Graning","Vorg","Tra","Nording","Agring","Gran","Funt","Grufing",'
    + '"Trening","Chend","Drinning","Long","Tor","Mar","Fin"';
  LStringList[1].DelimitedText :=
    '"ville","burg","ley","ly","field","town","well","bell","bridge","ton",' +
    '"stone","hattan"';
  Result := '';
  for I := 0 to 1 do
  begin
    Result := Result + LStringList[I][Random(LStringList[I].Count - 1)];
    FreeAndNil(LStringList[I]);
  end;
end;

function TTownIndustry.GetRacePop(const ARaceEnum: TRaceEnum): Byte;
begin
  Result := FRacePop[ARaceEnum];
end;

procedure TTownIndustry.GenRacePop(const ATownRace: TRaceEnum);
begin
  repeat
    case ATownRace of
      reHuman:
        begin
          FRacePop[reHuman] := (Math.RandomRange(1, 5) * 5) + 50;
          FRacePop[reDwarf] := Math.RandomRange(2, 5) * 5;
          FRacePop[reElf] := 100 - (FRacePop[reHuman] + FRacePop[reDwarf]);
        end;
      reDwarf:
        begin
          FRacePop[reDwarf] := (Math.RandomRange(1, 5) * 5) + 50;
          FRacePop[reHuman] := Math.RandomRange(2, 5) * 5;
          FRacePop[reElf] := 100 - (FRacePop[reDwarf] + FRacePop[reHuman]);
        end;
      reElf:
        begin
          FRacePop[reElf] := (Math.RandomRange(1, 5) * 5) + 50;
          FRacePop[reHuman] := Math.RandomRange(2, 5) * 5;
          FRacePop[reDwarf] := 100 - (FRacePop[reElf] + FRacePop[reHuman]);
        end;
    end;
  until ((FRacePop[reHuman] <> FRacePop[reDwarf]) and
    (FRacePop[reDwarf] <> FRacePop[reElf]) and
    (FRacePop[reHuman] <> FRacePop[reElf]));
end;

procedure TTownIndustry.Grows;
var
  LWeekPassengers: Integer;
  LWeekMail: Integer;
begin
  if Math.RandomRange(0, 25) <= GrowModif then
    ModifyPopulation(Math.RandomRange(GrowModif * 8, GrowModif * 12));
  if Airport.IsBuilding or Dock.IsBuilding or BusStation.IsBuilding then
  begin
    LWeekPassengers := FPopulation div Math.RandomRange(10, 12);
    SetCargoAmount(cgPassengers, LWeekPassengers);
  end;
  if Airport.IsBuilding or Dock.IsBuilding or TruckLoadingBay.IsBuilding then
  begin
    LWeekMail := FPopulation div Math.RandomRange(40, 50);
    SetCargoAmount(cgMail, LWeekMail);
  end;
end;

function TTownIndustry.GrowModif: Integer;
begin
  Result := Airport.Level + Dock.Level +
    BusStation.Level { + Trainstation } + 5;
end;

procedure TTownIndustry.ModifyPopulation(const APopulation: Integer);
begin
  FPopulation := FPopulation + APopulation;
  FHouses := FPopulation div 30;
end;

function TTownIndustry.MaxCargo: Integer;
begin
  Result := FHouses * 7;
end;

{ TForestIndustry }

constructor TForestIndustry.Create(const AName: string; const AX, AY: Integer);
begin
  inherited Create(Trim(AName + ' Forest'), AX, AY);
  FIndustryType := inForest;
  FProduces := [cgWood];
end;

{ TSawmillIndustry }

constructor TSawmillIndustry.Create(const AName: string; const AX, AY: Integer);
begin
  inherited Create(Trim(AName + ' Sawmill'), AX, AY);
  FIndustryType := inSawmill;
  FAccepts := [cgWood];
  FProduces := [cgGoods];
end;

{ TCoalMineIndustry }

constructor TCoalMineIndustry.Create(const AName: string;
  const AX, AY: Integer);
begin
  inherited Create(Trim(AName + ' Coal Mine'), AX, AY);
  FIndustryType := inCoalMine;
  FProduces := [cgCoal];
end;

{ TPowerPlantIndustry }

constructor TPowerPlantIndustry.Create(const AName: string;
  const AX, AY: Integer);
begin
  inherited Create(Trim(AName + ' Power Plant'), AX, AY);
  FIndustryType := inPowerPlant;
  FAccepts := [cgCoal];
end;

end.
