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
    (Name: 'MF Cargo Ship'; CargoSet: [cgCoal, cgWood]; Amount: 120;
    Cost: 27000; RunningCost: 95 * 12; Speed: 50; Since: 1950;
    VehicleType: vtShip;),
    // #3
    (Name: 'TD-4 Cargo Ship'; CargoSet: [cgGoods]; Amount: 110; Cost: 28000;
    RunningCost: 97 * 12; Speed: 60; Since: 1955; VehicleType: vtShip;)
    //
    );

type

  { TShip }

  TShip = class(TVehicle)
  private
    FTimer: Integer;
    FState: string;
  public const
    Color: string = 'white';
  public
    constructor Create(const AName: string; const AX, AY, AIndex: Integer);
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

function IsPath(AX, AY: Integer): Boolean; stdcall;
begin
  Result := Game.Map.IsShipPath(AX, AY);
end;

procedure TShip.AddOrder(const AIndex: Integer);
begin
  with Game.Map.Industry[AIndex] do
    Orders.AddOrder(AIndex, Name, X, Y);
end;

constructor TShip.Create(const AName: string; const AX, AY, AIndex: Integer);
begin
  inherited Create(AName, AX, AY, ShipBase, AIndex);
  FTimer := 0;
  FState := 'Wait';
end;

procedure TShip.Load;
var
  LCargo: TCargo;
begin
  FState := 'Load';
  for LCargo := Succ(Low(TCargo)) to High(TCargo) do
    if (LCargo in Game.Map.Industry[CurOrder.IndustryIndex].Produces) and
      (LCargo in CargoSet) then
    begin
      SetCargoType(LCargo);
      while (Game.Map.Industry[CurOrder.IndustryIndex].ProducesAmount[LCargo] > 0) and
        (CargoAmount < CargoMaxAmount) do
      begin
        Game.Map.Industry[CurOrder.IndustryIndex].DecCargoAmount(LCargo);
        IncCargoAmount;
      end;
      Exit;
    end;
end;

function TShip.Move(const AX, AY: Integer): Boolean;
var
  LX, LY: Integer;
begin
  Result := False;
  FState := 'Move';
  LX := 0;
  LY := 0;
  if not IsMove(Game.Map.Width, Game.Map.Height, X, Y, AX, AY, @IsPath, LX, LY)
  then
    Exit;
  SetLocation(LX, LY);
  Result := (X <> AX) or (Y <> AY);
end;

procedure TShip.Step;
var
  LCargo: TCargo;
begin
  if Orders.Count > 0 then
  begin
    if not Move(CurOrder.X, CurOrder.Y) then
    begin
      Inc(FTimer);
      if CurOrder.IndustryIndex <> LastStationId then
        UnLoad;
      FState := 'Service';
      if FTimer > (15 - (Game.Map.Industry[CurOrder.IndustryIndex].Dock.Level * 2)) then
      begin
        FTimer := 0;
        Load;
        if FullLoad then
          for LCargo := Succ(Low(TCargo)) to High(TCargo) do
            if (LCargo in Game.Map.Industry[CurOrder.IndustryIndex].Produces) and
              (LCargo in CargoSet) then
            begin
              SetCargoType(LCargo);
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
  LMoney: Integer;
begin
  SetLastStation;
  FState := 'Unload';
  if (CargoType in Game.Map.Industry[CurOrder.IndustryIndex].Accepts) and
    (CargoType <> cgNone) and (CargoAmount > 0) then
  begin
    LMoney := (CargoAmount * (Distance div 10)) * CargoPrice[CargoType];
    Game.Map.Industry[CurOrder.IndustryIndex].IncAcceptsCargoAmount(CargoType,
      CargoAmount);
    Game.ModifyMoney(ttShipIncome, LMoney);
    Profit := Profit + LMoney;
    ClearCargo;
  end;
  Distance := 0;
end;

end.
