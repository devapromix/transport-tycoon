unit TransportTycoon.Ship;

interface

uses
  TransportTycoon.Vehicle,
  TransportTycoon.Cargo;

const
  ShipBase: array [0 .. 2] of TVehicleBase = (
    // #1
    (Name: 'TM-22'; CargoSet: [cgPassengers]; Amount: 90; Cost: 25000;
    RunningCost: 90 * 12; Speed: 50; Since: 1950; VehicleType: vtShip;),
    // #2
    (Name: 'MF Cargo Ship'; CargoSet: [cgCoal, cgWood]; Amount: 120; Cost: 27000;
    RunningCost: 95 * 12; Speed: 50; Since: 1950; VehicleType: vtShip;),
    // #3
    (Name: 'TD-4 Cargo Ship'; CargoSet: [cgGoods]; Amount: 110; Cost: 28000;
    RunningCost: 97 * 12; Speed: 60; Since: 1955; VehicleType: vtShip;)
    //
    );

type

  { TShip }

  TShip = class(TVehicle)
  private
    FT: Integer;
    FState: string;
  public const
    Color: string = 'white';
  public
    constructor Create(const AName: string; const AX, AY, ID: Integer);
    function Move(const AX, AY: Integer): Boolean; override;
    property State: string read FState;
    procedure Step; override;
    procedure Load; override;
    procedure UnLoad; override;
    procedure AddOrder(const AIndex: Integer); overload;
  end;

implementation

uses
  SysUtils,
  TransportTycoon.Map,
  TransportTycoon.Game,
  TransportTycoon.Finances,
  TransportTycoon.PathFind,
  TransportTycoon.Industries;

{ TShip }

function IsPath(X, Y: Integer): Boolean; stdcall;
begin
  Result := Game.Map.IsShipPath(X, Y);
end;

procedure TShip.AddOrder(const AIndex: Integer);
begin
  with Game.Map.Industry[AIndex] do
    Orders.AddOrder(AIndex, Name, X, Y);
end;

constructor TShip.Create(const AName: string; const AX, AY, ID: Integer);
begin
  inherited Create(AName, AX, AY, ShipBase, ID);
  FT := 0;
  FState := 'Wait';
end;

procedure TShip.Load;
var
  Cargo: TCargo;
begin
  FState := 'Load';
  for Cargo := Succ(Low(TCargo)) to High(TCargo) do
    if (Cargo in Game.Map.Industry[CurOrder.ID].Produces) and (Cargo in CargoSet)
    then
    begin
      SetCargoType(Cargo);
      while (Game.Map.Industry[CurOrder.ID].ProducesAmount[Cargo] > 0) and
        (CargoAmount < CargoMaxAmount) do
      begin
        Game.Map.Industry[CurOrder.ID].DecCargoAmount(Cargo);
        IncCargoAmount;
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
var
  Cargo: TCargo;
begin
  if Orders.Count > 0 then
  begin
    if not Move(CurOrder.X, CurOrder.Y) then
    begin
      Inc(FT);
      if CurOrder.ID <> LastStationId then
        UnLoad;
      FState := 'Service';
      if FT > (15 - (Game.Map.Industry[CurOrder.ID].Dock.Level * 2)) then
      begin
        FT := 0;
        Load;
        if FullLoad then
          for Cargo := Succ(Low(TCargo)) to High(TCargo) do
            if (Cargo in Game.Map.Industry[CurOrder.ID].Produces) and
              (Cargo in CargoSet) then
            begin
              SetCargoType(Cargo);
              if (CargoAmount < CargoMaxAmount) then
                Exit;
            end;
        Orders.IncOrder;
      end
    end
    else
      IncDistance;
  end;
end;

procedure TShip.UnLoad;
var
  Money: Integer;
begin
  SetLastStation;
  FState := 'Unload';
  if (CargoType in Game.Map.Industry[CurOrder.ID].Accepts) and
    (CargoType <> cgNone) and (CargoAmount > 0) then
  begin
    Money := (CargoAmount * (Distance div 10)) * CargoPrice[CargoType];
    Game.Map.Industry[CurOrder.ID].IncAcceptsCargoAmount(CargoType,
      CargoAmount);
    Game.ModifyMoney(ttShipIncome, Money);
    Profit := Profit + Money;
    ClearCargo;
  end;
  Distance := 0;
end;

end.
