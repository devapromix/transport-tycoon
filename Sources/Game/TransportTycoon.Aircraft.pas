unit TransportTycoon.Aircraft;

interface

uses
  TransportTycoon.Vehicle,
  TransportTycoon.Cargo;

type
  TAircraftBase = record
    Name: string;
    Passengers: Word;
    Mail: Word;
    Cost: Word;
    RunningCost: Word;
    Speed: Word;
    Since: Word;
  end;

const
  AircraftBase: array [0 .. 8] of TAircraftBase = (
    // #1
    (Name: 'Toreador MT-4'; Passengers: 25; Mail: 3; Cost: 22000;
    RunningCost: 130 * 12; Speed: 400; Since: 1950),
    // #2
    (Name: 'Rotor JG'; Passengers: 30; Mail: 4; Cost: 24000;
    RunningCost: 140 * 12; Speed: 420; Since: 1950),
    // #3
    (Name: 'Raxton ML'; Passengers: 35; Mail: 5; Cost: 27000;
    RunningCost: 150 * 12; Speed: 450; Since: 1955),
    // #4
    (Name: 'Tornado S9'; Passengers: 45; Mail: 5; Cost: 30000;
    RunningCost: 160 * 12; Speed: 500; Since: 1965),
    // #5
    (Name: 'ExOA-H7'; Passengers: 55; Mail: 7; Cost: 33000;
    RunningCost: 170 * 12; Speed: 700; Since: 1970),
    // #6
    (Name: 'AIN D88'; Passengers: 75; Mail: 7; Cost: 35000;
    RunningCost: 180 * 12; Speed: 800; Since: 1980),
    // #7
    (Name: 'HeWi C4'; Passengers: 100; Mail: 8; Cost: 38000;
    RunningCost: 190 * 12; Speed: 850; Since: 1990),
    // #8
    (Name: 'UtBotS FL'; Passengers: 120; Mail: 10; Cost: 40000;
    RunningCost: 200 * 12; Speed: 900; Since: 2000),
    // #9
    (Name: 'Venus M2'; Passengers: 150; Mail: 12; Cost: 50000;
    RunningCost: 210 * 12; Speed: 1000; Since: 2020)
    //
    );

type

  { TAircraft }

  TAircraft = class(TVehicle)
  private
    FT: Integer;
    FState: string;
    FPassengers: Integer;
    FMaxPassengers: Integer;
    FMail: Integer;
    FMaxMail: Integer;
  public
    constructor Create(const AName: string; const AX, AY, ID: Integer);
    function Move(const AX, AY: Integer): Boolean; override;
    property Passengers: Integer read FPassengers write FPassengers;
    property MaxPassengers: Integer read FMaxPassengers;
    property Mail: Integer read FMail write FMail;
    property MaxMail: Integer read FMaxMail;
    property State: string read FState;
    procedure Step; override;
    procedure Load; override;
    procedure UnLoad; override;
    procedure AddOrder(const AIndex: Integer); overload;
  end;

implementation

uses
  SysUtils,
  TransportTycoon.Map,
  TransportTycoon.Game,
  TransportTycoon.Finances,
  TransportTycoon.PathFind,
  TransportTycoon.Industries;

{ TAircraft }

function IsPath(X, Y: Integer): Boolean; stdcall;
begin
  Result := True;
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
  FMaxMail := AircraftBase[ID].Mail;
  FMail := 0;
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
  while (Game.Map.Industry[Order[OrderIndex].ID].ProducesAmount[cgMail] > 0) and
    (Mail < MaxMail) do
  begin
    Game.Map.Industry[Order[OrderIndex].ID].DecCargoAmount(cgMail);
    Inc(FMail);
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

procedure TAircraft.Step;
begin
  if Length(Order) > 0 then
  begin
    if not Move(Order[OrderIndex].X, Order[OrderIndex].Y) then
    begin
      Inc(FT);
      if Order[OrderIndex].ID <> LastStationId then
        UnLoad;
      FState := 'Service';
      if FT > (15 - (TTownIndustry(Game.Map.Industry[Order[OrderIndex].ID])
        .Airport.Level * 2)) then
      begin
        FT := 0;
        Load;
        IncOrder;
      end;
    end
    else
      IncDistance;
  end;
end;

procedure TAircraft.UnLoad;
var
  M: Integer;
begin
  SetLastStation;
  FState := 'Unload';
  if Passengers > 0 then
  begin
    M := (Passengers * (Distance div 10)) * 7;
    Game.ModifyMoney(ttAircraftIncome, M);
    Passengers := 0;
  end;
  if Mail > 0 then
  begin
    M := (Mail * (Distance div 7)) * 8;
    Game.ModifyMoney(ttAircraftIncome, M);
    Mail := 0;
  end;
  Distance := 0;
end;

end.
