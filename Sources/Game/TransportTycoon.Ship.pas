unit TransportTycoon.Ship;

interface

uses
  TransportTycoon.Vehicle,
  TransportTycoon.Order;

type
  TShipBase = record
    Name: string;
    Passengers: Word;
    Mail: Word;
    Cost: Word;
    RunningCost: Word;
    Speed: Word;
    Since: Word;
  end;

const
  ShipBase: array [0 .. 0] of TShipBase = (
    // #1
    (Name: 'TM-22'; Passengers: 120; Mail: 10; Cost: 25000;
    RunningCost: 90 * 12; Speed: 50; Since: 1950)
    //
    );

type
  TShip = class(TVehicle)
  private
    FT: Integer;
    FDistance: Integer;
    FState: string;
    FLastAirportId: Integer;
    FPassengers: Integer;
    FMaxPassengers: Integer;
    FMail: Integer;
    FMaxMail: Integer;
    FOrderIndex: Integer;
  public
    Order: array of TOrder;
    constructor Create(const AName: string; const AX, AY, ID: Integer);
    function Move(const AX, AY: Integer): Boolean; override;
    property Distance: Integer read FDistance;
    property Passengers: Integer read FPassengers write FPassengers;
    property MaxPassengers: Integer read FMaxPassengers;
    property Mail: Integer read FMail write FMail;
    property MaxMail: Integer read FMaxMail;
    property State: string read FState;
    property LastDockId: Integer write FLastAirportId;
    property OrderIndex: Integer read FOrderIndex;
    procedure Step; override;
    procedure Load;
    procedure UnLoad;
    procedure AddOrder(const AIndex: Integer); overload;
    procedure AddOrder(const TownIndex: Integer; const AName: string;
      const AX, AY: Integer); overload;
    procedure DelOrder(const AOrderIndex: Integer);
    function IsOrder(const TownIndex: Integer): Boolean;
  end;

implementation

uses
  SysUtils,
  TransportTycoon.Map,
  TransportTycoon.Game,
  TransportTycoon.Finances,
  TransportTycoon.PathFind,
  TransportTycoon.Industries;

function IsPath(X, Y: Integer): Boolean; stdcall;
begin
  Result := Game.Map.Cell[X][Y] in [tlTownIndustry, tlWater] + IndustryTiles;
end;

procedure TShip.AddOrder(const TownIndex: Integer; const AName: string;
  const AX, AY: Integer);
begin
  if Game.Map.Industry[TownIndex].Dock.HasBuilding then
  begin
    SetLength(Order, Length(Order) + 1);
    Order[High(Order)].ID := TownIndex;
    Order[High(Order)].Name := AName;
    Order[High(Order)].X := AX;
    Order[High(Order)].Y := AY;
  end;
end;

procedure TShip.AddOrder(const AIndex: Integer);
begin
  with Game.Map.Industry[AIndex] do
    AddOrder(AIndex, Name, X, Y);
end;

constructor TShip.Create(const AName: string; const AX, AY, ID: Integer);
begin
  inherited Create(AName, AX, AY);
  FT := 0;
  FState := 'Wait';
  FMaxPassengers := ShipBase[ID].Passengers;
  FPassengers := 0;
  FMaxMail := ShipBase[ID].Mail;
  FMail := 0;
  FOrderIndex := 0;
  LastDockId := 0;
  FDistance := 0;
end;

procedure TShip.DelOrder(const AOrderIndex: Integer);
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

function TShip.IsOrder(const TownIndex: Integer): Boolean;
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

procedure TShip.Load;
begin
  FState := 'Load';
  while (Game.Map.Industry[Order[OrderIndex].ID].ProducesAmount[cgPassengers] >
    0) and (Passengers < MaxPassengers) do
  begin
    Game.Map.Industry[Order[OrderIndex].ID].DecCargoAmount(cgPassengers);
    Inc(FPassengers);
  end;
  while (Game.Map.Industry[Order[OrderIndex].ID].ProducesAmount[cgMail] >
    0) and (Mail < MaxMail) do
  begin
    Game.Map.Industry[Order[OrderIndex].ID].DecCargoAmount(cgMail);
    Inc(FMail);
  end;
end;

function TShip.Move(const AX, AY: Integer): Boolean;
var
  NX, NY: Integer;
begin
  Result := False;
  FState := 'Move';
  NX := 0;
  NY := 0;
  if not IsMove(Game.Map.Width, Game.Map.Height, X, Y, AX, AY, @IsPath, NX, NY)
  then
    Exit;
  SetLocation(NX, NY);
  Result := (X <> AX) or (Y <> AY);
end;

procedure TShip.Step;
begin
  if Length(Order) > 0 then
  begin
    if not Move(Order[OrderIndex].X, Order[OrderIndex].Y) then
    begin
      Inc(FT);
      if Order[OrderIndex].ID <> FLastAirportId then
        UnLoad;
      FState := 'Service';
      if FT > (15 - (Game.Map.Industry[Order[OrderIndex].ID].Dock.Level * 2))
      then
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

procedure TShip.UnLoad;
var
  M: Integer;
begin
  FState := 'Unload';
  LastDockId := Order[OrderIndex].ID;
  if Passengers > 0 then
  begin
    M := (Passengers * (Distance div 10)) * 7;
    Game.ModifyMoney(ttShipIncome, M);
    Passengers := 0;
  end;
  if Mail > 0 then
  begin
    M := (Mail * (Distance div 7)) * 8;
    Game.ModifyMoney(ttShipIncome, M);
    Mail := 0;
  end;
  FDistance := 0;
end;

end.
