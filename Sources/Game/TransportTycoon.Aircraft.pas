unit TransportTycoon.Aircraft;

interface

type
  TOrder = record
    Id: Integer;
    Name: string;
    X, Y: Integer;
  end;

type
  TAircraft = class
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
    procedure Step;
    procedure Load;
    procedure UnLoad;
    procedure AddOrder(const AId: Integer; const AName: string;
      const AX, AY: Integer);
  end;

type
  TAircrafts = class(TObject)
  private
  public
    procedure Step;
    procedure AddAircraft(const AName: string;
      const ACityIndex, AMaxPassengers: Integer);
  end;

implementation

uses
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
      if FT > (299 - (Game.Map.City[Order[OrderIndex].Id].Airport * 50)) then
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

{ TAircrafts }

procedure TAircrafts.AddAircraft(const AName: string;
  const ACityIndex, AMaxPassengers: Integer);
begin
  with Game do
    if ((Map.City[ACityIndex].Airport > 0) and (Money >= 1000)) then
    begin
      SetLength(Aircraft, Length(Aircraft) + 1);
      Aircraft[High(Aircraft)] := TAircraft.Create(AName,
        Game.Map.City[ACityIndex].X, Game.Map.City[ACityIndex].Y,
        AMaxPassengers);
      Aircraft[High(Aircraft)].AddOrder(ACityIndex,
        Game.Map.City[ACityIndex].Name, Game.Map.City[ACityIndex].X,
        Game.Map.City[ACityIndex].Y);
      Game.ModifyMoney(-1000);
    end;
end;

procedure TAircrafts.Step;
var
  I: Integer;
begin
  for I := 0 to Length(Game.Aircraft) - 1 do
    Game.Aircraft[I].Step;
end;

end.
