unit TransportTycoon.Map;

interface

uses
  TransportTycoon.Town,
  TransportTycoon.Industries;

type
  Tiles = (tlGrass, tlDirt, tlTree, tlSmallTree, tlBush, tlTown, tlRock, tlSand,
    tlWater, tlTownIndustry, tlForestIndustry, tlSawmillIndustry,
    tlCoalMineIndustry, tlPowerPlantIndustry);

const
  NormalTiles = [tlGrass, tlDirt, tlSand];
  TreeTiles = [tlTree, tlSmallTree, tlBush];
  IndustryTiles = [tlForestIndustry, tlSawmillIndustry, tlCoalMineIndustry,
    tlPowerPlantIndustry];

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
    (Name: 'Oak'; Tile: 'f'; Color: 'green'),
    //
    (Name: 'Pine'; Tile: 't'; Color: 'dark green'),
    //
    (Name: 'Bush'; Tile: 'b'; Color: 'dark green'),
    //
    (Name: 'Town'; Tile: '#'; Color: 'lighter yellow'),
    //
    (Name: 'Rock'; Tile: '^'; Color: 'dark gray'),
    //
    (Name: 'Sand'; Tile: ':'; Color: 'yellow'),
    //
    (Name: 'Water'; Tile: '='; Color: 'blue'),
    //
    (Name: 'Town'; Tile: '&'; Color: 'lighter yellow'),
    //
    (Name: 'Forest'; Tile: 'F'; Color: 'lighter yellow'),
    //
    (Name: 'Sawmill'; Tile: 'S'; Color: 'lighter yellow'),
    //
    (Name: 'Coal Mine'; Tile: 'C'; Color: 'lighter yellow'),
    //
    (Name: 'Power Plant'; Tile: 'P'; Color: 'lighter yellow')
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
  MapNoOfInd: array [TMapNoOfInd] of Integer = (1, 2, 3, 5);

type

  { TMap }

  TMap = class(TObject)
  private
    FNoOfInd: TMapNoOfInd;
    FTop: Word;
    FWidth: Word;
    FHeight: Word;
    FLeft: Word;
    FCurrentTown: Integer;
    FNoOfTowns: Integer;
    FRivers: TMapRivers;
    FSeaLevel: TMapSeaLevel;
    FSize: TMapSize;
    FCurrentIndustry: Integer;
    function HasIndustryLocation(const AX, AY: Integer): Boolean;
    function HasTownLocation(const AX, AY: Integer): Boolean;
    function HasNormalTile(const AX, AY: Integer): Boolean;
    procedure AddSpot(const AX, AY: Integer; const ATile: Tiles);
    procedure AddTree(const AX, AY: Integer);
    procedure Resize;
    function SizeCoef: Integer;
    function MapIndCount: Integer;
  public
    Cell: array of array of Tiles;
    Town: array of TTown;
    Industry: array of TIndustry;
    constructor Create;
    destructor Destroy; override;
    property Top: Word read FTop write FTop;
    property Left: Word read FLeft write FLeft;
    property Height: Word read FHeight;
    property Width: Word read FWidth;
    property CurrentTown: Integer read FCurrentTown write FCurrentTown;
    property CurrentIndustry: Integer read FCurrentIndustry
      write FCurrentIndustry;
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
    function GetCurrentTown(const AX, AY: Integer): Integer;
    function GetCurrentIndustry(const AX, AY: Integer): Integer;
    function EnterInCity(const AX, AY: Integer): Boolean;
    function EnterInIndustry(const AX, AY: Integer): Boolean;
    function WorldPop: Integer;
    function GetDist(const X1, Y1, X2, Y2: Integer): Integer;
    procedure NextNoOfInd;
    procedure NextNoOfTowns;
    procedure NextSeaLevel;
    procedure NextRivers;
    procedure NextSize;
    procedure ClearLand(const AX, AY: Integer);
    function GetNearTownName(const AX, AY: Integer): string;
    function IsNearTile(const AX, AY: Integer; const ATile: Tiles): Boolean;
    function EnterInTown(const AX, AY: Integer): Boolean;
  end;

implementation

uses
  Math,
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Game,
  TransportTycoon.Finances;

{ TMap }

