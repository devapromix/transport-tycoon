unit TransportTycoon.Map;

interface

type
  Tiles = (tlGrass, tlDirt, tlTree, tlSmallTree, tlBush);

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
    (Name: 'Dirt'; Tile: '.'; Color: 'red'),
    //
    (Name: 'Tree'; Tile: 'T'; Color: 'green'),
    //
    (Name: 'Small Tree'; Tile: 't'; Color: 'green'),
    //
    (Name: 'Bush'; Tile: 'b'; Color: 'green')
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

type

  { TMap }

  TMap = class(TObject)
  private
    FTop: Word;
    FWidth: Word;
    FHeight: Word;
  public
    Cell: array [0 .. 79, 0 .. 79] of Tiles;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Draw(const AWidth, AHeight: Integer);
    procedure Gen;
    property Top: Word read FTop write FTop;
  end;

implementation

uses
  Math,
  BearLibTerminal;

{ TMap }

constructor TMap.Create;
begin
  FWidth := 80;
  FHeight := 80;
end;

destructor TMap.Destroy;
begin

  inherited Destroy;
end;

procedure TMap.Clear;
var
  X, Y: Integer;
begin
  FTop := 0;
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
end;

procedure TMap.Draw(const AWidth, AHeight: Integer);
var
  X, Y: Integer;
begin
  for Y := 0 to AHeight - 1 do
    for X := 0 to AWidth - 1 do
    begin
      terminal_color(Tile[Cell[X][Top + Y]].Color);
      terminal_bkcolor('darkest ' + Tile[Cell[X][Top + Y]].Color);
      terminal_print(X, Y, Tile[Cell[X][Top + Y]].Tile);
    end;
end;

procedure TMap.Gen;
begin
  Self.Clear;
end;

end.
