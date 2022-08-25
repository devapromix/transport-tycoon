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
    FLastProfit: Integer;
    FOrder: array of TOrder;
    function GetOrder(Index: Integer): TOrder;
    procedure SetOrder(Index: Integer; AValue: TOrder);
  public
    constructor Create(const AName: string; const AX, AY: Integer;
      const VehicleBase: array of TVehicleBase; const ID: Integer);
    procedure Draw;
    procedure Step; virtual; abstract;
    procedure Load; virtual; abstract;
    procedure UnLoad; virtual; abstract;
    function Move(const AX, AY: Integer): Boolean; virtual; abstract;
    property VehicleID: Integer read FVehicleID write FVehicleID;
    property Profit: Integer read FProfit write FProfit;
    property LastProfit: Integer read FLastProfit write FLastProfit;
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
    property Order[Index: Integer]: TOrder read GetOrder write SetOrder;
    function IsOrder(const AIndex: Integer): Boolean;
    procedure IncOrder;
    function OrderLength: Integer;
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

function TVehicle.GetOrder(Index: Integer): TOrder;
begin
  Result := FOrder[Index];
end;

procedure TVehicle.SetOrder(Index: Integer; AValue: TOrder);
begin
  FOrder[Index] := AValue
end;

constructor TVehicle.Create(const AName: string; const AX, AY: Integer;
  const VehicleBase: array of TVehicleBase; const ID: Integer);
begin
  inherited Create(AName, AX, AY);
  FOrderIndex := 0;
  FDistance := 0;
  FProfit := 0;
  FLastProfit := 0;
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
  SetLength(FOrder, Length(FOrder) + 1);
  FOrder[High(FOrder)].ID := TownIndex;
  FOrder[High(FOrder)].Name := AName;
  FOrder[High(FOrder)].X := AX;
  FOrder[High(FOrder)].Y := AY;
end;

procedure TVehicle.DelOrder(const AIndex: Integer);
var
  I: Integer;
begin
  if (Length(FOrder) > 1) then
  begin
    if AIndex > High(FOrder) then
      Exit;
    if AIndex < Low(FOrder) then
      Exit;
    if AIndex = High(FOrder) then
    begin
      SetLength(FOrder, Length(FOrder) - 1);
      Exit;
    end;
    for I := AIndex + 1 to Length(FOrder) - 1 do
      FOrder[I - 1] := FOrder[I];
    SetLength(FOrder, Length(FOrder) - 1);
  end;
end;

function TVehicle.IsOrder(const AIndex: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Length(FOrder) - 1 do
    if FOrder[I].ID = AIndex then
      Exit(True);
end;

procedure TVehicle.IncOrder;
begin
  FOrderIndex := FOrderIndex + 1;
  if (FOrderIndex > High(FOrder)) then
    FOrderIndex := 0;
end;

function TVehicle.OrderLength: Integer;
begin
  Result := Length(FOrder);
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
