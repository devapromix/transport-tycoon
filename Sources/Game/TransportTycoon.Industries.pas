unit TransportTycoon.Industries;

interface

uses
  TransportTycoon.MapObject,
  TransportTycoon.Stations;

const
  AirportSizeStr: array [0 .. 5] of string = ('None', 'Small Airport',
    'Commuter Airport', 'City Airport', 'Metropolitan Airport',
    'International Airport');
  DockSizeStr: array [0 .. 1] of string = ('None', 'Dock');

type
  TCargo = (cgPassengers, cgMail, cgGoods, cgCoal, cgWood);

const
  CargoStr: array [TCargo] of string = ('Passengers', 'Mail', 'Goods',
    'Coal', 'Wood');

type
  TCargoAmount = array [TCargo] of Integer;

type
  TCargoSet = set of TCargo;

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
    FAccepts: TCargoSet;
    FDock: TDock;
  public
    constructor Create(const AName: string; const AX, AY: Integer);
    destructor Destroy; override;
    property Accepts: TCargoSet read FAccepts write FAccepts;
    property Produces: TCargoSet read FProduces write FProduces;
    property ProducesAmount: TCargoAmount read FProducesAmount;
    property IndustryType: TIndustryType read FIndustryType;
    procedure SetCargoAmount(const ACargo: TCargo; const AAmount: Integer);
    procedure DecCargoAmount(const ACargo: TCargo);
    property Dock: TDock read FDock;
    procedure Grows; virtual;
  end;

type

  { TTownIndustry }

  TTownIndustry = class(TIndustry)
  private
    FHouses: Word;
    FPopulation: Integer;
    FAirport: TStation;
    FHQ: TStation;
    function GrowModif: Integer;
  public
    constructor Create(const AName: string; const AX, AY: Integer);
    destructor Destroy; override;
    property Population: Integer read FPopulation;
    property Houses: Word read FHouses;
    procedure ModifyPopulation(const APopulation: Integer);
    property Airport: TStation read FAirport;
    property HQ: TStation read FHQ;
    class function GenName: string;
    procedure Grows; override;
  end;

type

  { TForestIndustry }

  TForestIndustry = class(TIndustry)
  private
  public
    constructor Create(const AName: string; const AX, AY: Integer);
  end;

type

  { TSawmillIndustry }

  TSawmillIndustry = class(TIndustry)
  private
  public
    constructor Create(const AName: string; const AX, AY: Integer);
  end;

type

  { TCoalMineIndustry }

  TCoalMineIndustry = class(TIndustry)
  private
  public
    constructor Create(const AName: string; const AX, AY: Integer);
  end;

type

  { TPowerPlantIndustry }

  TPowerPlantIndustry = class(TIndustry)
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
  for Cargo := Low(TCargo) to High(TCargo) do
    FProducesAmount[Cargo] := 0;
  FDock := TDock.Create(9000);
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
  FDock.Free;
  inherited;
end;

procedure TIndustry.Grows;
begin
  if Dock.HasBuilding then
  begin
    if (cgWood in Produces) then
      SetCargoAmount(cgWood, RandomRange(15, 18));
    if (cgCoal in Produces) then
      SetCargoAmount(cgCoal, RandomRange(15, 18));
    if (cgGoods in Produces) then
      SetCargoAmount(cgGoods, RandomRange(15, 18));
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
  FHQ := TStation.Create(250);
end;

destructor TTownIndustry.Destroy;
begin
  FHQ.Free;
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
    + '"Trening","Chend","Drinning","Long","Tor","Mar"';
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
  MonthPassengers: Integer;
  MonthMail: Integer;
begin
  if Math.RandomRange(0, 25) <= GrowModif then
    ModifyPopulation(Math.RandomRange(GrowModif * 8, GrowModif * 12));
  MonthPassengers := FPopulation div Math.RandomRange(40, 50);
  MonthMail := FPopulation div Math.RandomRange(160, 190);
  if Airport.HasBuilding or Dock.HasBuilding then
  begin
    SetCargoAmount(cgPassengers, MonthPassengers);
    SetCargoAmount(cgMail, MonthMail);
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
