unit TransportTycoon.Aircraft;

interface

uses
  TransportTycoon.Vehicle,
  TransportTycoon.Cargo;

const
  AircraftBase: array [0 .. 8] of TVehicleBase = (
    // #1
    (Name: 'Toreador MT-4'; CargoSet: [cgPassengers]; Amount: 25; Cost: 22000;
    RunningCost: 130 * 12; Speed: 400; Since: 1950; VehicleType: vtAircraft;),
    // #2
    (Name: 'Rotor JG'; CargoSet: [cgPassengers]; Amount: 30; Cost: 24000;
    RunningCost: 140 * 12; Speed: 420; Since: 1950; VehicleType: vtAircraft;),
    // #3
    (Name: 'Raxton ML'; CargoSet: [cgPassengers]; Amount: 35; Cost: 27000;
    RunningCost: 150 * 12; Speed: 450; Since: 1955; VehicleType: vtAircraft;),
    // #4
    (Name: 'Tornado S9'; CargoSet: [cgPassengers]; Amount: 45; Cost: 30000;
    RunningCost: 160 * 12; Speed: 500; Since: 1965; VehicleType: vtAircraft;),
    // #5
    (Name: 'ExOA-H7'; CargoSet: [cgPassengers]; Amount: 55; Cost: 33000;
    RunningCost: 170 * 12; Speed: 700; Since: 1970; VehicleType: vtAircraft;),
    // #6
    (Name: 'AIN D88'; CargoSet: [cgPassengers]; Amount: 75; Cost: 35000;
    RunningCost: 180 * 12; Speed: 800; Since: 1980; VehicleType: vtAircraft;),
    // #7
    (Name: 'HeWi C4'; CargoSet: [cgPassengers]; Amount: 100; Cost: 38000;
    RunningCost: 190 * 12; Speed: 850; Since: 1990; VehicleType: vtAircraft;),
    // #8
    (Name: 'UtBotS FL'; CargoSet: [cgPassengers]; Amount: 125; Cost: 40000;
    RunningCost: 200 * 12; Speed: 900; Since: 2000; VehicleType: vtAircraft;),
    // #9
    (Name: 'Venus M2'; CargoSet: [cgPassengers]; Amount: 160; Cost: 50000;
    RunningCost: 210 * 12; Speed: 1000; Since: 2020; VehicleType: vtAircraft;)
    //
    );

type

  { TAircraft }

  TAircraft = class(TVehicle)
  private
    FTimer: Integer;
    FState: string;
  public const
    Color: string = 'lightest blue';
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

{ TAircraft }

function IsPath(X, Y: Integer): Boolean; stdcall;
begin
  Result := Game.Map.IsAircraftPath(X, Y);
end;

procedure TAircraft.AddOrder(const AIndex: Integer);
begin
  with TTownIndustry(Game.Map.Industry[AIndex]) do
    Orders.AddOrder(AIndex, Name, X, Y);
end;

constructor TAircraft.Create(const AName: string; const AX, AY, AIndex: Integer);
begin
  inherited Create(AName, AX, AY, AircraftBase, AIndex);
  FTimer := 0;
  FState := 'Wait';
end;

procedure TAircraft.Load;
var
  LCargo: TCargo;
begin
  FState := 'Load';
  for LCargo := Succ(Low(TCargo)) to High(TCargo) do
    if (LCargo in Game.Map.Industry[CurOrder.ID].Produces) and
      (LCargo in CargoSet) then
    begin
      SetCargoType(LCargo);
      while (Game.Map.Industry[CurOrder.ID].ProducesAmount[LCargo] > 0) and
        (CargoAmount < CargoMaxAmount) do
      begin
        Game.Map.Industry[CurOrder.ID].DecCargoAmount(LCargo);
        IncCargoAmount;
      end;
      Exit;
    end;
end;

function TAircraft.Move(const AX, AY: Integer): Boolean;
var
  LNX, LNY: Integer;
begin
  Result := False;
  FState := 'Fly';
  LNX := 0;
  LNY := 0;
  if not IsMove(Game.Map.Width, Game.Map.Height, X, Y, AX, AY, @IsPath, LNX, LNY)
  then
    Exit;
  SetLocation(LNX, LNY);
  Result := (X <> AX) or (Y <> AY);
end;

procedure TAircraft.Step;
var
  LCargo: TCargo;
begin
  if Orders.Count > 0 then
  begin
    if not Move(CurOrder.X, CurOrder.Y) then
    begin
      Inc(FTimer);
      if CurOrder.ID <> LastStationId then
        UnLoad;
      FState := 'Service';
      if FTimer >
        (15 - (TTownIndustry(Game.Map.Industry[Orders.Order[Orders.OrderIndex]
        .ID]).Airport.Level * 2)) then
      begin
        FTimer := 0;
        Load;
        if FullLoad then
          for LCargo := Succ(Low(TCargo)) to High(TCargo) do
            if (LCargo in Game.Map.Industry[CurOrder.ID].Produces) and
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

procedure TAircraft.UnLoad;
var
  LMoney: Integer;
begin
  SetLastStation;
  FState := 'Unload';
  if (CargoType in Game.Map.Industry[CurOrder.ID].Accepts) and
    (CargoType <> cgNone) and (CargoAmount > 0) then
  begin
    LMoney := (CargoAmount * (Distance div 10)) * CargoPrice[CargoType];
    Game.Map.Industry[CurOrder.ID].IncAcceptsCargoAmount(CargoType,
      CargoAmount);
    Game.ModifyMoney(ttAircraftIncome, LMoney);
    Profit := Profit + LMoney;
    ClearCargo;
  end;
  Distance := 0;
end;

end.
