unit TransportTycoon.Vehicle;

interface

uses
  TransportTycoon.Order,
  TransportTycoon.MapObject;

type
  TGetXYVal = function(X, Y: Integer): Boolean; stdcall;

type

  { TVehicle }

  TVehicle = class(TMapObject)
  private
    FDistance: Integer;
    FOrderIndex: Integer;
    FVehicleID: Integer;
  public
    Order: array of TOrder;
    constructor Create(const AName: string; const AX, AY: Integer);
    procedure Draw;
    procedure Step; virtual; abstract;
    function Move(const AX, AY: Integer): Boolean; virtual; abstract;
    property VehicleID: Integer read FVehicleID write FVehicleID;
    property OrderIndex: Integer read FOrderIndex write FOrderIndex;
    property Distance: Integer read FDistance write FDistance;
    procedure AddOrder(const TownIndex: Integer; const AName: string;
      const AX, AY: Integer); overload;
    procedure DelOrder(const AIndex: Integer);
    function IsOrder(const AIndex: Integer): Boolean;
    procedure IncOrder;
    procedure IncDistance;
  end;

implementation

uses
  BearLibTerminal,
  TransportTycoon.Game;

{ TVehicle }

constructor TVehicle.Create(const AName: string; const AX, AY: Integer);
begin
  inherited Create(AName, AX, AY);
  FOrderIndex := 0;
  FDistance := 0;
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

procedure TVehicle.IncDistance;
begin
  Inc(FDistance);
end;

end.
