unit TransportTycoon.Vehicles;

interface

uses
  TransportTycoon.Aircraft,
  TransportTycoon.Ship,
  TransportTycoon.RoadVehicle,
  TransportTycoon.Vehicle;

type
  TVehicles = class(TObject)
  private const
    MaxVehicles = 7;
  private
    FCurrentVehicle: Integer;
    FAircraft: TArray<TAircraft>;
    FShip: TArray<TShip>;
    FRoadVehicle: TArray<TRoadVehicle>;
    function GetAircraftCount: Integer;
    function GetShipCount: Integer;
    function GetRoadVehicleCount: Integer;
    function GetGotAircrafts: Boolean;
    function GetGotShips: Boolean;
    function GetGotRoadVehicles: Boolean;
    function GetAircraft(AVehicle: Integer): TAircraft;
    function GetShip(AVehicle: Integer): TShip;
    function GetRoadVehicle(AVehicle: Integer): TRoadVehicle;
    function GetVehicle(AX, AY: Integer; AVehicles: TArray<TVehicle>): Integer;
  public
    constructor Create;
    destructor Destroy; override;
    property CurrentVehicle: Integer read FCurrentVehicle write FCurrentVehicle;
    procedure Draw;
    procedure Step;
    procedure Clear;
    procedure AddAircraft(const AName: string;
      const AIndex, AAircraftID: Integer);
    procedure AddShip(const AName: string; const AIndex, AShipID: Integer);
    procedure AddRoadVehicle(const AName: string;
      const AIndex, ARoadVehicleID: Integer);
    procedure RunningCosts;
    function GetCurrentAircraft(const AX, AY: Integer): Integer;
    function GetCurrentShip(const AX, AY: Integer): Integer;
    function GetCurrentRoadVehicle(const AX, AY: Integer): Integer;
    function IsVehicleOnMap(const AX, AY: Integer;
      out AVehicleName: string): Boolean;
    function IsBuyShipAllowed(): Boolean;
    function IsBuyAircraftAllowed(): Boolean;
    function IsBuyRoadVehicleAllowed(): Boolean;
    property ShipCount: Integer read GetShipCount;
    property AircraftCount: Integer read GetAircraftCount;
    property RoadVehicleCount: Integer read GetRoadVehicleCount;
    property GotShips: Boolean read GetGotShips;
    property GotAircrafts: Boolean read GetGotAircrafts;
    property GotRoadVehicles: Boolean read GetGotRoadVehicles;
    property Aircraft[AVehicleIdent: Integer]: TAircraft read GetAircraft;
    property Ship[AVehicleIdent: Integer]: TShip read GetShip;
    property RoadVehicle[AVehicleIdent: Integer]: TRoadVehicle
      read GetRoadVehicle;
    procedure ClearProfit;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Game,
  TransportTycoon.Finances,
  TransportTycoon.Industries,
  TransportTycoon.Palette,
  TransportTycoon.Log;

type
  TGetVehicleFunc = function(const AX, AY: Integer): Integer of object;

procedure TVehicles.AddAircraft(const AName: string;
  const AIndex, AAircraftID: Integer);
var
  LTown: TTownIndustry;
begin
  LTown := TTownIndustry(Game.Map.Industry[AIndex]);

  if (LTown.Airport.IsBuilding and (Game.Money >= AircraftBase[AAircraftID]
    .Cost)) then
    SetLength(FAircraft, AircraftCount + 1);

  FAircraft[High(FAircraft)] := TAircraft.Create(AName, LTown.X, LTown.Y,
    AAircraftID);

  with FAircraft[High(FAircraft)] do
  begin
    Orders.AddOrder(AIndex, LTown.Name, LTown.X, LTown.Y);
    Game.ModifyMoney(ttNewVehicles, -AircraftBase[AAircraftID].Cost);
    VehicleID := AAircraftID;
  end;
end;

procedure TVehicles.AddRoadVehicle(const AName: string;
  const AIndex, ARoadVehicleID: Integer);
begin
  if ((Game.Money >= RoadVehicleBase[ARoadVehicleID].Cost)) then
    SetLength(FRoadVehicle, RoadVehicleCount + 1);

  FRoadVehicle[High(FRoadVehicle)] := TRoadVehicle.Create(AName,
    Game.Map.Industry[AIndex].X, Game.Map.Industry[AIndex].Y, ARoadVehicleID);

  with FRoadVehicle[High(FRoadVehicle)] do
  begin
    Orders.AddOrder(AIndex, Game.Map.Industry[AIndex].Name,
      Game.Map.Industry[AIndex].X, Game.Map.Industry[AIndex].Y);
    Game.ModifyMoney(ttNewVehicles, -RoadVehicleBase[ARoadVehicleID].Cost);
    VehicleID := ARoadVehicleID;
  end;
