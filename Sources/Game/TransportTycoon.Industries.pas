unit TransportTycoon.Industries;

interface

uses
  TransportTycoon.MapObject,
  TransportTycoon.Stations;

type
  TCargo = (cgPassengers, cgBagsOfMail, cgGoods, cgCoal, cgWood);

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
  end;

type

  { TTownIndustry }

  TTownIndustry = class(TIndustry)
  private
    FHouses: Word;
    FPopulation: Integer;
    FAirport: TStation;
    FHQ: TStation;
  public
    constructor Create(const AName: string; const AX, AY: Integer);
    destructor Destroy; override;
    property Population: Integer read FPopulation;
    property Houses: Word read FHouses;
    procedure ModifyPopulation(const APopulation: Integer);
    property Airport: TStation read FAirport;
    property HQ: TStation read FHQ;
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

{ TTownIndustry }

constructor TTownIndustry.Create(const AName: string; const AX, AY: Integer);
begin
  inherited Create(AName, AX, AY);
  FIndustryType := inTown;
  Accepts := [cgPassengers, cgBagsOfMail, cgGoods];
  Produces := [cgPassengers, cgBagsOfMail];
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
