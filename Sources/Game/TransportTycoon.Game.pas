﻿unit TransportTycoon.Game;

interface

uses
  Classes,
  SysUtils,
  TransportTycoon.Map,
  TransportTycoon.Vehicles;

const
  MonStr: array [1 .. 12] of string = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');

type
  TGame = class(TObject)
  private
    FMoney: Integer;
    FCompanyName: string;
  public
    IsClearLand: Boolean;
    IsPause: Boolean;
    IsGame: Boolean;
    Map: TMap;
    Turn: Integer;
    Day: Byte;
    Month: Byte;
    Year: Word;
    Vehicles: TVehicles;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Step;
    procedure New;
    property Money: Integer read FMoney;
    procedure ModifyMoney(const AMoney: Integer);
    procedure CityGrow;
    property CompanyName: string read FCompanyName;
  end;

var
  Game: TGame;

implementation

uses
  Math,
  TransportTycoon.City;

{ TGame }

constructor TGame.Create;
begin
  IsClearLand := False;
  IsPause := True;
  Self.New;
  Year := 1950;
  Map := TMap.Create;
  Map.Gen;
  Vehicles := TVehicles.Create;
end;

destructor TGame.Destroy;
begin
  Map.Free;
  Vehicles.Free;
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

  Vehicles.Step;
end;

procedure TGame.Clear;
begin
  Self.New;
  IsGame := True;
  IsClearLand := False;
  Turn := 0;
  FMoney := 100000;
  Map.Gen;
  FCompanyName := TownNameStr[Math.RandomRange(0, Length(Map.City))] +
    ' TRANSPORT';
end;

initialization

Game := TGame.Create;

finalization

Game.Free;

end.
