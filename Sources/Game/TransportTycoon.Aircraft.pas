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
  AircraftBase: array [0 .. 8] of TAircraftBase = (
    // #1
    (Name: 'Toreador MT-4'; Passengers: 25; BagsOfMail: 3; Cost: 22000;
    RunningCost: 130 * 12; Speed: 400; Since: 1950),
    // #2
    (Name: 'Rotor JG'; Passengers: 30; BagsOfMail: 4; Cost: 24000;
    RunningCost: 140 * 12; Speed: 420; Since: 1950),
    // #3
    (Name: 'Raxton ML'; Passengers: 35; BagsOfMail: 5; Cost: 27000;
    RunningCost: 150 * 12; Speed: 450; Since: 1955),
    // #4
    (Name: 'Tornado S9'; Passengers: 45; BagsOfMail: 5; Cost: 30000;
    RunningCost: 160 * 12; Speed: 500; Since: 1965),
    // #5
    (Name: 'ExOA-H7'; Passengers: 55; BagsOfMail: 7; Cost: 33000;
    RunningCost: 170 * 12; Speed: 700; Since: 1970),
    // #6
    (Name: 'AIN D88'; Passengers: 75; BagsOfMail: 7; Cost: 35000;
    RunningCost: 180 * 12; Speed: 800; Since: 1980),
    // #7
    (Name: 'HeWi C4'; Passengers: 100; BagsOfMail: 8; Cost: 38000;
    RunningCost: 190 * 12; Speed: 850; Since: 1990),
    // #8
    (Name: 'UtBotS FL'; Passengers: 120; BagsOfMail: 10; Cost: 40000;
    RunningCost: 200 * 12; Speed: 900; Since: 2000),
    // #9
    (Name: 'Venus M2'; Passengers: 150; BagsOfMail: 12; Cost: 50000;
    RunningCost: 210 * 12; Speed: 1000; Since: 2020)
    //
    );

type
  TAircraft = class(TVehicle)
  private
    FT: Integer;
    FDistance: Integer;
    FState: string;
    FPassengers: Integer;
    FMaxPassengers: Integer;
    FBagsOfMail: Integer;
    FMaxBagsOfMail: Integer;
    FLastAirportId: Integer;
    FOrderIndex: Integer;
  public
    Order: array of TOrder;
    constructor Create(const AName: string; const AX, AY, ID: Integer);
    function Move(const AX, AY: Integer): Boolean; override;
    property Distance: Integer read FDistance;
    property Passengers: Integer read FPassengers write FPassengers;
    property MaxPassengers: Integer read FMaxPassengers;
    property BagsOfMail: Integer read FBagsOfMail write FBagsOfMail;
    property MaxBagsOfMail: Integer read FMaxBagsOfMail;
    property State: string read FState;
    property LastAirportId: Integer write FLastAirportId;
    property OrderIndex: Integer read FOrderIndex;
    procedure Step; override;
    procedure Load;
    procedure UnLoad;
    procedure AddOrder(const AIndex: Integer); overload;
    procedure AddOrder(const AIndex: Integer; const AName: string;
      const AX, AY: Integer); overload;
    procedure DelOrder(const AOrderIndex: Integer);
    function IsOrder(const TownIndex: Integer): Boolean;
  end;

implementation

uses
  SysUtils,
  TransportTycoon.Game,
  TransportTycoon.Finances,
  TransportTycoon.PathFind,
  TransportTycoon.Map,
  TransportTycoon.Industries;

function IsPath(X, Y: Integer): Boolean; stdcall;
begin
  Result := True;
end;

procedure TAircraft.AddOrder(const AIndex: Integer; const AName: string;
  const AX, AY: Integer);
begin
  if TTownIndustry(Game.Map.Industry[AIndex]).Airport.HasBuilding then
  begin
    SetLength(Order, Length(Order) + 1);
    Order[High(Order)].ID := AIndex;
    Order[High(Order)].Name := AName;
    Order[High(Order)].X := AX;
    Order[High(Order)].Y := AY;
  end;
end;

procedure TAircraft.DelOrder(const AOrderIndex: Integer);
var
  I: Integer;
begin
  if (Length(Order) > 1) then
  begin
    if AOrderIndex > High(Order) then
      Exit;
    if AOrderIndex < Low(Order) then
      Exit;
    if AOrderIndex = High(Order) then
    begin
      SetLength(Order, Length(Order) - 1);
      Exit;
    end;
    for I := AOrderIndex + 1 to Length(Order) - 1 do
      Order[I - 1] := Order[I];
    SetLength(Order, Length(Order) - 1);
  end;
end;

procedure TAircraft.AddOrder(const AIndex: Integer);
begin
  with TTownIndustry(Game.Map.Industry[AIndex]) do
    AddOrder(AIndex, Name, X, Y);
end;

constructor TAircraft.Create(const AName: string; const AX, AY, ID: Integer);
begin
  inherited Create(AName, AX, AY);
  FT := 0;
  FState := 'Wait';
  FMaxPassengers := AircraftBase[ID].Passengers;
  FPassengers := 0;
  FMaxBagsOfMail := AircraftBase[ID].BagsOfMail;
  FBagsOfMail := 0;
  FOrderIndex := 0;
  LastAirportId := 0;
  FDistance := 0;
end;

procedure TAircraft.Load;
begin
  FState := 'Load';
  while (Game.Map.Industry[Order[OrderIndex].ID].ProducesAmount[cgPassengers] >
    0) and (Passengers < MaxPassengers) do
  begin
    Game.Map.Industry[Order[OrderIndex].ID].DecCargoAmount(cgPassengers);
    Inc(FPassengers);
  end;
  while (Game.Map.Industry[Order[OrderIndex].ID].ProducesAmount[cgBagsOfMail] >
    0) and (BagsOfMail < MaxBagsOfMail) do
  begin
    Game.Map.Industry[Order[OrderIndex].ID].DecCargoAmount(cgBagsOfMail);
    Inc(FBagsOfMail);
  end;
end;

function TAircraft.Move(const AX, AY: Integer): Boolean;
var
  NX, NY: Integer;
begin
  Result := False;
  FState := 'Fly';
  NX := 0;
  NY := 0;
  if not IsMove(Game.Map.Width, Game.Map.Height, X, Y, AX, AY, @IsPath, NX, NY)
  then
    Exit;
  SetLocation(NX, NY);
  Result := (X <> AX) or (Y <> AY);
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
      if Order[OrderIndex].ID <> FLastAirportId then
        UnLoad;
      FState := 'Service';
      if FT > (15 - (TTownIndustry(Game.Map.Industry[Order[OrderIndex].ID])
        .Airport.Level * 2)) then
      begin
        FT := 0;
        Load;
        FOrderIndex := FOrderIndex + 1;
        if (OrderIndex > High(Order)) then
          FOrderIndex := 0;
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
    M := (Passengers * (Distance div 10)) * 7;
    Game.ModifyMoney(ttAircraftIncome, M);
    Passengers := 0;
  end;
  if BagsOfMail > 0 then
  begin
    M := (BagsOfMail * (Distance div 7)) * 8;
    Game.ModifyMoney(ttAircraftIncome, M);
    BagsOfMail := 0;
  end;
  FDistance := 0;
end;

end.