end;

procedure TVehicles.AddShip(const AName: string;
  const AIndex, AShipID: Integer);
begin
  if (Game.Map.Industry[AIndex].Dock.IsBuilding and
    (Game.Money >= ShipBase[AShipID].Cost)) then

    SetLength(FShip, ShipCount + 1);

  FShip[High(FShip)] := TShip.Create(AName, Game.Map.Industry[AIndex].X,
    Game.Map.Industry[AIndex].Y, AShipID);

  with FShip[High(FShip)] do
  begin
    Orders.AddOrder(AIndex, Game.Map.Industry[AIndex].Name,
      Game.Map.Industry[AIndex].X, Game.Map.Industry[AIndex].Y);
    Game.ModifyMoney(ttNewVehicles, -ShipBase[AShipID].Cost);
    VehicleID := AShipID;
  end;
end;

procedure TVehicles.RunningCosts;
var
  LVehicle, LVehicleIdent, LMoney: Integer;
begin
  for LVehicle := 0 to AircraftCount - 1 do
  begin
    LVehicleIdent := Aircraft[LVehicle].VehicleID;
    LMoney := AircraftBase[LVehicleIdent].RunningCost div 12;
    Game.ModifyMoney(ttAircraftRunningCosts, -LMoney);
    Aircraft[LVehicle].Profit := Aircraft[LVehicle].Profit - LMoney;
  end;
  for LVehicle := 0 to ShipCount - 1 do
  begin
    LVehicleIdent := Ship[LVehicle].VehicleID;
    LMoney := ShipBase[LVehicleIdent].RunningCost div 12;
    Game.ModifyMoney(ttShipRunningCosts, -LMoney);
    Ship[LVehicle].Profit := Ship[LVehicle].Profit - LMoney;
  end;
  for LVehicle := 0 to RoadVehicleCount - 1 do
  begin
    LVehicleIdent := RoadVehicle[LVehicle].VehicleID;
    LMoney := RoadVehicleBase[LVehicleIdent].RunningCost div 12;
    Game.ModifyMoney(ttRoadVehicleRunningCosts, -LMoney);
    RoadVehicle[LVehicle].Profit := RoadVehicle[LVehicle].Profit - LMoney;
  end;
end;

procedure TVehicles.Clear;
var
  LVehicle: Integer;
begin
  for LVehicle := 0 to AircraftCount - 1 do
    FreeAndNil(FAircraft[LVehicle]);
  SetLength(FAircraft, 0);
  for LVehicle := 0 to ShipCount - 1 do
    FreeAndNil(FShip[LVehicle]);
  SetLength(FShip, 0);
  for LVehicle := 0 to RoadVehicleCount - 1 do
    FreeAndNil(FRoadVehicle[LVehicle]);
  SetLength(FRoadVehicle, 0);
end;

procedure TVehicles.ClearProfit;
var
  LVehicle: Integer;
begin
  for LVehicle := 0 to AircraftCount - 1 do
    with Aircraft[LVehicle] do
    begin
      LastProfit := Profit;
      Profit := 0;
    end;
  for LVehicle := 0 to ShipCount - 1 do
    with Ship[LVehicle] do
    begin
      LastProfit := Profit;
      Profit := 0;
    end;
  for LVehicle := 0 to RoadVehicleCount - 1 do
    with RoadVehicle[LVehicle] do
    begin
      LastProfit := Profit;
      Profit := 0;
    end;
end;

constructor TVehicles.Create;
begin
  CurrentVehicle := 0;
end;

destructor TVehicles.Destroy;
begin
  Clear();
  inherited;
end;

procedure TVehicles.Draw;
var
  LVehicle: Integer;
begin
  // Aircrafts
  terminal_color(TAircraft.Color);
  for LVehicle := 0 to AircraftCount - 1 do
    Aircraft[LVehicle].Draw;
  // Ships
  terminal_color(TShip.Color);
  for LVehicle := 0 to ShipCount - 1 do
    Ship[LVehicle].Draw;
  // Road Vehicles
  terminal_color(TRoadVehicle.Color);
  for LVehicle := 0 to RoadVehicleCount - 1 do
    RoadVehicle[LVehicle].Draw;
  //
  terminal_color(TPalette.Default);
