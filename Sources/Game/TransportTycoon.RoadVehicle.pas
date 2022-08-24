unit TransportTycoon.RoadVehicle;

interface

uses
  TransportTycoon.Vehicle,
  TransportTycoon.Cargo;

const
  RoadVehicleBase: array [0 .. 4] of TVehicleBase = (
    // #1
    (Name: 'TG Perry Bus'; Cargo: [cgPassengers]; Amount: 27; Cost: 4000;
    RunningCost: 18 * 12; Speed: 60; Since: 1950; VehicleType: vtBus;),
    // #2
    (Name: 'JK-5 Mail Truck'; Cargo: [cgMail]; Amount: 7; Cost: 3500;
    RunningCost: 14 * 12; Speed: 60; Since: 1950; VehicleType: vtTruck;),
    // #3
    (Name: 'DR-2 Coal Truck'; Cargo: [cgCoal]; Amount: 9; Cost: 4800;
    RunningCost: 18 * 12; Speed: 60; Since: 1950; VehicleType: vtTruck;),
    // #4
    (Name: 'ASV-11 Wood Truck'; Cargo: [cgWood]; Amount: 9; Cost: 5000;
    RunningCost: 19 * 12; Speed: 60; Since: 1950; VehicleType: vtTruck;),
    // #5
    (Name: 'RT Goods Truck'; Cargo: [cgGoods]; Amount: 9; Cost: 4500;
    RunningCost: 20 * 12; Speed: 60; Since: 1950; VehicleType: vtTruck;)
    //
    );

type

  { TRoadVehicle }

  TRoadVehicle = class(TVehicle)
  private
    FT: Integer;
    FState: string;
  public const
    Color: string = 'light red';
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
  TransportTycoon.Industries,
  TransportTycoon.Stations;

{ TRoadVehicle }

function IsPath(X, Y: Integer): Boolean; stdcall;
begin
  Result := Game.Map.IsRoadVehiclePath(X, Y);
end;

procedure TRoadVehicle.AddOrder(const AIndex: Integer);
begin
  with Game.Map.Industry[AIndex] do
    AddOrder(AIndex, Name, X, Y);
end;

constructor TRoadVehicle.Create(const AName: string; const AX, AY, ID: Integer);
begin
  inherited Create(AName, AX, AY, RoadVehicleBase, ID);
  FT := 0;
  FState := 'Wait';
end;

procedure TRoadVehicle.Load;
var
  C: TCargo;
begin
  FState := 'Load';
  for C := Succ(Low(TCargo)) to High(TCargo) do
    if (C in Game.Map.Industry[Order[OrderIndex].ID].Produces) and (C in Cargo)
    then
    begin
      SetCargoType(C);
      while (Game.Map.Industry[Order[OrderIndex].ID].ProducesAmount[C] > 0) and
        (CargoAmount < CargoMaxAmount) do
      begin
        Game.Map.Industry[Order[OrderIndex].ID].DecCargoAmount(C);
        IncCargoAmount;
      end;
      Exit;
    end;
end;

function TRoadVehicle.Move(const AX, AY: Integer): Boolean;
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

procedure TRoadVehicle.Step;
var
  C: TCargo;
  Station: TStation;
begin
  if Length(Order) > 0 then
  begin
    if not Move(Order[OrderIndex].X, Order[OrderIndex].Y) then
    begin
      Inc(FT);
      if Order[OrderIndex].ID <> LastStationId then
        UnLoad;
      case CargoType of
        cgPassengers:
          Station := TTownIndustry(Game.Map.Industry[Order[OrderIndex].ID])
            .BusStation;
      else
        Station := Game.Map.Industry[Order[OrderIndex].ID].TruckLoadingBay;
      end;
      FState := 'Service';
      if FT > (15 - (Station.Level * 2)) then
      begin
        FT := 0;
        Load;
        if FullLoad then
          for C := Succ(Low(TCargo)) to High(TCargo) do
            if (C in Game.Map.Industry[Order[OrderIndex].ID].Produces) and
              (C in Cargo) then
            begin
              SetCargoType(C);
              if (CargoAmount < CargoMaxAmount) then
                Exit;
            end;
        IncOrder;
      end
    end
    else
      IncDistance;
  end;
end;

procedure TRoadVehicle.UnLoad;
var
  Money: Integer;
begin
  SetLastStation;
  FState := 'Unload';
  if (CargoType in Game.Map.Industry[Order[OrderIndex].ID].Accepts) and
    (CargoType <> cgNone) and (CargoAmount > 0) then
  begin
    Money := (CargoAmount * (Distance div 10)) * CargoPrice[CargoType];
    Game.Map.Industry[Order[OrderIndex].ID].IncAcceptsCargoAmount(CargoType,
      CargoAmount);
    Game.ModifyMoney(ttRoadVehicleIncome, Money);
    Profit := Profit + Money;
    ClearCargo;
  end;
  Distance := 0;
end;

end.