function TMap.HasTownName(const ATownName: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Length(Town) - 1 do
    if Town[I].Name = ATownName then
    begin
      Result := True;
      Exit;
    end;
end;

function TMap.IsNearTile(const AX, AY: Integer; const ATile: Tiles): Boolean;
var
  X, Y: Integer;
begin
  Result := False;
  for X := AX - 1 to AX + 1 do
    for Y := AY - 1 to AY + 1 do
    begin
      if (X = AX) and (Y = AY) then
        Continue;
      if (Cell[AX][AY] = ATile) then
        Exit(True);
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

function TMap.MapIndCount: Integer;
begin
  Result := MapNoOfInd[NoOfInd];
  if (Size = msTiny) then
    Result := MapNoOfInd[niVeryLow];
  if (Size = msSmall) then
    Result := MapNoOfInd[niLow];
end;

function TMap.HasNormalTile(const AX, AY: Integer): Boolean;
begin
  Result := Cell[AX][AY] in NormalTiles;
end;

function TMap.HasIndustryLocation(const AX, AY: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Length(Industry) - 1 do
    if ((Industry[I].X = AX) and (Industry[I].Y = AY)) or
      (GetDist(Industry[I].X, Industry[I].Y, AX, AY) < (Self.Width div 10)) then
      Exit(True);
end;

function TMap.HasTownLocation(const AX, AY: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Length(Town) - 1 do
    if ((Town[I].X = AX) and (Town[I].Y = AY)) or
      (GetDist(Town[I].X, Town[I].Y, AX, AY) < 15) then
      Exit(True);
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
  for I := 0 to Length(Town) - 1 do
    Town[I].Free;
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

procedure TMap.ClearLand(const AX, AY: Integer);
begin
  if (Cell[AX][AY] in TreeTiles) then
    if (Game.Money >= 100) then
    begin
      Cell[AX][AY] := tlDirt;
      Game.ModifyMoney(ttConstruction, -100);
    end;
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
  FCurrentTown := GetCurrentCity(AX, AY);
  Result := FCurrentTown >= 0;
end;

function TMap.EnterInIndustry(const AX, AY: Integer): Boolean;
begin
  FCurrentIndustry := GetCurrentIndustry(AX, AY);
  Result := FCurrentIndustry >= 0;
end;

function TMap.EnterInTown(const AX, AY: Integer): Boolean;
begin
  FCurrentTown := GetCurrentTown(AX, AY);
  Result := FCurrentTown >= 0;
end;

procedure TMap.Gen;
var
  X, Y, I, J, N, D: Integer;
  TownName, S: string;
  IndustryType: TIndustryType;
begin
  // Terrain
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
  // Towns
  for I := 0 to Length(Town) - 1 do
    Town[I].Free;
  SetLength(Town, 0);
  for I := 0 to MapNoOfTownsInt[NoOfTowns] - 1 do
  begin
    repeat
      X := (Math.RandomRange(1, FWidth div 10) * 10) +
        (Math.RandomRange(0, 10) - 5);
      Y := (Math.RandomRange(1, FHeight div 10) * 10) +
        (Math.RandomRange(0, 10) - 5);
      TownName := TTown.GenName;

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
    Cell[X][Y] := tlTown;
    SetLength(Town, I + 1);
    Town[I] := TTown.Create(TownName, X, Y);
  end;
  // Industries
  I := 0;
  for J := 0 to MapIndCount - 1 do
  begin
    for IndustryType := Succ(Low(TIndustryType)) to High(TIndustryType) do
    begin
      repeat
        X := (Math.RandomRange(1, FWidth div 10) * 10) +
          (Math.RandomRange(0, 10) - 5);
        Y := (Math.RandomRange(1, FHeight div 10) * 10) +
          (Math.RandomRange(0, 10) - 5);
      until HasNormalTile(X, Y) and not HasTownLocation(X, Y) and
        not HasIndustryLocation(X, Y);
      if IndustryType = inNone then
        Continue;
      case IndustryType of
        inTown:
          begin
            S := TTown.GenName;;
            SetLength(Industry, I + 1);
            Cell[X][Y] := tlTownIndustry;
            Industry[I] := TTownIndustry.Create(S, X, Y);
            Inc(I);
          end;
        inCoalMine:
          begin
            S := GetNearTownName(X, Y);
            SetLength(Industry, I + 1);
            Cell[X][Y] := tlCoalMineIndustry;
            Industry[I] := TCoalMineIndustry.Create(S, X, Y);
            Inc(I);
          end;
        inPowerPlant:
          begin
            S := GetNearTownName(X, Y);
            SetLength(Industry, I + 1);
            Cell[X][Y] := tlPowerPlantIndustry;
            Industry[I] := TPowerPlantIndustry.Create(S, X, Y);
            Inc(I);
          end;
        inForest:
          begin
            S := GetNearTownName(X, Y);
            SetLength(Industry, I + 1);
            Cell[X][Y] := tlForestIndustry;
            Industry[I] := TForestIndustry.Create(S, X, Y);
            Inc(I);
          end;
        inSawmill:
          begin
            S := GetNearTownName(X, Y);
            SetLength(Industry, I + 1);
            Cell[X][Y] := tlSawmillIndustry;
            Industry[I] := TSawmillIndustry.Create(S, X, Y);
            Inc(I);
          end;
      end;
    end;
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
  for I := 0 to Length(Town) - 1 do
    Town[I].Grow;
end;

function TMap.GetCurrentCity(const AX, AY: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Length(Town) - 1 do
    if (Town[I].X = AX) and (Town[I].Y = AY) then
      Exit(I);
end;

function TMap.GetCurrentIndustry(const AX, AY: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Length(Industry) - 1 do
    if (Industry[I].X = AX) and (Industry[I].Y = AY) then
      Exit(I);
end;

function TMap.GetCurrentTown(const AX, AY: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Length(Industry) - 1 do
    if (Industry[I].X = AX) and (Industry[I].Y = AY) and
      (Industry[I].IndustryType = inTown) then
      Exit(I);
end;

function TMap.WorldPop: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Length(Town) - 1 do
    Result := Result + Town[I].Population;
end;

function TMap.GetDist(const X1, Y1, X2, Y2: Integer): Integer;
begin
  Result := Round(Sqrt(Sqr(X2 - X1) + Sqr(Y2 - Y1)));
end;

function TMap.GetNearTownName(const AX, AY: Integer): string;
var
  I, D, Mx: Integer;
begin
  Mx := Width div 2;
  Result := '';
  for I := 0 to Length(Town) - 1 do
  begin
    D := GetDist(Town[I].X, Town[I].Y, AX, AY);
    if D < Mx then
    begin
      Result := Town[I].Name;
      Mx := D;
    end;
  end;
end;

end.
