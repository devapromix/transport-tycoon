unit TransportTycoon.Industries;

interface

uses
  TransportTycoon.MapObject;

type
  TCargo = (cgNone, cgGoods, cgCoal, cgWood);

type
  TIndustryType = (inNone, inCoalMine, inPowerPlant, inForest, inSawmill);

type

  { TIndustry }

  TIndustry = class(TMapObject)
  private
    FIndustryType: TIndustryType;
    FProducesAmount: Integer;
    FProduces: TCargo;
    FAccepts: TCargo;
  public
    constructor Create(const AName: string; const AX, AY: Integer);
    property Accepts: TCargo read FAccepts;
    property Produces: TCargo read FProduces;
    property ProducesAmount: Integer read FProducesAmount;
    property IndustryType: TIndustryType read FIndustryType;
  end;

type

  { TForestIndustry }

  TForestIndustry = class(TIndustry)
  private
  public
    constructor Create(const AX, AY: Integer);
  end;

type

  { TSawmillIndustry }

  TSawmillIndustry = class(TIndustry)
  private
  public
    constructor Create(const AX, AY: Integer);
  end;

type

  { TCoalMineIndustry }

  TCoalMineIndustry = class(TIndustry)
  private
  public
    constructor Create(const AX, AY: Integer);
  end;

type

  { TPowerPlantIndustry }

  TPowerPlantIndustry = class(TIndustry)
  private
  public
    constructor Create(const AX, AY: Integer);
  end;

implementation

uses
  SysUtils;

{ TIndustry }

constructor TIndustry.Create(const AName: string; const AX, AY: Integer);
begin
  inherited Create(AName, AX, AY);
  FIndustryType := inNone;
  FAccepts := cgNone;
  FProduces := cgNone;
  FProducesAmount := 0;
end;

{ TForestIndustry }

constructor TForestIndustry.Create(const AX, AY: Integer);
begin
  inherited Create('Forest', AX, AY);
  FIndustryType := inForest;
  FProduces := cgWood;
end;

{ TSawmillIndustry }

constructor TSawmillIndustry.Create(const AX, AY: Integer);
begin
  inherited Create('Sawmill', AX, AY);
  FIndustryType := inSawmill;
  FAccepts := cgWood;
  FProduces := cgGoods;
end;

{ TCoalMineIndustry }

constructor TCoalMineIndustry.Create(const AX, AY: Integer);
begin
  inherited Create('Coal Mine', AX, AY);
  FIndustryType := inCoalMine;
  FProduces := cgCoal;
end;

{ TPowerPlantIndustry }

constructor TPowerPlantIndustry.Create(const AX, AY: Integer);
begin
  inherited Create('Power Plant', AX, AY);
  FIndustryType := inPowerPlant;
  FAccepts := cgCoal;
end;

end.
