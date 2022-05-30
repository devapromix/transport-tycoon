unit TransportTycoon.Map;

interface

type
  Tiles = (tlGrass);

type
  TTile = record
    Tile: char;
    Color: string;
  end;

const
  Tile: array [Tiles] of TTile = (
    (Tile: '"'; Color: 'dark green')
    );

type
  TCell = record
    Tile: TTile;
  end;

type
  TMapSize = (msTiny, msSmall, msMedium, msLarge);

const
  MapSizeStr: array [TMapSize] of string = ('Tiny', 'Small', 'Medium', 'Large');
  MapSizeInt: array [TMapSize] of integer = (64, 128, 256, 512);

type

  { TMap }

  TMap = class(TObject)
  private
    FWidth: word;
    FHeight: word;
  public
    Cell: array [0..79, 0..19] of Tiles;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Draw(const AWidth, AHeight: integer);
    procedure Gen;
  end;

implementation

uses
  BearLibTerminal;


{ TMap }

constructor TMap.Create;
begin
  FWidth := 80;
  FHeight := 20;
end;

destructor TMap.Destroy;
begin

  inherited Destroy;
end;

procedure TMap.Clear;
var
  X, Y: integer;
begin
  for Y := 0 to FHeight - 1 do
    for X := 0 to FWidth - 1 do
      Cell[X][Y] := tlGrass;
end;

procedure TMap.Draw(const AWidth, AHeight: integer);
var
  X, Y: integer;
begin
  for Y := 0 to AHeight - 1 do
    for X := 0 to AWidth - 1 do
      terminal_print(X, Y, Tile[Cell[X][Y]].Tile);
end;

procedure TMap.Gen;
begin
  Self.Clear;
end;

end.
