unit TransportTycoon.Aircraft;

interface

uses
  TransportTycoon.Vehicle,
  TransportTycoon.Order;

type
  TAircraftBase = record
    Name: string;
    Passengers: Word;
    BagsOfMail: Word;
    Cost: Word;
    RunningCost: Word;
    Speed: Word;
    Since: Word;
  end;

const
  AircraftBase: array [0 .. 2] of TAircraftBase = (
    // #1
    (Name: 'Toreador MT-4'; Passengers: 25; BagsOfMail: 4; Cost: 22000;
    RunningCost: 2000; Speed: 420; Since: 1930),
    // #2
    (Name: 'Rotor JG'; Passengers: 30; BagsOfMail: 3; Cost: 24000;
    RunningCost: 2200; Speed: 400; Since: 1940),
    // #3
    (Name: 'Raxton ML'; Passengers: 35; BagsOfMail: 4; Cost: 28000;
    RunningCost: 2400; Speed: 450; Since: 1950)
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
    FState: string;
    FPassengers: Integer;
    FMaxPassengers: Integer;
    FBagsOfMail: Integer;
    FMaxBagsOfMail: Integer;
  public
    Order: array of TOrder;
    OrderIndex, LastAirportId: Integer;
    constructor Create(const AName: string; const AX, AY, ID: Integer);
    function Move(const AX, AY: Integer): Boolean; override;
    property Name: string read FName;
    property Distance: Integer read FDistance;
    property Passengers: Integer read FPassengers write FPassengers;
    property MaxPassengers: Integer read FMaxPassengers;
    property BagsOfMail: Integer read FBagsOfMail write FBagsOfMail;
    property MaxBagsOfMail: Integer read FMaxBagsOfMail;
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
  Math,
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
    Order[High(Order)].ID := TownIndex;
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

constructor TAircraft.Create(const AName: string; const AX, AY, ID: Integer);
begin
  FName := AName;
  FX := AX;
  FY := AY;
  FT := 0;
  FH := 0;
  FState := 'Wait';
  FMaxPassengers := AircraftBase[ID].Passengers;
  FPassengers := 0;
  FMaxBagsOfMail := AircraftBase[ID].BagsOfMail;
  FBagsOfMail := 0;
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
  while (Game.Map.City[Order[OrderIndex].ID].Passengers > 0) and
    (Passengers < MaxPassengers) do
  begin
    with Game.Map.City[Order[OrderIndex].ID] do
      Passengers := Passengers - 1;
    Inc(FPassengers);
  end;
  while (Game.Map.City[Order[OrderIndex].ID].BagsOfMail > 0) and
    (BagsOfMail < MaxBagsOfMail) do
  begin
    with Game.Map.City[Order[OrderIndex].ID] do
      BagsOfMail := BagsOfMail - 1;
    Inc(FBagsOfMail);
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
    if Order[I].ID = TownIndex then
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
      if Order[OrderIndex].ID <> LastAirportId then
        UnLoad;
      FState := 'Service';
      if FT > (15 - (Game.Map.City[Order[OrderIndex].ID].Airport * 2)) then
      begin
        FT := 0;
        FH := RandomRange(0, 2);
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
  LastAirportId := Order[OrderIndex].ID;
  if Passengers > 0 then
  begin
    M := (Passengers * (Distance div 10)) * 5;
    Game.ModifyMoney(ttAircraftIncome, M);
    Passengers := 0;
  end;
  if BagsOfMail > 0 then
  begin
    M := (BagsOfMail * (Distance div 7)) * 4;
    Game.ModifyMoney(ttAircraftIncome, M);
    BagsOfMail := 0;
  end;
  FDistance := 0;
end;

end.
