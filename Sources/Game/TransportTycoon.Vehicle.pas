﻿unit TransportTycoon.Vehicle;

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
    FVehicleID: Integer;
    FFullLoad: Boolean;
    FCargo: TCargoSet;
    FCargoType: TCargo;
    FCargoAmount: Integer;
    FCargoMaxAmount: Integer;
    FProfit: Integer;
    FLastProfit: Integer;
    FOrders: TOrders;
  public
    constructor Create(const AName: string; const AX, AY: Integer;
      const VehicleBase: array of TVehicleBase; const ID: Integer);
    destructor Destroy; override;
    procedure Draw;
    procedure Step; virtual; abstract;
    procedure Load; virtual; abstract;
    procedure UnLoad; virtual; abstract;
    function Move(const AX, AY: Integer): Boolean; virtual; abstract;
    property VehicleID: Integer read FVehicleID write FVehicleID;
    property Profit: Integer read FProfit write FProfit;
    property LastProfit: Integer read FLastProfit write FLastProfit;
    property Distance: Integer read FDistance write FDistance;
    property LastStationId: Integer read FLastStationId;
    property Cargo: TCargoSet read FCargo;
    property CargoType: TCargo read FCargoType;
    property CargoAmount: Integer read FCargoAmount;
    property CargoMaxAmount: Integer read FCargoMaxAmount;
    procedure IncDistance;
    procedure SetLastStation;
    property FullLoad: Boolean read FFullLoad write FFullLoad;
    procedure ClearCargo;
    procedure SetCargoType(const ACargo: TCargo);
    procedure IncCargoAmount(const AValue: Integer = 1);
    property Orders: TOrders read FOrders;
    function CurOrder: TOrder;
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
  FDistance := 0;
  FProfit := 0;
  FLastProfit := 0;
  FLastStationId := 0;
  FFullLoad := False;
  ClearCargo;
  FCargoMaxAmount := VehicleBase[ID].Amount;
  FCargo := VehicleBase[ID].Cargo;
  FOrders := TOrders.Create;
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

destructor TVehicle.Destroy;
begin
  FOrders.Free;
  inherited;
end;

procedure TVehicle.IncCargoAmount(const AValue: Integer);
begin
  Inc(FCargoAmount, AValue);
end;

function TVehicle.CurOrder: TOrder;
begin
  Result := Orders.Order[Orders.OrderIndex];
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
  FLastStationId := CurOrder.ID;
end;

end.
