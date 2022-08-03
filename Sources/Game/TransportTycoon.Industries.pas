unit TransportTycoon.Industries;

interface

uses
  TransportTycoon.MapObject,
  TransportTycoon.Stations,
  TransportTycoon.Cargo;

const
  AirportSizeStr: array [0 .. 5] of string = ('None', 'Small Airport',
    'Commuter Airport', 'City Airport', 'Metropolitan Airport',
    'International Airport');
  DockSizeStr: array [0 .. 1] of string = ('None', 'Dock');

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
    FAirport: TStation;
    FHQ: TStation;
    FBusStation: TStation;
    function GrowModif: Integer;
  public
    constructor Create(const AName: string; const AX, AY: Integer);
    destructor Destroy; override;
    property Population: Integer read FPopulation;
    property Houses: Word read FHouses;
    procedure ModifyPopulation(const APopulation: Integer);
    property Airport: TStation read FAirport;
    property BusStation: TStation read FBusStation;
    property HQ: TStation read FHQ;
    class function GenName: string;
    procedure Grows; override;
    function MaxCargo: Integer; override;
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
  SysUtils;

{ TIndustry }

constructor TIndustry.Create(const AName: string; const AX, AY: Integer);
var
  Cargo: TCargo;
begin
  inherited Create(AName, AX, AY);
  FIndustryType := inNone;
  FAccepts := [];
  FProduces := [];
  for Cargo := Succ(Low(TCargo)) to High(TCargo) do
  begin
    FAcceptsAmount[Cargo] := 0;
    FProducesAmount[Cargo] := 0;
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
  FTruckLoadingBay.Free;
  FDock.Free;
  inherited;
end;

function TIndustry.GetCargoStr(const ACargoSet: TCargoSet): string;
var
  Cargo: TCargo;
begin
  Result := '';
  for Cargo := Succ(Low(TCargo)) to High(TCargo) do
    if (Cargo in ACargoSet) then
      Result := Result + CargoStr[Cargo] + ' ';
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
  Cargo: TCargo;
begin
  if Dock.IsBuilding then
  begin
    for Cargo := Succ(Low(TCargo)) to High(TCargo) do
      if (Cargo in Produces) then
        IncProducesCargoAmount(Cargo, RandomRange(4, 6));
  end;
end;

{ TSecondaryIndustry }

procedure TSecondaryIndustry.Grows;
var
  AcceptsCargo, ProducesCargo: TCargo;
begin
  if Dock.IsBuilding then
  begin
    for AcceptsCargo := Succ(Low(TCargo)) to High(TCargo) do
      if (AcceptsCargo in Accepts) then
        for ProducesCargo := Succ(Low(TCargo)) to High(TCargo) do
          if (ProducesCargo in Produces) and (FAcceptsAmount[AcceptsCargo] > 0)
          then
          begin
            IncProducesCargoAmount(ProducesCargo, FAcceptsAmount[AcceptsCargo]);
            FAcceptsAmount[AcceptsCargo] := 0;
          end;
  end;
end;

{ TTownIndustry }

constructor TTownIndustry.Create(const AName: string; const AX, AY: Integer);
begin
  inherited Create(AName, AX, AY);
  FIndustryType := inTown;
  Accepts := [cgPassengers, cgMail, cgGoods];
  Produces := [cgPassengers, cgMail];
  FPopulation := 0;
  ModifyPopulation(Math.RandomRange(250, 1500));
  FAirport := TStation.Create(8000, 5);
  FBusStation := TStation.Create(250);
  FHQ := TStation.Create(250);
end;

destructor TTownIndustry.Destroy;
begin
  FHQ.Free;
  FBusStation.Free;
  FAirport.Free;
  inherited;
end;

class function TTownIndustry.GenName: string;
var
  S: array [0 .. 1] of TStringList;
  I: Integer;
begin
  for I := 0 to 1 do
    S[I] := TStringList.Create;
  S[0].DelimitedText :=
    '"Eding","Graning","Vorg","Tra","Nording","Agring","Gran","Funt","Grufing",'
    + '"Trening","Chend","Drinning","Long","Tor","Mar","Fin"';
  S[1].DelimitedText :=
    '"ville","burg","ley","ly","field","town","well","bell","bridge","ton",' +
    '"stone","hattan"';
  Result := '';
  for I := 0 to 1 do
  begin
    Result := Result + S[I][Random(S[I].Count - 1)];
    S[I].Free;
  end;
end;

procedure TTownIndustry.Grows;
var
  WeekPassengers: Integer;
  WeekMail: Integer;
begin
  if Math.RandomRange(0, 25) <= GrowModif then
    ModifyPopulation(Math.RandomRange(GrowModif * 8, GrowModif * 12));
  WeekPassengers := FPopulation div Math.RandomRange(10, 12);
  WeekMail := FPopulation div Math.RandomRange(40, 50);
  if Airport.IsBuilding or Dock.IsBuilding then
  begin
    SetCargoAmount(cgPassengers, WeekPassengers);
    SetCargoAmount(cgMail, WeekMail);
  end;
end;

function TTownIndustry.GrowModif: Integer;
begin
  Result := Airport.Level + Dock.Level { + Trainstation } + 5;
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
