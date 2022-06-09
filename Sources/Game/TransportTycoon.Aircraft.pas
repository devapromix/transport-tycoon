unit TransportTycoon.Aircraft;

interface

uses
  TransportTycoon.Vehicle,
  TransportTycoon.Order;

type
  TAircraftBase = record
    Name: string;
    MaxPassengers: Word;
    Speed: Word;
  end;

const
  AircraftBase: array [0 .. 1] of TAircraftBase = (
    // #1
    (Name: 'Toreador MT-4'; MaxPassengers: 25; Speed: 420),
    // #2
    (Name: 'Rotor JG'; MaxPassengers: 30; Speed: 400)
    //
    );

type
  TAircraft = class(TVehicle)
  private
    FName: string;
    FH: Integer;
    FT: Integer;
    FY: Integer;
    FX: Integer;
    FDistance: Integer;
    FPassengers: Integer;
    FMaxPassengers: Integer;
    FState: string;
  public
    Order: array of TOrder;
    OrderIndex, LastAirportId: Integer;
    constructor Create(const AName: string;
      const AX, AY, AMaxPassengers: Integer);
    function Move(const AX, AY: Integer): Boolean; override;
    property Name: string read FName;
    property Distance: Integer read FDistance;
    property Passengers: Integer read FPassengers write FPassengers;
    property MaxPassengers: Integer read FMaxPassengers;
    property X: Integer read FX;
    property Y: Integer read FY;
    property State: string read FState;
    procedure Step; override;
    procedure Load;
    procedure UnLoad;
    procedure AddOrder(const TownIndex: Integer); overload;
    procedure AddOrder(const TownIndex: Integer; const AName: string;
      const AX, AY: Integer); overload;
    function IsOrder(const TownIndex: Integer): Boolean;
    procedure Draw; override;
  end;

implementation

uses
  BearLibTerminal,
  SysUtils,
  TransportTycoon.Game,
  TransportTycoon.Finances;

{ TPlane }

procedure TAircraft.AddOrder(const TownIndex: Integer; const AName: string;
  const AX, AY: Integer);
begin
  if Game.Map.City[TownIndex].Airport > 0 then
  begin
    SetLength(Order, Length(Order) + 1);
    Order[High(Order)].Id := TownIndex;
    Order[High(Order)].Name := AName;
    Order[High(Order)].X := AX;
    Order[High(Order)].Y := AY;
  end;
end;

procedure TAircraft.AddOrder(const TownIndex: Integer);
begin
  with Game.Map.City[TownIndex] do
    AddOrder(TownIndex, Name, X, Y);
end;

constructor TAircraft.Create(const AName: string;
  const AX, AY, AMaxPassengers: Integer);
begin
  FName := AName;
  FX := AX;
  FY := AY;
  FT := 0;
  FH := 0;
  FState := 'Wait';
  FMaxPassengers := AMaxPassengers;
  FPassengers := 0;
  OrderIndex := 0;
  LastAirportId := 0;
  FDistance := 0;
end;

procedure TAircraft.Draw;
begin
  terminal_print(FX, FY - Game.Map.Top, '@');
end;

procedure TAircraft.Load;
begin
  FState := 'Load';
  while (Game.Map.City[Order[OrderIndex].Id].Passengers > 0) and
    (Passengers < MaxPassengers) do
  begin
    with Game.Map.City[Order[OrderIndex].Id] do
      Passengers := Passengers - 1;
    Inc(FPassengers);
  end;
end;

function TAircraft.Move(const AX, AY: Integer): Boolean;
begin
  FState := 'Fly';
  if FH = 0 then
  begin
    if FX < AX then
      FX := FX + 1;
    if FY < AY then
      FY := FY + 1;
    if FX > AX then
      FX := FX - 1;
    if FY > AY then
      FY := FY - 1;
  end
  else
  begin
    if FY > AY then
      FY := FY - 1;
    if FX > AX then
      FX := FX - 1;
    if FY < AY then
      FY := FY + 1;
    if FX < AX then
      FX := FX + 1;
  end;
  Result := (FX <> AX) or (FY <> AY);
end;

function TAircraft.IsOrder(const TownIndex: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Length(Order) - 1 do
    if Order[I].Id = TownIndex then
    begin
      Result := True;
      Exit;
    end;
end;

procedure TAircraft.Step;
begin
  if Length(Order) > 0 then
  begin
    if not Move(Order[OrderIndex].X, Order[OrderIndex].Y) then
    begin
      Inc(FT);
      if Order[OrderIndex].Id <> LastAirportId then
        UnLoad;
      FState := 'Service';
      if FT > (15 - (Game.Map.City[Order[OrderIndex].Id].Airport * 2)) then
      begin
        FT := 0;
        FH := Random(2);
        Load;
        Inc(OrderIndex);
        if (OrderIndex > High(Order)) then
          OrderIndex := 0;
      end;
    end
    else
      Inc(FDistance);
  end;
end;

procedure TAircraft.UnLoad;
var
  M: Integer;
begin
  FState := 'Unload';
  LastAirportId := Order[OrderIndex].Id;
  if Passengers > 0 then
  begin
    M := Passengers * (Distance div 10);
    Game.ModifyMoney(ttAircraftIncome, M);
    FDistance := 0;
    FPassengers := 0;
  end;
end;

end.
