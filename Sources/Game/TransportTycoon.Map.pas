unit TransportTycoon.Map;

interface

uses
  TransportTycoon.City;

type
  Tiles = (tlGrass, tlDirt, tlTree, tlSmallTree, tlBush, tlCity, tlRock,
    tlSand, tlWater);

const
  AllTiles = [tlGrass, tlDirt, tlTree, tlSmallTree, tlBush, tlCity, tlRock,
    tlSand, tlWater];
  NormalTiles = [tlGrass, tlDirt, tlSand];

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
    (Name: 'Rock'; Tile: '^'; Color: 'dark gray'),
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
  TMapSeaLevel = (msVeryLow, msLow, msNormal, msHigh);
  TMapNoOfTowns = (ntVeryLow, ntLow, ntNormal, ntHigh);
  TMapNoOfInd = (niVeryLow, niLow, niNormal, niHigh);
  TMapRivers = (mrNone, mrFew, mrMedium, mrMany);

const
  MapSizeStr: array [TMapSize] of string = ('Tiny', 'Small', 'Medium', 'Large');
  MapSizeInt: array [TMapSize] of Integer = (80, 160, 320, 640);
  MapSeaLevelStr: array [TMapSeaLevel] of string = ('Very Low', 'Low',
    'Normal', 'High');
  MapNoOfIndStr: array [TMapNoOfInd] of string = ('Very Low', 'Low',
    'Normal', 'High');
  MapRiversStr: array [TMapRivers] of string = ('None', 'Few',
    'Medium', 'Many');
  MapNoOfTownsStr: array [1 .. 4] of string = ('Very Low', 'Low',
    'Normal', 'High');
  MapNoOfTownsInt: array [1 .. 4] of Integer = (3, 5, 8, 11);

type
  TMap = class(TObject)
  private
    FTop: Word;
    FWidth: Word;
    FHeight: Word;
    FLeft: Word;
    FCurrentCity: Integer;
    FNoOfInd: TMapNoOfInd;
    FNoOfTowns: Integer;
    FRivers: TMapRivers;
    FSeaLevel: TMapSeaLevel;
    FSize: TMapSize;
    function HasTownLocation(const AX, AY: Integer): Boolean;
    function HasNormalTile(const AX, AY: Integer): Boolean;
    procedure AddSpot(const AX, AY: Integer; const ATile: Tiles);
    procedure AddTree(const AX, AY: Integer);
    procedure Resize;
    function SizeCoef: Integer;
  public
    Cell: array of array of Tiles;
    City: array of TCity;
    constructor Create;
    destructor Destroy; override;
    property Top: Word read FTop write FTop;
    property Left: Word read FLeft write FLeft;
    property Height: Word read FHeight;
    property Width: Word read FWidth;
    property CurrentCity: Integer read FCurrentCity write FCurrentCity;
    property Size: TMapSize read FSize write FSize;
    property SeaLevel: TMapSeaLevel read FSeaLevel write FSeaLevel;
    property Rivers: TMapRivers read FRivers write FRivers;
    property NoOfTowns: Integer read FNoOfTowns write FNoOfTowns;
    property NoOfInd: TMapNoOfInd read FNoOfInd write FNoOfInd;
    procedure Clear;
    function HasTownName(const ATownName: string): Boolean;
    procedure Draw(const AWidth, AHeight: Integer);
    procedure Gen;
    procedure CityGrows;
    function GetCurrentCity(const AX, AY: Integer): Integer;
    function EnterInCity(const AX, AY: Integer): Boolean;
    function WorldPop: Integer;
    function GetDist(const X1, Y1, X2, Y2: Integer): Integer;
    procedure NextNoOfInd;
    procedure NextNoOfTowns;
    procedure NextSeaLevel;
    procedure NextRivers;
    procedure NextSize;
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

procedure TMap.NextNoOfInd;
begin
  Inc(FNoOfInd);
  if (FNoOfInd > niHigh) then
    FNoOfInd := niVeryLow;
