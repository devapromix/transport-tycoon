unit TransportTycoon.Vehicles;

interface

uses
  TransportTycoon.Aircraft,
  TransportTycoon.Ship,
  TransportTycoon.RoadVehicle,
  TransportTycoon.Vehicle;

type
  TVehicles = class
  private const
    MaxAircrafts = 7;
    MaxShips = 7;
    MaxRoadVehicles = 7;
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
    function GetAircraft(AID: Integer): TAircraft;
    function GetShip(AID: Integer): TShip;
    function GetRoadVehicle(AID: Integer): TRoadVehicle;
    function GetVehicle(AX, AY: Integer; AVehicles: TArray<TVehicle>): Integer;
  public
    constructor Create;
    destructor Destroy; override;
    property CurrentVehicle: Integer read FCurrentVehicle write FCurrentVehicle;
    procedure Draw;
    procedure Step;
    procedure AddAircraft(const AName: string;
      const AIndex, AircraftID: Integer);
    procedure AddShip(const AName: string; const AIndex, ShipID: Integer);
    procedure AddRoadVehicle(const AName: string;
      const AIndex, RoadVehicleID: Integer);
    procedure RunningCosts;
    function GetCurrentAircraft(const AX, AY: Integer): Integer;
    function GetCurrentShip(const AX, AY: Integer): Integer;
    function GetCurrentRoadVehicle(const AX, AY: Integer): Integer;
    function IsVehicleOnMap(const AX, AY: Integer;
      out AVehicleName: string): Boolean;
    function IsBuyShipAllowed(): Boolean;
    function IsBuyAircraftAllowed(): Boolean;
    function IsBuyRoadVehicleAllowed(): Boolean;
    procedure Clear;
    property ShipCount: Integer read GetShipCount;
    property AircraftCount: Integer read GetAircraftCount;
    property RoadVehicleCount: Integer read GetRoadVehicleCount;
    property GotShips: Boolean read GetGotShips;
    property GotAircrafts: Boolean read GetGotAircrafts;
    property GotRoadVehicle: Boolean read GetGotRoadVehicles;
    property Aircraft[AID: Integer]: TAircraft read GetAircraft;
    property Ship[AID: Integer]: TShip read GetShip;
    property RoadVehicle[AID: Integer]: TRoadVehicle read GetRoadVehicle;
  end;

implementation

uses
  BearLibTerminal,
  TransportTycoon.Game,
  TransportTycoon.Finances,
  TransportTycoon.Industries;

type
  TGetVehicleFunc = function(const AX, AY: Integer): Integer of object;

procedure TVehicles.AddAircraft(const AName: string;
  const AIndex, AircraftID: Integer);
var
  Town: TTownIndustry;
begin
  Town := TTownIndustry(Game.Map.Industry[AIndex]);

  if (Town.Airport.IsBuilding and (Game.Money >= AircraftBase[AircraftID].Cost))
  then
    SetLength(FAircraft, AircraftCount + 1);

  FAircraft[High(FAircraft)] := TAircraft.Create(AName, Town.X, Town.Y,
    AircraftID);

  with FAircraft[High(FAircraft)] do
  begin
    AddOrder(AIndex, Town.Name, Town.X, Town.Y);
    Game.ModifyMoney(ttNewVehicles, -AircraftBase[AircraftID].Cost);
    VehicleID := AircraftID;
  end;
end;

procedure TVehicles.AddRoadVehicle(const AName: string;
  const AIndex, RoadVehicleID: Integer);
begin
  if ((Game.Money >= RoadVehicleBase[RoadVehicleID].Cost)) then
    SetLength(FRoadVehicle, RoadVehicleCount + 1);

  FRoadVehicle[High(FRoadVehicle)] := TRoadVehicle.Create(AName,
    Game.Map.Industry[AIndex].X, Game.Map.Industry[AIndex].Y, RoadVehicleID);

  with FRoadVehicle[High(FRoadVehicle)] do
  begin
    AddOrder(AIndex, Game.Map.Industry[AIndex].Name,
      Game.Map.Industry[AIndex].X, Game.Map.Industry[AIndex].Y);
    Game.ModifyMoney(ttNewVehicles, -RoadVehicleBase[RoadVehicleID].Cost);
    VehicleID := RoadVehicleID;
  end;
end;

