unit TransportTycoon.Ship;

interface

uses
  TransportTycoon.Vehicle,
  TransportTycoon.Order,
  TransportTycoon.Cargo;

type
  TShipBase = record
    Name: string;
    Cargo: TCargoSet;
    Amount: Integer;
    Cost: Word;
    RunningCost: Word;
    Speed: Word;
    Since: Word;
  end;

const
  ShipBase: array [0 .. 1] of TShipBase = (
    // #1
    (Name: 'TM-22'; Cargo: [cgPassengers]; Amount: 90; Cost: 25000;
    RunningCost: 90 * 12; Speed: 50; Since: 1950),
    // #2
    (Name: 'MF Cargo Ship'; Cargo: [cgCoal, cgWood, cgGoods]; Amount: 120;
    Cost: 27000; RunningCost: 95 * 12; Speed: 50; Since: 1950)
    //
    );

type
  TShip = class(TVehicle)
  private
    FT: Integer;
    FDistance: Integer;
    FState: string;
    FLastAirportId: Integer;
    FOrderIndex: Integer;
    FCargoAmount: Integer;
    FCargoMaxAmount: Integer;
    FCargo: TCargoSet;
    FCargoType: TCargo;
  public
    Order: array of TOrder;
    constructor Create(const AName: string; const AX, AY, ID: Integer);
    function Move(const AX, AY: Integer): Boolean; override;
    property Distance: Integer read FDistance;
    property State: string read FState;
    property LastDockId: Integer write FLastAirportId;
    property OrderIndex: Integer read FOrderIndex;
    property Cargo: TCargoSet read FCargo;
    property CargoAmount: Integer read FCargoAmount;
    property CargoMaxAmount: Integer read FCargoMaxAmount;
    property CargoType: TCargo read FCargoType;
    procedure Step; override;
    procedure Load;
    procedure UnLoad;
    procedure AddOrder(const AIndex: Integer); overload;
    procedure AddOrder(const TownIndex: Integer; const AName: string;
      const AX, AY: Integer); overload;
    procedure DelOrder(const AIndex: Integer);
    function IsOrder(const AIndex: Integer): Boolean;
  end;

implementation

uses
  SysUtils,
  TransportTycoon.Map,
  TransportTycoon.Game,
  TransportTycoon.Finances,
  TransportTycoon.PathFind,
  TransportTycoon.Industries;

function IsPath(X, Y: Integer): Boolean; stdcall;
begin
  Result := Game.Map.Cell[X][Y] in [tlTownIndustry, tlWater, tlCanal] +
    IndustryTiles;
end;

procedure TShip.AddOrder(const TownIndex: Integer; const AName: string;
  const AX, AY: Integer);
begin
  if Game.Map.Industry[TownIndex].Dock.IsBuilding then
  begin
    SetLength(Order, Length(Order) + 1);
    Order[High(Order)].ID := TownIndex;
    Order[High(Order)].Name := AName;
    Order[High(Order)].X := AX;
    Order[High(Order)].Y := AY;
  end;
end;

procedure TShip.AddOrder(const AIndex: Integer);
begin
  with Game.Map.Industry[AIndex] do
    AddOrder(AIndex, Name, X, Y);
end;

constructor TShip.Create(const AName: string; const AX, AY, ID: Integer);
begin
  inherited Create(AName, AX, AY);
  FT := 0;
  FState := 'Wait';
  FOrderIndex := 0;
  LastDockId := 0;
  FDistance := 0;
  FCargoAmount := 0;
  FCargoMaxAmount := ShipBase[ID].Amount;
  FCargo := ShipBase[ID].Cargo;
  FCargoType := cgNone;
end;

procedure TShip.DelOrder(const AIndex: Integer);
var
  I: Integer;
begin
  if (Length(Order) > 1) then
  begin
    if AIndex > High(Order) then
      Exit;
    if AIndex < Low(Order) then
      Exit;
    if AIndex = High(Order) then
    begin
      SetLength(Order, Length(Order) - 1);
      Exit;
    end;
    for I := AIndex + 1 to Length(Order) - 1 do
      Order[I - 1] := Order[I];
    SetLength(Order, Length(Order) - 1);
  end;
end;

function TShip.IsOrder(const AIndex: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Length(Order) - 1 do
    if Order[I].ID = AIndex then
    begin
      Result := True;
      Exit;
    end;
end;

procedure TShip.Load;
var
  Cargo: TCargo;
begin
  FState := 'Load';
  for Cargo := Low(TCargo) to High(TCargo) do
    if (Cargo in Game.Map.Industry[Order[OrderIndex].ID]
      .Produces) and (Cargo in FCargo) then
    begin
      FCargoType := Cargo;
      while (Game.Map.Industry[Order[OrderIndex].ID].ProducesAmount[Cargo] > 0)
        and (FCargoAmount < FCargoMaxAmount) do
      begin
        Game.Map.Industry[Order[OrderIndex].ID].DecCargoAmount(Cargo);
        Inc(FCargoAmount);
      end;
      Exit;
    end;
end;

function TShip.Move(const AX, AY: Integer): Boolean;
var
  NX, NY: Integer;
begin
  Result := False;
  FState := 'Move';
  NX := 0;
  NY := 0;
  if not IsMove(Game.Map.Width, Game.Map.Height, X, Y, AX, AY, @IsPath, NX, NY)
  then
    Exit;
  SetLocation(NX, NY);
  Result := (X <> AX) or (Y <> AY);
end;

procedure TShip.Step;
begin
  if Length(Order) > 0 then
  begin
    if not Move(Order[OrderIndex].X, Order[OrderIndex].Y) then
    begin
      Inc(FT);
      if Order[OrderIndex].ID <> FLastAirportId then
        UnLoad;
      FState := 'Service';
      if FT > (15 - (Game.Map.Industry[Order[OrderIndex].ID].Dock.Level * 2))
      then
      begin
        FT := 0;
        Load;
        FOrderIndex := FOrderIndex + 1;
        if (OrderIndex > High(Order)) then
          FOrderIndex := 0;
      end;
    end
    else
      Inc(FDistance);
  end;
end;

procedure TShip.UnLoad;
var
  Money: Integer;
begin
  FState := 'Unload';
  LastDockId := Order[OrderIndex].ID;

  if (CargoType in Game.Map.Industry[Order[OrderIndex].ID].Accepts)
    and (CargoType <> cgNone) and (CargoAmount > 0) then
  begin
    Money := (FCargoAmount * (Distance div 10)) * CargoPrice[CargoType];
    Game.ModifyMoney(ttShipIncome, Money);
    FCargoAmount := 0;
    FCargoType := cgNone;
  end;

  FDistance := 0;
end;

end.