end;

procedure TMap.NextNoOfTowns;
begin
  Inc(FNoOfTowns);
  if (FNoOfTowns > 4) then
    FNoOfTowns := 1;
end;

procedure TMap.NextRivers;
begin
  Inc(FRivers);
  if (FRivers > mrMany) then
    FRivers := mrNone;
end;

procedure TMap.NextSeaLevel;
begin
  Inc(FSeaLevel);
  if (FSeaLevel > msHigh) then
    FSeaLevel := msVeryLow;
end;

procedure TMap.NextSize;
begin
  Inc(FSize);
  if (FSize > msLarge) then
    FSize := msTiny;
end;

procedure TMap.Resize;
begin
  FTop := 0;
  FLeft := 0;
  FWidth := MapSizeInt[Size];
  FHeight := MapSizeInt[Size];
  SetLength(Cell, FWidth, FHeight);
end;

function TMap.SizeCoef: Integer;
begin
  Result := (Ord(Size) + 1) * (Ord(Size) + 1);
end;

function TMap.HasNormalTile(const AX, AY: Integer): Boolean;
begin
  Result := Cell[AX][AY] in NormalTiles;
end;

function TMap.HasTownLocation(const AX, AY: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Length(City) - 1 do
    if ((City[I].X = AX) and (City[I].Y = AY)) or
      (GetDist(City[I].X, City[I].Y, AX, AY) < 15) then
    begin
      Result := True;
      Exit;
    end;
end;

constructor TMap.Create;
begin
  FSize := msTiny;
  FSeaLevel := msVeryLow;
  FNoOfTowns := 1;
  FRivers := mrNone;
  FNoOfInd := niVeryLow;
  Resize;
end;

destructor TMap.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(City) - 1 do
    City[I].Free;
  inherited;
end;

procedure TMap.Clear;
var
  X, Y: Integer;
begin
  Resize;
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
      terminal_color(Tile[Cell[Left + X][Top + Y]].Color);
      terminal_put(X, Y, Tile[Cell[Left + X][Top + Y]].Tile);
    end;
  terminal_color('white');
end;

function TMap.EnterInCity(const AX, AY: Integer): Boolean;
begin
  FCurrentCity := GetCurrentCity(AX, AY);
  Result := FCurrentCity >= 0;
end;

procedure TMap.Gen;
var
  X, Y, I, J, N, D: Integer;
  TownName: string;
begin
  Self.Clear;
  D := 0;
  if (SeaLevel >= msNormal) then
    D := 5 + SizeCoef;
  for Y := 0 to FHeight - 1 do
  begin
    for X := 0 to FWidth - 1 do
    begin
      case Math.RandomRange(0, 15) of
        0:
          Cell[X][Y] := tlDirt;
        1:
          Cell[X][Y] := tlSand;
        2:
          Cell[X][Y] := tlRock;
        3 .. 6:
          AddTree(X, Y);
      else
        Cell[X][Y] := tlGrass;
      end;
    end;
    if (SeaLevel > msVeryLow) then
    begin
      J := Math.RandomRange(0, 4) + Math.RandomRange(0, 2) + D;
      for X := 0 to J do
        Cell[X][Y] := tlWater;
      J := Math.RandomRange(0, 4) + Math.RandomRange(0, 2) + D;
      for X := FWidth - 1 downto FWidth - J - 1 do
        Cell[X][Y] := tlWater;
    end;
  end;
  for I := 0 to 14 do
  begin
    X := Math.RandomRange((SizeCoef + 10), FWidth - (SizeCoef + 10));
    Y := Math.RandomRange((SizeCoef + 10), FWidth - (SizeCoef + 10));
    case RandomRange(0, 4) of
      0:
        AddSpot(X, Y, tlDirt);
      1:
        AddSpot(X, Y, tlRock);
      2:
        AddSpot(X, Y, tlWater);
    else
      AddSpot(X, Y, tlSand);
    end;
  end;
  if (SeaLevel > msVeryLow) then
  begin
    for X := 0 to FWidth - 1 do
    begin
      J := Math.RandomRange(0, 4) + Math.RandomRange(0, 2) + D;
      for Y := 0 to J do
        Cell[X][Y] := tlWater;
      J := Math.RandomRange(0, 4) + Math.RandomRange(0, 2) + D;
      for Y := FHeight - 1 downto FHeight - J - 1 do
        Cell[X][Y] := tlWater;
    end;
    D := SizeCoef * 9;
    if (SeaLevel = msHigh) then
      D := SizeCoef * 25;
    if (SeaLevel >= msNormal) then
    begin
      for I := 0 to D do
      begin
        X := Math.RandomRange(10, FWidth - 11);
        Y := Math.RandomRange(10, FWidth - 11);
        AddSpot(X, Y, tlWater);
      end;
    end;
    for Y := 1 to FHeight - 2 do
    begin
      for X := 1 to FWidth - 2 do
      begin
        if (Cell[X][Y] <> tlWater) and
          (((Cell[X + 1][Y] = tlWater) and (Cell[X - 1][Y] = tlWater)) or
          ((Cell[X][Y + 1] = tlWater) and (Cell[X][Y - 1] = tlWater))) then
          Cell[X][Y] := tlWater;
      end;
    end;
    //
    for Y := 1 to FHeight - 2 do
    begin
      for X := 1 to FWidth - 2 do
      begin
        if (Cell[X][Y] <> tlWater) and
          (((Cell[X + 1][Y] = tlWater) and (Cell[X - 1][Y] = tlWater) and
          (Cell[X][Y + 1] = tlWater) and (Cell[X][Y - 1] = tlWater))) then
          Cell[X][Y] := tlWater;
      end;
    end;
  end;
  //
  for I := 0 to Length(City) - 1 do
    City[I].Free;
  SetLength(City, 0);
  for I := 0 to MapNoOfTownsInt[NoOfTowns] - 1 do
  begin
    repeat
      X := (Math.RandomRange(1, FWidth div 10) * 10) +
        (Math.RandomRange(0, 10) - 5);
      Y := (Math.RandomRange(1, FHeight div 10) * 10) +
        (Math.RandomRange(0, 10) - 5);
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

    until not HasTownName(TownName) and not HasTownLocation(X, Y) and
      HasNormalTile(X, Y);
    Cell[X][Y] := tlCity;
    SetLength(City, I + 1);
    City[I] := TCity.Create(TownName, X, Y);
  end;
end;

procedure TMap.AddSpot(const AX, AY: Integer; const ATile: Tiles);
var
  VSize, I, VX, VY: Integer;
begin
  VX := AX;
  VY := AY;
  VSize := RandomRange(100, 300) * SizeCoef;
  for I := 0 to VSize do
  begin
    if (RandomRange(0, 6) = 0) and (VX > (SizeCoef + 10)) then
    begin
      VX := VX - 1;
      Cell[VX][VY] := ATile;
    end;
    if (RandomRange(0, 6) = 0) and (VX < FWidth - (SizeCoef + 10)) then
    begin
      VX := VX + 1;
      Cell[VX][VY] := ATile;
    end;
    if (RandomRange(0, 6) = 0) and (VY > (SizeCoef + 10)) then
    begin
      VY := VY - 1;
      Cell[VX][VY] := ATile;
    end;
    if (RandomRange(0, 6) = 0) and (VY < FHeight - (SizeCoef + 10)) then
    begin
      VY := VY + 1;
      Cell[VX][VY] := ATile;
    end;
  end;

end;

procedure TMap.AddTree(const AX, AY: Integer);
begin
  case RandomRange(0, 4) of
    0:
      Cell[AX][AY] := tlTree;
    1:
      Cell[AX][AY] := tlSmallTree;
  else
    Cell[AX][AY] := tlBush;
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
      Exit(I);
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
