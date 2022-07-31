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
    procedure IncCargoAmount(const ACargo: TCargo; AValue: Integer = 1);
    property Dock: TDock read FDock;
    procedure Grows; virtual;
    function GetCargoStr(const ACargoSet: TCargoSet): string;
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
    procedure Grows; override;
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
  for Cargo := Succ(Low(TCargo)) to High(TCargo) do
  begin
    FAcceptsAmount[Cargo] := 0;
    FProducesAmount[Cargo] := 0;
  end;
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
  if Dock.IsBuilding then
  begin
    if (cgWood in Produces) then
      IncCargoAmount(cgWood, RandomRange(4, 6));
    if (cgCoal in Produces) then
      IncCargoAmount(cgCoal, RandomRange(4, 6));
    if (cgGoods in Produces) then
      IncCargoAmount(cgGoods, RandomRange(4, 6));
  end;
end;

procedure TIndustry.IncCargoAmount(const ACargo: TCargo; AValue: Integer);
begin
  FProducesAmount[ACargo] := FProducesAmount[ACargo] + AValue;
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

procedure TSawmillIndustry.Grows;
begin
  if Dock.IsBuilding then
  begin
    if (cgWood in Accepts) and (cgGoods in Produces) then
    begin
      IncCargoAmount(cgGoods, FAcceptsAmount[cgWood]);
      FAcceptsAmount[cgWood] := 0;
    end;
  end;
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