end;

function TVehicles.GetAircraft(AVehicle: Integer): TAircraft;
begin
  Exit(FAircraft[AVehicle]);
end;

function TVehicles.GetAircraftCount: Integer;
begin
  Exit(Length(FAircraft));
end;

function TVehicles.GetCurrentAircraft(const AX, AY: Integer): Integer;
begin
  Exit(GetVehicle(AX, AY, TArray<TVehicle>(FAircraft)));
end;

function TVehicles.GetCurrentRoadVehicle(const AX, AY: Integer): Integer;
begin
  Exit(GetVehicle(AX, AY, TArray<TVehicle>(FRoadVehicle)));
end;

function TVehicles.GetCurrentShip(const AX, AY: Integer): Integer;
begin
  Exit(GetVehicle(AX, AY, TArray<TVehicle>(FShip)));
end;

function TVehicles.GetVehicle(AX, AY: Integer;
  AVehicles: TArray<TVehicle>): Integer;
var
  LVehicle: Integer;
begin
  Result := -1;
  for LVehicle := 0 to Length(AVehicles) - 1 do
    if ((AVehicles[LVehicle].X = AX) and (AVehicles[LVehicle].Y = AY)) then
      Exit(LVehicle);
end;

function TVehicles.IsBuyAircraftAllowed: Boolean;
begin
  Exit(AircraftCount < MaxVehicles);
end;

function TVehicles.IsBuyRoadVehicleAllowed: Boolean;
begin
  Exit(RoadVehicleCount < MaxVehicles);
end;

function TVehicles.IsBuyShipAllowed: Boolean;
begin
  Exit(ShipCount < MaxVehicles);
end;

function TVehicles.IsVehicleOnMap(const AX, AY: Integer;
  out AVehicleName: string): Boolean;

  function GetVehicle(AFunc: TGetVehicleFunc;
    AVehicles: TArray<TVehicle>): Boolean;
  var
    LVehicle: Integer;
  begin
    LVehicle := AFunc(AX, AY);
    Result := LVehicle >= 0;
    if Result then
      AVehicleName := AVehicles[LVehicle].Name;
  end;

begin
  AVehicleName := '';
  // for more Vehicle types add more "if not" expressions in this chain
  if not GetVehicle(GetCurrentAircraft, TArray<TVehicle>(FAircraft)) then
    if not GetVehicle(GetCurrentShip, TArray<TVehicle>(FShip)) then
      GetVehicle(GetCurrentRoadVehicle, TArray<TVehicle>(FRoadVehicle));
  Exit(AVehicleName <> '');
end;

function TVehicles.GetGotAircrafts: Boolean;
begin
  Exit(AircraftCount > 0);
end;

function TVehicles.GetGotRoadVehicles: Boolean;
begin
  Exit(RoadVehicleCount > 0);
end;

function TVehicles.GetGotShips: Boolean;
begin
  Exit(ShipCount > 0);
end;

function TVehicles.GetRoadVehicle(AVehicle: Integer): TRoadVehicle;
begin
  Exit(FRoadVehicle[AVehicle]);
end;

function TVehicles.GetRoadVehicleCount: Integer;
begin
  Exit(Length(FRoadVehicle));
end;

function TVehicles.GetShip(AVehicle: Integer): TShip;
begin
  Exit(FShip[AVehicle]);
end;

function TVehicles.GetShipCount: Integer;
begin
  Exit(Length(FShip));
end;

procedure TVehicles.Step;
var
  LVehicle, LTick: Integer;
begin
  try
    for LTick := 0 to 200 - 1 do
    begin
      for LVehicle := 0 to AircraftCount - 1 do
        with Aircraft[LVehicle] do
          if AP <= 0 then
          begin
            Step;
            AP := MaxAP;
          end
          else
            AP := AP - 1;
      for LVehicle := 0 to ShipCount - 1 do
        with Ship[LVehicle] do
          if AP <= 0 then
          begin
            Step;
            AP := MaxAP;
          end
          else
            AP := AP - 1;
      for LVehicle := 0 to RoadVehicleCount - 1 do
        with RoadVehicle[LVehicle] do
          if AP <= 0 then
          begin
            Step;
            AP := MaxAP;
          end
          else
            AP := AP - 1;
    end;
  except
    on E: Exception do
      Log.Add('TVehicles.Step', E.Message);
  end;
end;

end.
