﻿unit TransportTycoon.Map;

interface

uses
  TransportTycoon.City;

type
  Tiles = (tlGrass, tlDirt, tlTree, tlSmallTree, tlBush, tlCity);

type
  TTile = record
    Name: string;
    Tile: Char;
    Color: string;
  end;

const
  Tile: array [Tiles] of TTile = (
    //
    (Name: 'Grass'; Tile: '"'; Color: 'green'),
    //
    (Name: 'Dirt'; Tile: ':'; Color: 'darker yellow'),
    //
    (Name: 'Tree'; Tile: 'T'; Color: 'green'),
    //
    (Name: 'Small Tree'; Tile: 't'; Color: 'dark green'),
    //
    (Name: 'Bush'; Tile: 'b'; Color: 'dark green'),
    //
    (Name: 'City'; Tile: '#'; Color: 'lighter yellow')
    //
    );

type
  TCell = record
    Tile: TTile;
  end;

type
  TMapSize = (msTiny, msSmall, msMedium, msLarge);

const
  MapSizeStr: array [TMapSize] of string = ('Tiny', 'Small', 'Medium', 'Large');
  MapSizeInt: array [TMapSize] of Integer = (80, 160, 320, 640);
  MapNoOfTownsStr: array [1 .. 4] of string = ('Very Low', 'Low',
    'Normal', 'High');
  MapNoOfTownsInt: array [1 .. 4] of Byte = (2, 3, 5, 7);

type

  { TMap }

  TMap = class(TObject)
  private
    FTop: Word;
    FWidth: Word;
    FHeight: Word;
    FLeft: Word;
  public
    Size: TMapSize;
    NoOfTowns: Byte;
    Cell: array [0 .. 79, 0 .. 79] of Tiles;
    City: array of TCity;
    CurrentCity: Byte;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Draw(const AWidth, AHeight: Integer);
    procedure Gen;
    property Top: Word read FTop write FTop;
    property Left: Word read FLeft write FLeft;
    property Height: Word read FHeight;
    function GetCurrentCity(const AX, AY: Integer): ShortInt;
    function EnterInCity(const AX, AY: Integer): Boolean;
  end;

implementation

uses
  Math,
  SysUtils,
  BearLibTerminal;

constructor TMap.Create;
begin
  Self.Size := msTiny;
  FWidth := 80;
  FHeight := 80;
  NoOfTowns := 1;
end;

destructor TMap.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(City) - 1 do
    City[I].Free;

  inherited Destroy;
end;

procedure TMap.Clear;
var
  X, Y: Integer;
begin
  FTop := 0;
  FLeft := 0;
  for Y := 0 to FHeight - 1 do
    for X := 0 to FWidth - 1 do
      Cell[X][Y] := tlGrass;
end;

procedure TMap.Draw(const AWidth, AHeight: Integer);
var
  X, Y: Integer;
begin
  terminal_bkcolor('darkest gray');
  for Y := 0 to AHeight - 1 do
    for X := 0 to AWidth - 1 do
    begin
      terminal_color(Tile[Cell[X][Top + Y]].Color);
      terminal_put(X, Y, Tile[Cell[X][Top + Y]].Tile);
    end;
  terminal_color('white');
end;

function TMap.EnterInCity(const AX, AY: Integer): Boolean;
begin
  CurrentCity := GetCurrentCity(AX, AY);
  Result := CurrentCity >= 0;
end;

procedure TMap.Gen;
var
  X, Y, I: Integer;
begin
  Self.Clear;
  for Y := 0 to FHeight - 1 do
    for X := 0 to FWidth - 1 do
    begin
      case Math.RandomRange(0, 15) of
        0:
          Cell[X][Y] := tlDirt;
        1:
          Cell[X][Y] := tlTree;
        2:
          Cell[X][Y] := tlSmallTree;
        3:
          Cell[X][Y] := tlBush;
      else
        Cell[X][Y] := tlGrass;
      end;
    end;
  //
  for I := 0 to MapNoOfTownsInt[NoOfTowns] - 1 do
  begin
    X := Math.RandomRange(1, 78);
    Y := Math.RandomRange(1, 78);
    Cell[X][Y] := tlCity;
    SetLength(City, I + 1);
    City[I] := TCity.Create(TownNameStr[I], X, Y);
  end;
end;

function TMap.GetCurrentCity(const AX, AY: Integer): ShortInt;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Length(City) - 1 do
    if (City[I].X = AX) and (City[I].X = AX) then
    begin
      Result := I;
      Exit;
    end;
end;

end.