procedure TVehicles.AddShip(const AName: string; const AIndex, ShipID: Integer);
begin
  if (Game.Map.Industry[AIndex].Dock.IsBuilding and
    (Game.Money >= ShipBase[ShipID].Cost)) then

    SetLength(FShip, ShipCount + 1);

  FShip[High(FShip)] := TShip.Create(AName, Game.Map.Industry[AIndex].X,
    Game.Map.Industry[AIndex].Y, ShipID);

  with FShip[High(FShip)] do
  begin
    AddOrder(AIndex, Game.Map.Industry[AIndex].Name,
      Game.Map.Industry[AIndex].X, Game.Map.Industry[AIndex].Y);
    Game.ModifyMoney(ttNewVehicles, -ShipBase[ShipID].Cost);
    VehicleID := ShipID;
  end;
end;

procedure TVehicles.RunningCosts;
var
  I, J, M: Integer;
begin
  for I := 0 to AircraftCount - 1 do
  begin
    J := Aircraft[I].VehicleID;
    M := AircraftBase[J].RunningCost div 12;
    Game.ModifyMoney(ttAircraftRunningCosts, -M);
  end;
  for I := 0 to ShipCount - 1 do
  begin
    J := Ship[I].VehicleID;
    M := ShipBase[J].RunningCost div 12;
    Game.ModifyMoney(ttShipRunningCosts, -M);
  end;
  for I := 0 to RoadVehicleCount - 1 do
  begin
    J := RoadVehicle[I].VehicleID;
    M := RoadVehicleBase[J].RunningCost div 12;
    Game.ModifyMoney(ttRoadVehicleRunningCosts, -M);
  end;
end;

procedure TVehicles.Clear;
var
  I: Integer;
begin
  for I := 0 to AircraftCount - 1 do
    Aircraft[I].Free;
  SetLength(FAircraft, 0);
  for I := 0 to ShipCount - 1 do
    Ship[I].Free;
  SetLength(FShip, 0);
  for I := 0 to RoadVehicleCount - 1 do
    RoadVehicle[I].Free;
  SetLength(FRoadVehicle, 0);
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
  I: Integer;
begin
  // Aircrafts
  terminal_color('lightest blue');
  for I := 0 to AircraftCount - 1 do
    Aircraft[I].Draw;
  // Ships
  terminal_color('white');
  for I := 0 to ShipCount - 1 do
    Ship[I].Draw;
  // Road Vehicles
  terminal_color('light red');
  for I := 0 to RoadVehicleCount - 1 do
    RoadVehicle[I].Draw;
  //
  terminal_color('white');
end;

function TVehicles.GetAircraft(AID: Integer): TAircraft;
begin
  Exit(FAircraft[AID]);
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
  I: Integer;
begin
  Result := -1;
  for I := 0 to Length(AVehicles) - 1 do
    if ((AVehicles[I].X = AX) and (AVehicles[I].Y = AY)) then
      Exit(I);
end;

function TVehicles.IsBuyAircraftAllowed: Boolean;
begin
  Exit(AircraftCount < MaxAircrafts);
end;

function TVehicles.IsBuyRoadVehicleAllowed: Boolean;
begin
  Exit(RoadVehicleCount < MaxRoadVehicles);
end;

function TVehicles.IsBuyShipAllowed: Boolean;
begin
  Exit(ShipCount < MaxShips);
end;

function TVehicles.IsVehicleOnMap(const AX, AY: Integer;
  out AVehicleName: string): Boolean;
  function GetVehicle(AFunc: TGetVehicleFunc;
    AVehicles: TArray<TVehicle>): Boolean;
  var
    ID: Integer;
  begin
    ID := AFunc(AX, AY);
    Result := ID >= 0;
    if Result then

      AVehicleName := AVehicles[ID].Name;
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

function TVehicles.GetRoadVehicle(AID: Integer): TRoadVehicle;
begin
  Exit(FRoadVehicle[AID]);
end;

function TVehicles.GetRoadVehicleCount: Integer;
begin
  Exit(Length(FRoadVehicle));
end;

function TVehicles.GetShip(AID: Integer): TShip;
begin
  Exit(FShip[AID]);
end;

function TVehicles.GetShipCount: Integer;
begin
  Exit(Length(FShip));
end;

procedure TVehicles.Step;
var
  I: Integer;
begin
  for I := 0 to AircraftCount - 1 do
    Aircraft[I].Step;
  for I := 0 to ShipCount - 1 do
    Ship[I].Step;
  for I := 0 to RoadVehicleCount - 1 do
    RoadVehicle[I].Step;
end;

end.
