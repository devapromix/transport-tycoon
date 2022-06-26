unit TransportTycoon.Industries;

interface

uses
  TransportTycoon.MapObject;

type
  TCargo = (cgPassengers, cgBagsOfMail, cgGoods, cgCoal, cgWood);

type
  TCargoAmount = array [TCargo] of Integer;

type
  TCargoSet = set of TCargo;

type
  TIndustryType = (inNone, inCoalMine, inPowerPlant, inForest, inSawmill);

type

  { TIndustry }

  TIndustry = class(TMapObject)
  private
    FIndustryType: TIndustryType;
    FProducesAmount: TCargoAmount;
    FProduces: TCargoSet;
    FAccepts: TCargoSet;
  public
    constructor Create(const AName: string; const AX, AY: Integer);
    property Accepts: TCargoSet read FAccepts write FAccepts;
    property Produces: TCargoSet read FProduces write FProduces;
    property ProducesAmount: TCargoAmount read FProducesAmount;
    property IndustryType: TIndustryType read FIndustryType;
    procedure SetCargoAmount(const ACargo: TCargo; const AAmount: Integer);
    procedure DecCargoAmount(const ACargo: TCargo);
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
end;

procedure TIndustry.SetCargoAmount(const ACargo: TCargo; const AAmount: Integer
  );
begin
  FProducesAmount[ACargo] := AAmount;
end;

procedure TIndustry.DecCargoAmount(const ACargo: TCargo);
begin
  if FProducesAmount[ACargo] > 0 then
    FProducesAmount[ACargo] := FProducesAmount[ACargo] - 1;
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
