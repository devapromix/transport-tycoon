﻿unit TransportTycoon.Game;

interface

uses
  Classes,
  SysUtils,
  TransportTycoon.Map;

const
  MonStr: array [1 .. 12] of string = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');

type

  { TGame }

  TGame = class(TObject)
  private

  public
    IsPause: Boolean;
    IsGame: Boolean;
    Map: TMap;
    Turn: Integer;
    Money: Integer;
    Day: Byte;
    Month: Byte;
    Year: Word;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Step;
    procedure New;
  end;

var
  Game: TGame;

implementation

{ TGame }

constructor TGame.Create;
begin
  IsPause := True;
  Self.New;
  Year := 1950;
  Map := TMap.Create;
end;

destructor TGame.Destroy;
begin
  Map.Free;
  inherited Destroy;
end;

procedure TGame.New;
begin
  Day := 1;
  Month := 1;
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
  Money := 100000;
  Map.Gen;
end;

initialization

Game := TGame.Create;

finalization

Game.Free;

end.
