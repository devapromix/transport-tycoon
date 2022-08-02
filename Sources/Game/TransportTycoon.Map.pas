unit TransportTycoon.Map;

interface

uses
  TransportTycoon.Industries;

type
  TTiles = (tlGrass, tlDirt, tlTree, tlSmallTree, tlBush, tlRock, tlSand,
    tlWater, tlCanal, tlRoad, tlTownIndustry, tlForestIndustry,
    tlSawmillIndustry, tlCoalMineIndustry, tlPowerPlantIndustry);

const
  LandTiles = [tlGrass, tlDirt, tlSand];
  TreeTiles = [tlTree, tlSmallTree, tlBush];
  IndustryTiles = [tlForestIndustry, tlSawmillIndustry, tlCoalMineIndustry,
    tlPowerPlantIndustry];

type
  TTile = record
    Name: string;
    Tile: Char;
    Color: string;
    BkColor: string;
  end;

const
  Tile: array [TTiles] of TTile = (
    //
    (Name: 'Grass'; Tile: '"'; Color: 'green'; BkColor: 'darkest green'),
    //
    (Name: 'Dirt'; Tile: ':'; Color: 'dark yellow'; BkColor: 'darkest yellow'),
    //
    (Name: 'Oak'; Tile: 'f'; Color: 'green'; BkColor: 'darkest green'),
    //
    (Name: 'Pine'; Tile: 't'; Color: 'dark green'; BkColor: 'darkest green'),
    //
    (Name: 'Bush'; Tile: 'b'; Color: 'dark green'; BkColor: 'darkest green'),
    //
    (Name: 'Rock'; Tile: '^'; Color: 'dark gray'; BkColor: 'darkest grey'),
    //
    (Name: 'Sand'; Tile: ':'; Color: 'white'; BkColor: 'darkest yellow'),
    //
    (Name: 'Water'; Tile: '='; Color: 'blue'; BkColor: 'darkest blue'),
    //
    (Name: 'Canal'; Tile: '='; Color: 'light blue'; BkColor: 'darkest blue'),
    //
    (Name: 'Road'; Tile: '*'; Color: 'light gray'; BkColor: 'darkest gray'),
    //
    (Name: 'Town'; Tile: '#'; Color: 'light yellow'; BkColor: 'darkest yellow'),
    //
    (Name: 'Forest'; Tile: 'F'; Color: 'light yellow';
    BkColor: 'darkest yellow'),
    //
    (Name: 'Sawmill'; Tile: 'S'; Color: 'light yellow';
    BkColor: 'darkest yellow'),
    //
    (Name: 'Coal Mine'; Tile: 'C'; Color: 'light yellow';
    BkColor: 'darkest yellow'),
    //
    (Name: 'Power Plant'; Tile: 'P'; Color: 'light yellow';
    BkColor: 'darkest yellow')
    //
    );

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
    FLastColor: string;
    FLastBkColor: string;
    FNoOfTowns: Integer;
    FRivers: TMapRivers;
    FSeaLevel: TMapSeaLevel;
    FSize: TMapSize;
    FCurrentIndustry: Integer;
    FTile: array of array of TTiles;
    function IsIndustryLocation(const AX, AY: Integer): Boolean;
    function IsTownLocation(const AX, AY: Integer): Boolean;
    function IsLandTile(const AX, AY: Integer): Boolean;
    procedure AddSpot(const AX, AY: Integer; const ATile: TTiles);
    procedure AddTree(const AX, AY: Integer);
    procedure Resize;
    function SizeCoef: Integer;
    function MapIndCount: Integer;
    function MapTownCount: Integer;
    procedure DrawTile(const X, Y: Integer);
  public const
    ClearLandCost = 100;
    BuildCanalCost = 1000;
    BuildRoadCost = 250;
  public
    Industry: array of TIndustry;
    constructor Create;
    destructor Destroy; override;
    property Top: Word read FTop write FTop;
    property Left: Word read FLeft write FLeft;
    property Height: Word read FHeight;
    property Width: Word read FWidth;
    property CurrentIndustry: Integer read FCurrentIndustry
      write FCurrentIndustry;
    property Size: TMapSize read FSize write FSize;
    property SeaLevel: TMapSeaLevel read FSeaLevel write FSeaLevel;
    property Rivers: TMapRivers read FRivers write FRivers;
    property NoOfTowns: Integer read FNoOfTowns write FNoOfTowns;
    property NoOfInd: TMapNoOfInd read FNoOfInd write FNoOfInd;
    procedure Clear;
    function IsTownName(const ATownName: string): Boolean;
    procedure Draw(const AWidth, AHeight: Integer);
    procedure Gen;
    procedure Grows;
    function GetCurrentIndustry(const AX, AY: Integer): Integer;
    function EnterInIndustry(const AX, AY: Integer): Boolean;
    function WorldPop: Integer;
    function GetDist(const X1, Y1, X2, Y2: Integer): Integer;
    procedure NextNoOfInd;
    procedure NextNoOfTowns;
    procedure NextSeaLevel;
    procedure NextRivers;
    procedure NextSize;
    procedure ClearLand(const AX, AY: Integer);
    procedure BuildCanals(const AX, AY: Integer);
    procedure BuildRoad(const AX, AY: Integer);
    function GetNearTownName(const AX, AY: Integer): string;
    function IsNearTile(const AX, AY: Integer; const ATile: TTiles): Boolean;
    function TownCount: Integer;
    function IsAircraftPath(const AX, AY: Integer): Boolean;
    function IsShipPath(const AX, AY: Integer): Boolean;
    function GetTile(const AX, AY: Integer): TTiles;
  end;

