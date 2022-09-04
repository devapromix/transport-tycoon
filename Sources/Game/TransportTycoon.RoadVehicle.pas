unit TransportTycoon.RoadVehicle;

interface

uses
  TransportTycoon.Vehicle,
  TransportTycoon.Cargo;

const
  RoadVehicleBase: array [0 .. 4] of TVehicleBase = (
    // #1
    (Name: 'TG Perry Bus'; CargoSet: [cgPassengers]; Amount: 27; Cost: 4000;
    RunningCost: 18 * 12; Speed: 60; Since: 1950; VehicleType: vtBus;),
    // #2
    (Name: 'JK-5 Mail Truck'; CargoSet: [cgMail]; Amount: 7; Cost: 3500;
    RunningCost: 14 * 12; Speed: 60; Since: 1950; VehicleType: vtTruck;),
    // #3
    (Name: 'DR-2 Coal Truck'; CargoSet: [cgCoal]; Amount: 9; Cost: 4800;
    RunningCost: 18 * 12; Speed: 60; Since: 1950; VehicleType: vtTruck;),
    // #4
    (Name: 'ASV-11 Wood Truck'; CargoSet: [cgWood]; Amount: 9; Cost: 5000;
    RunningCost: 19 * 12; Speed: 60; Since: 1950; VehicleType: vtTruck;),
    // #5
    (Name: 'RT Goods Truck'; CargoSet: [cgGoods]; Amount: 9; Cost: 4500;
    RunningCost: 20 * 12; Speed: 60; Since: 1950; VehicleType: vtTruck;)
    //
    );

type

  { TRoadVehicle }

  TRoadVehicle = class(TVehicle)
  private
    FTimer: Integer;
    FState: string;
  public const
    Color: string = 'light red';
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
  TransportTycoon.Industries,
  TransportTycoon.Stations;

{ TRoadVehicle }

function IsPath(AX, AY: Integer): Boolean; stdcall;
begin
  Result := Game.Map.IsRoadVehiclePath(AX, AY);
end;

procedure TRoadVehicle.AddOrder(const AIndex: Integer);
begin
  with Game.Map.Industry[AIndex] do
    Orders.AddOrder(AIndex, Name, X, Y);
end;

constructor TRoadVehicle.Create(const AName: string;
  const AX, AY, AIndex: Integer);
begin
  inherited Create(AName, AX, AY, RoadVehicleBase, AIndex);
  FTimer := 0;
  FState := 'Wait';
end;

procedure TRoadVehicle.Load;
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

function TRoadVehicle.Move(const AX, AY: Integer): Boolean;
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

procedure TRoadVehicle.Step;
var
  LCargo: TCargo;
  LStation: TStation;
begin
  if Orders.Count > 0 then
  begin
    if not Move(CurOrder.X, CurOrder.Y) then
    begin
      Inc(FTimer);
      if CurOrder.IndustryIndex <> LastStationId then
        UnLoad;
      case CargoType of
        cgPassengers:
          LStation := TTownIndustry(Game.Map.Industry[CurOrder.IndustryIndex]).BusStation;
      else
        LStation := Game.Map.Industry[CurOrder.IndustryIndex].TruckLoadingBay;
      end;
      FState := 'Service';
      if FTimer > (15 - (LStation.Level * 2)) then
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

procedure TRoadVehicle.UnLoad;
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
    Game.ModifyMoney(ttRoadVehicleIncome, LMoney);
    Profit := Profit + LMoney;
    ClearCargo;
  end;
  Distance := 0;
end;

end.
