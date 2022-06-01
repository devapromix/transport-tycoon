unit TransportTycoon.Game;

interface

uses
  Classes,
  SysUtils,
  TransportTycoon.Map,
  TransportTycoon.Aircraft;

const
  MonStr: array [1 .. 12] of string = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');

type

  { TGame }

  TGame = class(TObject)
  private
    FMoney: Integer;
  public
    IsPause: Boolean;
    IsGame: Boolean;
    Map: TMap;
    Turn: Integer;
    Day: Byte;
    Month: Byte;
    Year: Word;
    Aircraft: array of TAircraft;
    Aircrafts: TAircrafts;

    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Step;
    procedure New;
    property Money: Integer read FMoney;
    procedure ModifyMoney(const AMoney: Integer);
    procedure CityGrow;
  end;

var
  Game: TGame;

implementation

uses
  Math;

{ TGame }

constructor TGame.Create;
begin
  IsPause := True;
  Self.New;
  Year := 1950;
  Aircrafts := TAircrafts.Create;
  Map := TMap.Create;
  Map.Gen;
end;

destructor TGame.Destroy;
begin
  Map.Free;
  Aircrafts.Free;
  inherited Destroy;
end;

procedure TGame.ModifyMoney(const AMoney: Integer);
begin
  FMoney := FMoney + AMoney;
end;

procedure TGame.New;
begin
  Day := 1;
  Month := 1;
end;

procedure TGame.CityGrow;
var
  I: Integer;
begin
  for I := 0 to Length(Map.City) - 1 do
    Map.City[I].Grow;
end;

procedure TGame.Step;
begin
  if not IsGame or IsPause then
    Exit;

  Inc(Turn);
  Inc(Day);
  if Day > 30 then
  begin
    Day := 1;
    Inc(Month);
    Self.CityGrow;
  end;
  if Month > 12 then
  begin
    Month := 1;
    Inc(Year);
  end;

end;

procedure TGame.Clear;
begin
  Self.New;
  IsGame := True;
  Turn := 0;
  FMoney := 100000;
  Map.Gen;
end;

initialization

Game := TGame.Create;

finalization

Game.Free;

end.