implementation

uses
  Math,
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Game,
  TransportTycoon.Finances;

{ TMap }

function TMap.IsTownName(const ATownName: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Length(Industry) - 1 do
    if (Industry[I].IndustryType = inTown) then
      if Industry[I].Name = ATownName then
        Exit(True);
end;

function TMap.IsNearTile(const AX, AY: Integer; const ATile: TTiles): Boolean;
var
  X, Y: Integer;
begin
  Result := False;
  for X := AX - 1 to AX + 1 do
    for Y := AY - 1 to AY + 1 do
    begin
      if (X = AX) and (Y = AY) then
        Continue;
      if (FTile[X][Y] = ATile) then
        Exit(True);
    end;
end;

function TMap.IsShipPath(const AX, AY: Integer): Boolean;
begin
  Result := FTile[AX][AY] in [tlTownIndustry, tlWater, tlCanal] + IndustryTiles;
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
  SetLength(FTile, FWidth, FHeight);
  FLastColor := '';
  FLastBkColor := '';
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

function TMap.MapTownCount: Integer;
begin
  Result := MapNoOfTownsInt[NoOfTowns];
  if (Size = msSmall) then
    Result := MapNoOfTownsInt[2];
  if (Size = msMedium) then
    Result := MapNoOfTownsInt[3];
  if (Size = msLarge) then
    Result := MapNoOfTownsInt[4];
end;

function TMap.IsLandTile(const AX, AY: Integer): Boolean;
begin
  Result := FTile[AX][AY] in LandTiles;
end;

function TMap.IsAircraftPath(const AX, AY: Integer): Boolean;
begin
  Result := True;
end;

function TMap.IsIndustryLocation(const AX, AY: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Length(Industry) - 1 do
    if Industry[I].InLocation(AX, AY) or
      (GetDist(Industry[I].X, Industry[I].Y, AX, AY) < (Self.Width div 10)) then
      Exit(True);
end;

function TMap.IsTownLocation(const AX, AY: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Length(Industry) - 1 do
    if (Industry[I].IndustryType = inTown) then
      if Industry[I].InLocation(AX, AY) or
        (GetDist(Industry[I].X, Industry[I].Y, AX, AY) < 15) then
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
  for I := 0 to Length(Industry) - 1 do
    Industry[I].Free;
  inherited;
end;

procedure TMap.Clear;
var
  X, Y: Integer;
begin
  Resize;
  for Y := 0 to FHeight - 1 do
    for X := 0 to FWidth - 1 do
      FTile[X][Y] := tlGrass;
end;

procedure TMap.ClearLand(const AX, AY: Integer);
begin
  if (FTile[AX][AY] in TreeTiles) then
    if (Game.Money >= ClearLandCost) then
    begin
      FTile[AX][AY] := tlDirt;
      Game.ModifyMoney(ttConstruction, -ClearLandCost);
    end;
end;

procedure TMap.BuildCanals(const AX, AY: Integer);
var
  Money: Word;
begin
  Money := BuildCanalCost;
  if (FTile[AX][AY] in TreeTiles) then
    Inc(Money, ClearLandCost);
  if (FTile[AX][AY] in TreeTiles + LandTiles) then
    if (Game.Money >= Money) then
    begin
      FTile[AX][AY] := tlCanal;
      Game.ModifyMoney(ttConstruction, -Money);
    end;
end;

procedure TMap.BuildRoad(const AX, AY: Integer);
var
  Money: Word;
begin
  Money := BuildRoadCost;
  if (FTile[AX][AY] in TreeTiles) then
    Inc(Money, ClearLandCost);
  if (FTile[AX][AY] in TreeTiles + LandTiles) then
    if (Game.Money >= Money) then
    begin
      FTile[AX][AY] := tlRoad;
      Game.ModifyMoney(ttConstruction, -Money);
    end;
end;

procedure TMap.Draw(const AWidth, AHeight: Integer);
var
  X, Y: Integer;
begin
  for Y := 0 to AHeight - 1 do
    for X := 0 to AWidth - 1 do
      DrawTile(X, Y);
  terminal_bkcolor('darkest gray');
  terminal_color('white');
end;

procedure TMap.DrawTile(const X, Y: Integer);
var
  DX, DY: Integer;
  F: Boolean;
begin
  DX := Left + X;
  DY := Top + Y;
  F := (X = 0) and (Y = 0);
  if not F or (Tile[FTile[DX][DY]].BkColor <> FLastBkColor) then
  begin
    terminal_bkcolor(Tile[FTile[DX][DY]].BkColor);
    FLastBkColor := Tile[FTile[DX][DY]].BkColor;
  end;
  if not F or (Tile[FTile[DX][DY]].Color <> FLastColor) then
  begin
    terminal_color(Tile[FTile[DX][DY]].Color);
    FLastColor := Tile[FTile[DX][DY]].Color;
  end;
  terminal_put(X, Y, Tile[FTile[DX][DY]].Tile);
end;

function TMap.EnterInIndustry(const AX, AY: Integer): Boolean;
begin
  FCurrentIndustry := GetCurrentIndustry(AX, AY);
  Result := FCurrentIndustry >= 0;
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
          FTile[X][Y] := tlDirt;
        1:
          FTile[X][Y] := tlSand;
        2:
          FTile[X][Y] := tlRock;
        3 .. 6:
          AddTree(X, Y);
      else
        FTile[X][Y] := tlGrass;
      end;
    end;
    if (SeaLevel > msVeryLow) then
    begin
      J := Math.RandomRange(0, 4) + Math.RandomRange(0, 2) + D;
      for X := 0 to J do
        FTile[X][Y] := tlWater;
      J := Math.RandomRange(0, 4) + Math.RandomRange(0, 2) + D;
      for X := FWidth - 1 downto FWidth - J - 1 do
        FTile[X][Y] := tlWater;
    end;
  end;
  for I := 0 to 14 do
  begin
    X := Math.RandomRange((SizeCoef + 10), FWidth - (SizeCoef + 10));
    Y := Math.RandomRange((SizeCoef + 10), FHeight - (SizeCoef + 10));
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
        FTile[X][Y] := tlWater;
      J := Math.RandomRange(0, 4) + Math.RandomRange(0, 2) + D;
      for Y := FHeight - 1 downto FHeight - J - 1 do
        FTile[X][Y] := tlWater;
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
        if (FTile[X][Y] <> tlWater) and
          (((FTile[X + 1][Y] = tlWater) and (FTile[X - 1][Y] = tlWater)) or
          ((FTile[X][Y + 1] = tlWater) and (FTile[X][Y - 1] = tlWater))) then
          FTile[X][Y] := tlWater;
      end;
    end;
    for Y := 1 to FHeight - 2 do
    begin
      for X := 1 to FWidth - 2 do
      begin
        if (FTile[X][Y] <> tlWater) and
          (((FTile[X + 1][Y] = tlWater) and (FTile[X - 1][Y] = tlWater) and
          (FTile[X][Y + 1] = tlWater) and (FTile[X][Y - 1] = tlWater))) then
          FTile[X][Y] := tlWater;
      end;
    end;
  end;
  // Towns
  for I := 0 to Length(Industry) - 1 do
    Industry[I].Free;
  SetLength(Industry, 0);
  for I := 0 to MapTownCount - 1 do
  begin
    repeat
      X := (Math.RandomRange(1, FWidth div 10) * 10) +
        (Math.RandomRange(0, 10) - 5);
      Y := (Math.RandomRange(1, FHeight div 10) * 10) +
        (Math.RandomRange(0, 10) - 5);
      TownName := TTownIndustry.GenName;

      for N := 2 to 5 do
      begin
        if (FTile[X - N][Y] = tlWater) then
        begin
          X := X - (N - 1);
          Break;
        end;
        if (FTile[X + N][Y] = tlWater) then
        begin
          X := X + (N - 1);
          Break;
        end;
        if (FTile[X][Y - N] = tlWater) then
        begin
          Y := Y - (N - 1);
          Break;
        end;
        if (FTile[X][Y + N] = tlWater) then
        begin
          Y := Y + (N - 1);
          Break;
        end;
      end;

    until not IsTownName(TownName) and not IsTownLocation(X, Y) and
      IsLandTile(X, Y);
    SetLength(Industry, I + 1);
    FTile[X][Y] := tlTownIndustry;
    Industry[I] := TTownIndustry.Create(TownName, X, Y);
  end;
  // Industries
  I := TownCount;
  for J := 0 to MapIndCount - 1 do
  begin
    for IndustryType := Succ(Low(TIndustryType)) to High(TIndustryType) do
    begin
      repeat
        X := (Math.RandomRange(1, FWidth div 10) * 10) +
          (Math.RandomRange(0, 10) - 5);
        Y := (Math.RandomRange(1, FHeight div 10) * 10) +
          (Math.RandomRange(0, 10) - 5);
      until IsLandTile(X, Y) and not IsTownLocation(X, Y) and
        not IsIndustryLocation(X, Y);
      case IndustryType of
        inCoalMine:
          begin
            S := GetNearTownName(X, Y);
            SetLength(Industry, I + 1);
            FTile[X][Y] := tlCoalMineIndustry;
            Industry[I] := TCoalMineIndustry.Create(S, X, Y);
            Inc(I);
          end;
        inPowerPlant:
          begin
            S := GetNearTownName(X, Y);
            SetLength(Industry, I + 1);
            FTile[X][Y] := tlPowerPlantIndustry;
            Industry[I] := TPowerPlantIndustry.Create(S, X, Y);
            Inc(I);
          end;
        inForest:
          begin
            S := GetNearTownName(X, Y);
            SetLength(Industry, I + 1);
            FTile[X][Y] := tlForestIndustry;
            Industry[I] := TForestIndustry.Create(S, X, Y);
            Inc(I);
          end;
        inSawmill:
          begin
            S := GetNearTownName(X, Y);
            SetLength(Industry, I + 1);
            FTile[X][Y] := tlSawmillIndustry;
            Industry[I] := TSawmillIndustry.Create(S, X, Y);
            Inc(I);
          end;
      end;
    end;
  end;
end;

procedure TMap.AddSpot(const AX, AY: Integer; const ATile: TTiles);
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
      FTile[VX][VY] := ATile;
    end;
    if (RandomRange(0, 6) = 0) and (VX < FWidth - (SizeCoef + 10)) then
    begin
      VX := VX + 1;
      FTile[VX][VY] := ATile;
    end;
    if (RandomRange(0, 6) = 0) and (VY > (SizeCoef + 10)) then
    begin
      VY := VY - 1;
      FTile[VX][VY] := ATile;
    end;
    if (RandomRange(0, 6) = 0) and (VY < FHeight - (SizeCoef + 10)) then
    begin
      VY := VY + 1;
      FTile[VX][VY] := ATile;
    end;
  end;
end;

procedure TMap.AddTree(const AX, AY: Integer);
begin
  case RandomRange(0, 4) of
    0:
      FTile[AX][AY] := tlTree;
    1:
      FTile[AX][AY] := tlSmallTree;
  else
    FTile[AX][AY] := tlBush;
  end;
end;

procedure TMap.Grows;
var
  I: Integer;
begin
  for I := 0 to Length(Industry) - 1 do
    Industry[I].Grows;
end;

function TMap.GetCurrentIndustry(const AX, AY: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Length(Industry) - 1 do
    if Industry[I].InLocation(AX, AY) then
      Exit(I);
end;

function TMap.TownCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Length(Industry) - 1 do
    if (Industry[I].IndustryType = inTown) then
      Result := Result + 1;
end;

function TMap.WorldPop: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Length(Industry) - 1 do
    if (Industry[I].IndustryType = inTown) then
      Result := Result + TTownIndustry(Industry[I]).Population;
end;

function TMap.GetDist(const X1, Y1, X2, Y2: Integer): Integer;
begin
  Result := Round(Sqrt(Sqr(X2 - X1) + Sqr(Y2 - Y1)));
end;

function TMap.GetNearTownName(const AX, AY: Integer): string;
var
  I, D, Mx: Integer;
begin
  Mx := Width;
  Result := '';
  for I := 0 to Length(Industry) - 1 do
    if (Industry[I].IndustryType = inTown) then
    begin
      D := GetDist(Industry[I].X, Industry[I].Y, AX, AY);
      if (D < Mx) then
      begin
        Result := Industry[I].Name;
        Mx := D;
      end;
    end;
end;

function TMap.GetTile(const AX, AY: Integer): TTiles;
begin
  Result := FTile[AX][AY];
end;

end.
