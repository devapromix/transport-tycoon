unit TransportTycoon.Map;

interface

uses
  TransportTycoon.City;

type
  Tiles = (tlGrass, tlDirt, tlTree, tlSmallTree, tlBush, tlCity, tlSand,
    tlWater);

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
    (Name: 'City'; Tile: '#'; Color: 'lighter yellow'),
    //
    (Name: 'Sand'; Tile: ':'; Color: 'yellow'),
    //
    (Name: 'Water'; Tile: '='; Color: 'blue')
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
  MapNoOfTownsInt: array [1 .. 4] of Integer = (3, 5, 8, 11);

type

  { TMap }

  TMap = class(TObject)
  private
    FTop: Word;
    FWidth: Word;
    FHeight: Word;
    FLeft: Word;
    function HasTownName(const ATownName: string): Boolean;
    function HasTownLocation(const AX, AY: Integer): Boolean;
  public
    Size: TMapSize;
    NoOfTowns: Integer;
    Cell: array [0 .. 79, 0 .. 79] of Tiles;
    City: array of TCity;
    CurrentCity: Integer;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Draw(const AWidth, AHeight: Integer);
    procedure Gen;
    procedure CityGrows;
    property Top: Word read FTop write FTop;
    property Left: Word read FLeft write FLeft;
    property Height: Word read FHeight;
    function GetCurrentCity(const AX, AY: Integer): Integer;
    function EnterInCity(const AX, AY: Integer): Boolean;
    function WorldPop: Integer;
    function GetDist(const X1, Y1, X2, Y2: Integer): Integer;
  end;

implementation

uses
  Math,
  SysUtils,
  BearLibTerminal;

function TMap.HasTownName(const ATownName: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Length(City) - 1 do
    if City[I].Name = ATownName then
    begin
      Result := True;
      Exit;
    end;
end;

function TMap.HasTownLocation(const AX, AY: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Length(City) - 1 do
    if ((City[I].X = AX) and (City[I].Y = AY))
      or (GetDist(City[I].X, City[I].Y, AX, AY) < 15) then
    begin
      Result := True;
      Exit;
    end;
end;

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
  X, Y, I, J, N: Integer;
  TownName: string;
begin
  Self.Clear;
  for Y := 0 to FHeight - 1 do
  begin
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
    J := Math.RandomRange(0, 4) + Math.RandomRange(0, 2);
    for X := 0 to J do
      Cell[X][Y] := tlWater;
    J := Math.RandomRange(0, 4) + Math.RandomRange(0, 2);
    for X := FWidth - 1 downto FWidth - J - 1 do
      Cell[X][Y] := tlWater;
  end;
  for X := 0 to FWidth - 1 do
  begin
    J := Math.RandomRange(0, 4) + Math.RandomRange(0, 2);
    for Y := 0 to J do
      Cell[X][Y] := tlWater;
    J := Math.RandomRange(0, 4) + Math.RandomRange(0, 2);
    for Y := FHeight - 1 downto FHeight - J - 1 do
      Cell[X][Y] := tlWater;
  end;
  //
  for Y := 1 to FHeight - 2 do
  begin
    for X := 1 to FWidth - 2 do
    begin
      if (Cell[X][Y] <> tlWater)  and (((Cell[X+1][Y] = tlWater)and(Cell[X-1][Y] = tlWater))
      or((Cell[X][Y+1] = tlWater)and(Cell[X][Y-1] = tlWater))
      ) then
        Cell[X][Y] := tlWater;
    end;
  end;
  //
  for Y := 1 to FHeight - 2 do
  begin
    for X := 1 to FWidth - 2 do
    begin
      if (Cell[X][Y] <> tlWater)  and (((Cell[X+1][Y] = tlWater)and(Cell[X-1][Y] = tlWater)
      and(Cell[X][Y+1] = tlWater)and(Cell[X][Y-1] = tlWater))
      ) then
        Cell[X][Y] := tlWater;
    end;
  end;
  //
  for I := 0 to MapNoOfTownsInt[NoOfTowns] - 1 do
  begin
    repeat
      X := (Math.RandomRange(1, FWidth div 10) * 10) + (Math.RandomRange(0, 10) - 5);
      Y := (Math.RandomRange(1, FHeight div 10) * 10) + (Math.RandomRange(0, 10) - 5);
      TownName := TCity.GenName;

      for N := 2 to 5 do
      begin
        if (Cell[X - N][Y] = tlWater) then
        begin
          X := X - (N - 1);
          Break;
        end;
        if (Cell[X + N][Y] = tlWater) then
        begin
          X := X + (N - 1);
          Break;
        end;
        if (Cell[X][Y - N] = tlWater) then
        begin
          Y := Y - (N - 1);
          Break;
        end;
        if (Cell[X][Y + N] = tlWater) then
        begin
          Y := Y + (N - 1);
          Break;
        end;
      end;

    until not HasTownName(TownName) and not HasTownLocation(X, Y);
    Cell[X][Y] := tlCity;
    SetLength(City, I + 1);
    City[I] := TCity.Create(TownName, X, Y);
  end;
end;

procedure TMap.CityGrows;
var
  I: Integer;
begin
  for I := 0 to Length(City) - 1 do
    City[I].Grow;
end;

function TMap.GetCurrentCity(const AX, AY: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Length(City) - 1 do
    if (City[I].X = AX) and (City[I].Y = AY) then
    begin
      Result := I;
      Exit;
    end;
end;

function TMap.WorldPop: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Length(City) - 1 do
    Result := Result + City[I].Population;
end;

function TMap.GetDist(const X1, Y1, X2, Y2: Integer): Integer;
begin
  Result := Round(Sqrt(Sqr(X2 - X1) + Sqr(Y2 - Y1)));
end;

end.
