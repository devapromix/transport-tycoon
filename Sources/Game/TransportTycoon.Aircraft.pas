unit TransportTycoon.Aircraft;

interface

uses
  TransportTycoon.Vehicle;

type
  TOrder = record
    Id: Integer;
    Name: string;
    X, Y: Integer;
  end;

type
  TTransport = class

  end;

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
    function Fly(const CX, CY: Integer): Boolean;
    property Name: string read FName;
    property Distance: Integer read FDistance;
    property Passengers: Integer read FPassengers;
    property MaxPassengers: Integer read FMaxPassengers;
    property X: Integer read FX;
    property Y: Integer read FY;
    property State: string read FState;
    procedure Step; override;
    procedure Load;
    procedure UnLoad;
    procedure AddOrder(const AId: Integer; const AName: string;
      const AX, AY: Integer);
    procedure Draw; override;
  end;

implementation

uses
  BearLibTerminal,
  Math,
  SysUtils,
  TransportTycoon.Game;

{ TPlane }

procedure TAircraft.AddOrder(const AId: Integer; const AName: string;
  const AX, AY: Integer);
begin
  if Game.Map.City[AId].Airport > 0 then
  begin
    SetLength(Order, Length(Order) + 1);
    Order[High(Order)].Id := AId;
    Order[High(Order)].Name := AName;
    Order[High(Order)].X := AX;
    Order[High(Order)].Y := AY;
  end;
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
  while (Game.Map.City[Order[OrderIndex].Id].Population > 0) and
    (Passengers < MaxPassengers) do
  begin
    with Game.Map.City[Order[OrderIndex].Id] do
      ModifyPopulation(-1);
    Inc(FPassengers);
  end;
end;

function TAircraft.Fly(const CX, CY: Integer): Boolean;
begin
  FState := 'Fly';
  if FH = 0 then
  begin
    if FX < CX then
      FX := FX + 1;
    if FY < CY then
      FY := FY + 1;
    if FX > CX then
      FX := FX - 1;
    if FY > CY then
      FY := FY - 1;
  end
  else
  begin
    if FY > CY then
      FY := FY - 1;
    if FX > CX then
      FX := FX - 1;
    if FY < CY then
      FY := FY + 1;
    if FX < CX then
      FX := FX + 1;
  end;
  Result := (X <> CX) or (Y <> CY);
end;

procedure TAircraft.Step;
begin
  if Length(Order) > 0 then
  begin
    if not Fly(Order[OrderIndex].X, Order[OrderIndex].Y) then
    begin
      Inc(FT);
      if Order[OrderIndex].Id <> LastAirportId then
        UnLoad;
      FState := 'Obs';
      if FT > (7 - (Game.Map.City[Order[OrderIndex].Id].Airport)) then
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
begin
  FState := 'UnLoad';
  LastAirportId := Order[OrderIndex].Id;
  if Passengers > 0 then
  begin
    Game.ModifyMoney(Passengers * (Distance div 10));
    FDistance := 0;
    FPassengers := 0;
  end;
end;

end.
