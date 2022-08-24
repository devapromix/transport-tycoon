unit TransportTycoon.Vehicle;

interface

uses
  TransportTycoon.Order,
  TransportTycoon.Cargo,
  TransportTycoon.MapObject;

type
  TGetXYVal = function(X, Y: Integer): Boolean; stdcall;

type
  TVehicleType = (vtAircraft, vtShip, vtBus, vtTruck);

type

  { TVehicleBase }

  TVehicleBase = record
    Name: string;
    Cargo: TCargoSet;
    Amount: Integer;
    Cost: Word;
    RunningCost: Word;
    Speed: Word;
    Since: Word;
    VehicleType: TVehicleType;
  end;

type

  { TVehicle }

  TVehicle = class(TMapObject)
  private
    FDistance: Integer;
    FLastStationId: Integer;
    FOrderIndex: Integer;
    FVehicleID: Integer;
    FFullLoad: Boolean;
    FCargo: TCargoSet;
    FCargoType: TCargo;
    FCargoAmount: Integer;
    FCargoMaxAmount: Integer;
    FProfit: Integer;
  public
    Order: array of TOrder;
    constructor Create(const AName: string; const AX, AY: Integer;
      const VehicleBase: array of TVehicleBase; const ID: Integer);
    procedure Draw;
    procedure Step; virtual; abstract;
    procedure Load; virtual; abstract;
    procedure UnLoad; virtual; abstract;
    function Move(const AX, AY: Integer): Boolean; virtual; abstract;
    property VehicleID: Integer read FVehicleID write FVehicleID;
    property Profit: Integer read FProfit write FProfit;
    property OrderIndex: Integer read FOrderIndex write FOrderIndex;
    property Distance: Integer read FDistance write FDistance;
    property LastStationId: Integer read FLastStationId;
    property Cargo: TCargoSet read FCargo;
    property CargoType: TCargo read FCargoType;
    property CargoAmount: Integer read FCargoAmount;
    property CargoMaxAmount: Integer read FCargoMaxAmount;
    procedure AddOrder(const TownIndex: Integer; const AName: string;
      const AX, AY: Integer); overload;
    procedure DelOrder(const AIndex: Integer);
    function IsOrder(const AIndex: Integer): Boolean;
    procedure IncOrder;
    procedure IncDistance;
    procedure SetLastStation;
    property FullLoad: Boolean read FFullLoad write FFullLoad;
    procedure ClearCargo;
    procedure SetCargoType(const ACargo: TCargo);
    procedure IncCargoAmount(const AValue: Integer = 1);
  end;

implementation

uses
  BearLibTerminal,
  TransportTycoon.Game;

{ TVehicle }

constructor TVehicle.Create(const AName: string; const AX, AY: Integer;
  const VehicleBase: array of TVehicleBase; const ID: Integer);
begin
  inherited Create(AName, AX, AY);
  FOrderIndex := 0;
  FDistance := 0;
  FProfit := 0;
  FLastStationId := 0;
  FFullLoad := False;
  ClearCargo;
  FCargoMaxAmount := VehicleBase[ID].Amount;
  FCargo := VehicleBase[ID].Cargo;
end;

procedure TVehicle.ClearCargo;
begin
  FCargoAmount := 0;
  FCargoType := cgNone;
end;

procedure TVehicle.Draw;
begin
  terminal_print(X - Game.Map.Left, Y - Game.Map.Top, '@');
end;

procedure TVehicle.AddOrder(const TownIndex: Integer; const AName: string;
  const AX, AY: Integer);
begin
  SetLength(Order, Length(Order) + 1);
  Order[High(Order)].ID := TownIndex;
  Order[High(Order)].Name := AName;
  Order[High(Order)].X := AX;
  Order[High(Order)].Y := AY;
end;

procedure TVehicle.DelOrder(const AIndex: Integer);
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

function TVehicle.IsOrder(const AIndex: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Length(Order) - 1 do
    if Order[I].ID = AIndex then
      Exit(True);
end;

procedure TVehicle.IncOrder;
begin
  FOrderIndex := FOrderIndex + 1;
  if (FOrderIndex > High(Order)) then
    FOrderIndex := 0;
end;

procedure TVehicle.IncCargoAmount(const AValue: Integer);
begin
  Inc(FCargoAmount, AValue);
end;

procedure TVehicle.IncDistance;
begin
  Inc(FDistance);
end;

procedure TVehicle.SetCargoType(const ACargo: TCargo);
begin
  FCargoType := ACargo;
end;

procedure TVehicle.SetLastStation;
begin
  FLastStationId := Order[FOrderIndex].ID;
end;

end.
