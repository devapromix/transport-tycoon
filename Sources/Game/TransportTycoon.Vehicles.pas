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
    procedure Clear;
    property ShipCount: Integer read GetShipCount;
    property AircraftCount: Integer read GetAircraftCount;
    property RoadVehicleCount: Integer read GetRoadVehicleCount;
    property GotShips: Boolean read GetGotShips;
    property GotAircrafts: Boolean read GetGotAircrafts;
    property GotRoadVehicles: Boolean read GetGotRoadVehicles;
    property Aircraft[AID: Integer]: TAircraft read GetAircraft;
    property Ship[AID: Integer]: TShip read GetShip;
    property RoadVehicle[AID: Integer]: TRoadVehicle read GetRoadVehicle;
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
  I, LID, LMoney: Integer;
begin
  for I := 0 to AircraftCount - 1 do
  begin
    LID := Aircraft[I].VehicleID;
    LMoney := AircraftBase[LID].RunningCost div 12;
    Game.ModifyMoney(ttAircraftRunningCosts, -LMoney);
    Aircraft[I].Profit := Aircraft[I].Profit - LMoney;
  end;
  for I := 0 to ShipCount - 1 do
  begin
    LID := Ship[I].VehicleID;
    LMoney := ShipBase[LID].RunningCost div 12;
    Game.ModifyMoney(ttShipRunningCosts, -LMoney);
    Ship[I].Profit := Ship[I].Profit - LMoney;
  end;
  for I := 0 to RoadVehicleCount - 1 do
  begin
    LID := RoadVehicle[I].VehicleID;
    LMoney := RoadVehicleBase[LID].RunningCost div 12;
    Game.ModifyMoney(ttRoadVehicleRunningCosts, -LMoney);
    RoadVehicle[I].Profit := RoadVehicle[I].Profit - LMoney;
  end;
end;

procedure TVehicles.Clear;
var
  I: Integer;
begin
  for I := 0 to AircraftCount - 1 do
    FreeAndNil(FAircraft[I]);
  SetLength(FAircraft, 0);
  for I := 0 to ShipCount - 1 do
    FreeAndNil(FShip[I]);
  SetLength(FShip, 0);
  for I := 0 to RoadVehicleCount - 1 do
    FreeAndNil(FRoadVehicle[I]);
  SetLength(FRoadVehicle, 0);
end;

procedure TVehicles.ClearProfit;
var
  I: Integer;
begin
  for I := 0 to AircraftCount - 1 do
    with Aircraft[I] do
    begin
      LastProfit := Profit;
      Profit := 0;
    end;
  for I := 0 to ShipCount - 1 do
    with Ship[I] do
    begin
      LastProfit := Profit;
      Profit := 0;
    end;
  for I := 0 to RoadVehicleCount - 1 do
    with RoadVehicle[I] do
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
  I: Integer;
begin
  // Aircrafts
  terminal_color(TAircraft.Color);
  for I := 0 to AircraftCount - 1 do
    Aircraft[I].Draw;
  // Ships
  terminal_color(TShip.Color);
  for I := 0 to ShipCount - 1 do
    Ship[I].Draw;
  // Road Vehicles
  terminal_color(TRoadVehicle.Color);
  for I := 0 to RoadVehicleCount - 1 do
    RoadVehicle[I].Draw;
  //
  terminal_color(TPalette.Default);
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
    LID: Integer;
  begin
    LID := AFunc(AX, AY);
    Result := LID >= 0;
    if Result then
      AVehicleName := AVehicles[LID].Name;
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
  I, J: Integer;
begin
  try
    for J := 0 to 200 - 1 do
    begin
      for I := 0 to AircraftCount - 1 do
        with Aircraft[I] do
          if AP <= 0 then
          begin
            Step;
            AP := MaxAP;
          end
          else
            AP := AP - 1;
      for I := 0 to ShipCount - 1 do
        with Ship[I] do
          if AP <= 0 then
          begin
            Step;
            AP := MaxAP;
          end
          else
            AP := AP - 1;
      for I := 0 to RoadVehicleCount - 1 do
        with RoadVehicle[I] do
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
