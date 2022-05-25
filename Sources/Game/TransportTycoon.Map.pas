unit TransportTycoon.Map;

interface

type
  Tiles = (tlGrass);

type
  TTile = record
    Tile: Char;
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
  MapSizeInt: array [TMapSize] of Integer = (64, 128, 256, 512);

type

  { TMap }

  TMap = class(TObject)
  private
    FWidth: Word;
    FHeight: Word;
  public
    Cell: array of array of TCell;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Draw(const AWidth, AHeight: Integer);
    procedure Gen;
  end;

implementation

uses
  BearLibTerminal;


{ TMap }

constructor TMap.Create;
begin

end;

destructor TMap.Destroy;
begin

  inherited Destroy;
end;

procedure TMap.Clear;
begin

end;

procedure TMap.Draw(const AWidth, AHeight: Integer);
var
  X, Y: Integer;
begin
  for Y := 0 to AHeight - 1 do
    for X := 0 to AWidth - 1 do
      terminal_print(X, Y, Cell[X][Y].Tile.Tile);
end;

procedure TMap.Gen;
begin
  Self.Clear;
end;

end.
