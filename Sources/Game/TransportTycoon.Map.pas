unit TransportTycoon.Map;

interface

uses
  TransportTycoon.Industries,
  TransportTycoon.MapObject,
  TransportTycoon.Construct;

type
  TTileEnum = (tlGrass, tlDirt, tlTree, tlSmallTree, tlBush, tlRock, tlSand,
    tlWater, tlCanal, tlRoad, tlRoadTunnel, tlRoadBridge, tlTownIndustry,
    tlForestIndustry, tlSawmillIndustry, tlCoalMineIndustry,
    tlPowerPlantIndustry);

const
  LandTiles = [tlGrass, tlDirt, tlSand];
  MountainTiles = [tlRock];
  WaterTiles = [tlWater, tlCanal];
  TreeTiles = [tlTree, tlSmallTree, tlBush];
  IndustryTiles = [tlForestIndustry, tlSawmillIndustry, tlCoalMineIndustry,
    tlPowerPlantIndustry];

type
  TTile = record
    Name: string;
    Glyph: Char;
    Color: string;
    BkColor: string;
  end;

type
  TMapType = (mtRandom, mtNormal);

const
  Tile: array [TTileEnum] of TTile = (
    //
    (Name: 'Grass'; Glyph: '"'; Color: 'green'; BkColor: 'darkest green'),
    //
    (Name: 'Dirt'; Glyph: ':'; Color: 'dark yellow'; BkColor: 'darkest yellow'),
    //
    (Name: 'Oak'; Glyph: 'f'; Color: 'green'; BkColor: 'darkest green'),
    //
    (Name: 'Pine'; Glyph: 't'; Color: 'dark green'; BkColor: 'darkest green'),
    //
    (Name: 'Bush'; Glyph: 'b'; Color: 'dark green'; BkColor: 'darkest green'),
    //
    (Name: 'Rock'; Glyph: '^'; Color: 'dark gray'; BkColor: 'darkest grey'),
    //
    (Name: 'Sand'; Glyph: ':'; Color: 'lightest yellow';
    BkColor: 'darkest yellow'),
    //
    (Name: 'Water'; Glyph: '='; Color: 'blue'; BkColor: 'darkest blue'),
    //
    (Name: 'Canal'; Glyph: '='; Color: 'light blue'; BkColor: 'darkest blue'),
    //
    (Name: 'Road'; Glyph: '*'; Color: 'light gray'; BkColor: 'darkest gray'),
    //
    (Name: 'Road Tunnel'; Glyph: '~'; Color: 'dark gray';
    BkColor: 'darkest gray'),
    //
    (Name: 'Road Bridge'; Glyph: '='; Color: 'light gray';
    BkColor: 'darkest blue'),
    //
    (Name: 'Town'; Glyph: '#'; Color: 'light yellow';
    BkColor: 'darkest yellow'),
    //
    (Name: 'Forest'; Glyph: 'F'; Color: 'light yellow';
    BkColor: 'darkest yellow'),
    //
    (Name: 'Sawmill'; Glyph: 'S'; Color: 'light yellow';
    BkColor: 'darkest yellow'),
    //
    (Name: 'Coal Mine'; Glyph: 'C'; Color: 'light yellow';
    BkColor: 'darkest yellow'),
    //
    (Name: 'Power Plant'; Glyph: 'P'; Color: 'light yellow';
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
  MapRiversInt: array [TMapRivers] of Integer = (0, 2, 4, 8);
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
  TDirectionEnum = (drEast, drWest, drSouth, drNorth, drSouthEast, drSouthWest,
    drNorthEast, drNorthWest, drOrigin);

const
  Direction: array [TDirectionEnum] of TLocation = ((X: 1; Y: 0), (X: - 1;
    Y: 0), (X: 0; Y: 1), (X: 0; Y: - 1), (X: 1; Y: 1), (X: - 1; Y: 1), (X: 1;
    Y: - 1), (X: - 1; Y: - 1), (X: 0; Y: 0));

const
  ConstructCost: array [TConstructEnum] of Word = (100, 2000, 250, 5000, 1500);

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
    FTile: array of array of TTileEnum;
    function IsIndustryLocation(const AX, AY: Integer): Boolean;
    function IsTownLocation(const AX, AY: Integer): Boolean;
    function IsLandTile(const AX, AY: Integer): Boolean;
    procedure AddSpot(const AX, AY: Integer; const ATileEnum: TTileEnum);
    procedure AddTree(const AX, AY: Integer);
    procedure Resize;
    function SizeCoef: Integer;
    function MapIndCount: Integer;
    function MapTownCount: Integer;
    procedure DrawTile(const AX, AY: Integer);
    procedure AddRiver(const ADirectionEnum: TDirectionEnum);
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
    procedure Gen(const AMapType: TMapType = mtNormal);
    procedure Grows;
    function GetCurrentIndustry(const AX, AY: Integer): Integer;
    function EnterInIndustry(const AX, AY: Integer): Boolean;
    function WorldPop: Integer;
    function GetDist(const AX1, AY1, AX2, AY2: Integer): Integer;
    procedure NextNoOfInd;
    procedure NextNoOfTowns;
    procedure NextSeaLevel;
    procedure NextRivers;
    procedure NextSize;
    procedure BuildConstruct(const AX, AY: Integer;
      AConstructEnum: TConstructEnum);
    function GetNearTownName(const AX, AY: Integer): string;
    function IsNearTile(const AX, AY: Integer;
      const ATileEnum: TTileEnum): Boolean;
    function TownCount: Integer;
    function IsAircraftPath(const AX, AY: Integer): Boolean;
    function IsShipPath(const AX, AY: Integer): Boolean;
    function IsRoadVehiclePath(const AX, AY: Integer): Boolean;
    function GetTileEnum: TTileEnum;
  end;

implementation

uses
  Math,
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Log,
  TransportTycoon.Game,
  TransportTycoon.Finances,
  TransportTycoon.Palette;

type
  TBuildPlan = record
    AffectedTiles: set of TTileEnum;
    ResultTile: TTileEnum;
  end;

const
  BuildPlans: array [TConstructEnum] of TBuildPlan = (
    // ceClearLand
    (AffectedTiles: TreeTiles; ResultTile: tlDirt),
    // ceBuildCanal
    (AffectedTiles: TreeTiles + LandTiles; ResultTile: tlCanal),
    // ceBuildRoad
    (AffectedTiles: TreeTiles + LandTiles; ResultTile: tlRoad),
    // ceBuildRoadTunnel
    (AffectedTiles: MountainTiles; ResultTile: tlRoadTunnel),
    // ceBuildRoadBridge
    (AffectedTiles: WaterTiles; ResultTile: tlRoadBridge));

  { TMap }

function TMap.IsTownName(const ATownName: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  try
    for I := 0 to Length(Industry) - 1 do
      if (Industry[I].IndustryType = inTown) then
        if Industry[I].Name = ATownName then
          Exit(True);
  except
    on E: Exception do
      Log.Add('TMap.IsTownName', E.Message);
  end;
end;

function TMap.IsNearTile(const AX, AY: Integer;
  const ATileEnum: TTileEnum): Boolean;
var
  LX, LY: Integer;
begin
  Result := False;
  try
    for LX := AX - 1 to AX + 1 do
      for LY := AY - 1 to AY + 1 do
      begin
        if (LX = AX) and (LY = AY) then
          Continue;
        if (FTile[LX][LY] = ATileEnum) then
          Exit(True);
      end;
  except
    on E: Exception do
      Log.Add('TMap.IsNearTile', E.Message);
  end;
end;

function TMap.IsAircraftPath(const AX, AY: Integer): Boolean;
begin
  Result := True;
end;

function TMap.IsRoadVehiclePath(const AX, AY: Integer): Boolean;
begin
  Result := True;
  try
    Result := FTile[AX][AY] in [tlTownIndustry, tlRoad, tlRoadTunnel,
      tlRoadBridge] + IndustryTiles;
  except
    on E: Exception do
      Log.Add('TMap.IsRoadVehiclePath', E.Message);
  end;
end;

function TMap.IsShipPath(const AX, AY: Integer): Boolean;
begin
  Result := True;
  try
    Result := FTile[AX][AY] in [tlTownIndustry, tlWater, tlCanal, tlRoadBridge]
      + IndustryTiles;
  except
    on E: Exception do
      Log.Add('TMap.IsShipPath', E.Message);
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
  try
    FTop := 0;
    FLeft := 0;
    FWidth := MapSizeInt[Size];
    FHeight := MapSizeInt[Size];
    SetLength(FTile, FWidth, FHeight);
    FLastColor := '';
    FLastBkColor := '';
  except
    on E: Exception do
      Log.Add('TMap.Resize', E.Message);
  end;
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
  Result := False;
  try
    Result := FTile[AX][AY] in LandTiles;
  except
    on E: Exception do
      Log.Add('TMap.IsLandTile', E.Message);
  end;
end;

function TMap.IsIndustryLocation(const AX, AY: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  try
    for I := 0 to Length(Industry) - 1 do
      if Industry[I].InLocation(AX, AY) or
        (GetDist(Industry[I].X, Industry[I].Y, AX, AY) < (Self.Width div 10))
      then
        Exit(True);
  except
    on E: Exception do
      Log.Add('TMap.IsIndustryLocation', E.Message);
  end;
end;

function TMap.IsTownLocation(const AX, AY: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  try
    for I := 0 to Length(Industry) - 1 do
      if (Industry[I].IndustryType = inTown) then
        if Industry[I].InLocation(AX, AY) or
          (GetDist(Industry[I].X, Industry[I].Y, AX, AY) < 15) then
          Exit(True);
  except
    on E: Exception do
      Log.Add('TMap.IsTownLocation', E.Message);
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
  for I := 0 to Length(Industry) - 1 do
    FreeAndNil(Industry[I]);
  inherited;
end;

procedure TMap.Clear;
var
  LX, LY: Integer;
begin
  try
    Resize;
    for LY := 0 to FHeight - 1 do
      for LX := 0 to FWidth - 1 do
        FTile[LX][LY] := tlGrass;
  except
    on E: Exception do
      Log.Add('TMap.Clear', E.Message);
  end;
end;

procedure TMap.BuildConstruct(const AX, AY: Integer;
  AConstructEnum: TConstructEnum);
var
  LMoney: Word;
  LPlan: TBuildPlan;
begin
  try
    LPlan := BuildPlans[AConstructEnum];
    if not(FTile[AX][AY] in LPlan.AffectedTiles) then
      Exit;
    LMoney := ConstructCost[AConstructEnum];
    if not(AConstructEnum in [ceClearLand]) and (FTile[AX][AY] in TreeTiles)
    then
      Inc(LMoney, ConstructCost[ceClearLand]);
    if (Game.Money >= LMoney) then
    begin
      FTile[AX][AY] := LPlan.ResultTile;
      Game.ModifyMoney(ttConstruction, -LMoney);
      Game.Company.Stat.IncStat(AConstructEnum);
    end;
  except
    on E: Exception do
      Log.Add('TMap.BuildConstruct', E.Message);
  end;
end;

procedure TMap.Draw(const AWidth, AHeight: Integer);
var
  LX, LY: Integer;
begin
  try
    for LY := 0 to AHeight - 1 do
      for LX := 0 to AWidth - 1 do
        DrawTile(LX, LY);
    terminal_bkcolor(TPalette.Background);
    terminal_color(TPalette.Default);
  except
    on E: Exception do
      Log.Add('TMap.Draw', E.Message);
  end;
end;

procedure TMap.DrawTile(const AX, AY: Integer);
var
  LX, LY: Integer;
  LIsFlag: Boolean;
begin
  try
    LX := Left + AX;
    LY := Top + AY;
    LIsFlag := (AX = 0) and (AY = 0);
    if LIsFlag or (Tile[FTile[LX][LY]].BkColor <> FLastBkColor) then
    begin
      terminal_bkcolor(Tile[FTile[LX][LY]].BkColor);
      FLastBkColor := Tile[FTile[LX][LY]].BkColor;
    end;
    if LIsFlag or (Tile[FTile[LX][LY]].Color <> FLastColor) then
    begin
      terminal_color(Tile[FTile[LX][LY]].Color);
      FLastColor := Tile[FTile[LX][LY]].Color;
    end;
    terminal_put(AX, AY, Tile[FTile[LX][LY]].Glyph);
  except
    on E: Exception do
      Log.Add('TMap.DrawTile', E.Message);
  end;
end;

procedure TMap.AddRiver(const ADirectionEnum: TDirectionEnum);
var
  I, LX, LY, LStart, LFinish: Integer;
begin
  try
    case ADirectionEnum of
      drEast:
        begin
          LX := (Width div 3) * 2;
          LY := RandomRange(FHeight div 3, (FHeight div 3) * 2);
          LStart := (FWidth div 3) * 2;
          LFinish := FWidth - 1;
        end;
      drWest:
        begin
          LX := 0;
          LY := RandomRange(FHeight div 3, (FHeight div 3) * 2);
          LStart := 0;
          LFinish := FWidth div 3;
        end;
      drSouth:
        begin
          LX := RandomRange(FWidth div 3, (FWidth div 3) * 2);
          LY := (FHeight div 3) * 2;
          LStart := (FHeight div 3) * 2;;
          LFinish := FHeight - 1;
        end;
      drNorth:
        begin
          LX := RandomRange(FWidth div 3, (FWidth div 3) * 2);
          LY := 0;
          LStart := 0;
          LFinish := FHeight div 3;
        end;
    end;
    for I := LStart to LFinish do
    begin
      case ADirectionEnum of
        drEast, drWest:
          if RandomRange(0, 3) = 1 then
            if RandomRange(0, 2) = 1 then
              Inc(LY)
            else
              Dec(LY);
        drSouth, drNorth:
          if RandomRange(0, 3) = 1 then
            if RandomRange(0, 2) = 1 then
              Inc(LX)
            else
              Dec(LX);
      end;
      LX := EnsureRange(LX, 0, FWidth - 1);
      LY := EnsureRange(LY, 0, FHeight - 1);
      if (FTile[LX][LY] in [tlWater, tlRock]) then
        Break;
      FTile[LX][LY] := tlWater;
      case ADirectionEnum of
        drEast, drWest:
          Inc(LX);
        drSouth, drNorth:
          Inc(LY);
      end;
    end;
  except
    on E: Exception do
      Log.Add('TMap.AddRiver', E.Message);
  end;
end;

function TMap.EnterInIndustry(const AX, AY: Integer): Boolean;
begin
  Result := False;
  try
    FCurrentIndustry := GetCurrentIndustry(AX, AY);
    Result := FCurrentIndustry >= 0;
  except
    on E: Exception do
      Log.Add('TMap.EnterInIndustry', E.Message);
  end;
end;

procedure TMap.Gen(const AMapType: TMapType = mtNormal);
var
  X, Y, I, J, N, LCoef: Integer;
  LTownName, S: string;
  LIndustryType: TIndustryType;
begin
  try
    // Terrain
    if AMapType = mtRandom then
    begin
      SeaLevel := TMapSeaLevel(RandomRange(Ord(msVeryLow),
        Ord(High(TMapSeaLevel)) + 1));
    end;
    Self.Clear;
    LCoef := 0;
    if (SeaLevel >= msNormal) then
      LCoef := 5 + SizeCoef;
    for Y := 0 to FHeight - 1 do
    begin
      for X := 0 to FWidth - 1 do
      begin
        case Math.RandomRange(0, 15) of
          0 .. 1:
            FTile[X][Y] := tlDirt;
          2 .. 3:
            FTile[X][Y] := tlSand;
          4 .. 6:
            AddTree(X, Y);
        else
          FTile[X][Y] := tlGrass;
        end;
      end;
      if (SeaLevel > msVeryLow) then
      begin
        J := Math.RandomRange(0, 4) + Math.RandomRange(0, 2) + LCoef;
        for X := 0 to J do
          FTile[X][Y] := tlWater;
        J := Math.RandomRange(0, 4) + Math.RandomRange(0, 2) + LCoef;
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
        J := Math.RandomRange(0, 4) + Math.RandomRange(0, 2) + LCoef;
        for Y := 0 to J do
          FTile[X][Y] := tlWater;
        J := Math.RandomRange(0, 4) + Math.RandomRange(0, 2) + LCoef;
        for Y := FHeight - 1 downto FHeight - J - 1 do
          FTile[X][Y] := tlWater;
      end;
      LCoef := SizeCoef * 9;
      if (SeaLevel = msHigh) then
        LCoef := SizeCoef * 25;
      if (SeaLevel >= msNormal) then
      begin
        for I := 0 to LCoef do
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
    // Rivers
    for I := 0 to MapRiversInt[Rivers] - 1 do
      AddRiver(TDirectionEnum(RandomRange(0, 4)));
    // Towns
    for I := 0 to Length(Industry) - 1 do
      FreeAndNil(Industry[I]);
    SetLength(Industry, 0);
    for I := 0 to MapTownCount - 1 do
    begin
      repeat
        X := (Math.RandomRange(1, FWidth div 10) * 10) +
          (Math.RandomRange(0, 10) - 5);
        Y := (Math.RandomRange(1, FHeight div 10) * 10) +
          (Math.RandomRange(0, 10) - 5);
        LTownName := TTownIndustry.GenName;

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

      until not IsTownName(LTownName) and not IsTownLocation(X, Y) and
        IsLandTile(X, Y);
      SetLength(Industry, I + 1);
      FTile[X][Y] := tlTownIndustry;
      Industry[I] := TTownIndustry.Create(LTownName, X, Y);
    end;
    // Industries
    I := TownCount;
    for J := 0 to MapIndCount - 1 do
    begin
      for LIndustryType := Succ(Low(TIndustryType)) to High(TIndustryType) do
      begin
        repeat
          X := (Math.RandomRange(1, FWidth div 10) * 10) +
            (Math.RandomRange(0, 10) - 5);
          Y := (Math.RandomRange(1, FHeight div 10) * 10) +
            (Math.RandomRange(0, 10) - 5);
        until IsLandTile(X, Y) and not IsTownLocation(X, Y) and
          not IsIndustryLocation(X, Y);
        case LIndustryType of
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
  except
    on E: Exception do
      Log.Add('TMap.Gen', E.Message);
  end;
end;

procedure TMap.AddSpot(const AX, AY: Integer; const ATileEnum: TTileEnum);
var
  I, LSize, LX, LY: Integer;
begin
  try
    LX := AX;
    LY := AY;
    LSize := RandomRange(100, 300) * SizeCoef;
    for I := 0 to LSize do
    begin
      if (RandomRange(0, 6) = 0) and (LX > (SizeCoef + 10)) then
      begin
        LX := LX - 1;
        FTile[LX][LY] := ATileEnum;
      end;
      if (RandomRange(0, 6) = 0) and (LX < FWidth - (SizeCoef + 10)) then
      begin
        LX := LX + 1;
        FTile[LX][LY] := ATileEnum;
      end;
      if (RandomRange(0, 6) = 0) and (LY > (SizeCoef + 10)) then
      begin
        LY := LY - 1;
        FTile[LX][LY] := ATileEnum;
      end;
      if (RandomRange(0, 6) = 0) and (LY < FHeight - (SizeCoef + 10)) then
      begin
        LY := LY + 1;
        FTile[LX][LY] := ATileEnum;
      end;
    end;
  except
    on E: Exception do
      Log.Add('TMap.AddSpot', E.Message);
  end;
end;

procedure TMap.AddTree(const AX, AY: Integer);
begin
  try
    case RandomRange(0, 4) of
      0:
        FTile[AX][AY] := tlTree;
      1:
        FTile[AX][AY] := tlSmallTree;
    else
      FTile[AX][AY] := tlBush;
    end;
  except
    on E: Exception do
      Log.Add('TMap.AddTree', E.Message);
  end;
end;

procedure TMap.Grows;
var
  I: Integer;
begin
  try
    for I := 0 to Length(Industry) - 1 do
      Industry[I].Grows;
  except
    on E: Exception do
      Log.Add('TMap.Grows', E.Message);
  end;
end;

function TMap.GetCurrentIndustry(const AX, AY: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  try
    for I := 0 to Length(Industry) - 1 do
      if Industry[I].InLocation(AX, AY) then
        Exit(I);
  except
    on E: Exception do
      Log.Add('TMap.GetCurrentIndustry', E.Message);
  end;
end;

function TMap.TownCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  try
    for I := 0 to Length(Industry) - 1 do
      if (Industry[I].IndustryType = inTown) then
        Result := Result + 1;
  except
    on E: Exception do
      Log.Add('TMap.TownCount', E.Message);
  end;
end;

function TMap.WorldPop: Integer;
var
  I: Integer;
begin
  Result := 0;
  try
    for I := 0 to Length(Industry) - 1 do
      if (Industry[I].IndustryType = inTown) then
        Result := Result + TTownIndustry(Industry[I]).Population;
  except
    on E: Exception do
      Log.Add('TMap.WorldPop', E.Message);
  end;
end;

function TMap.GetDist(const AX1, AY1, AX2, AY2: Integer): Integer;
begin
  Result := Round(Sqrt(Sqr(AX2 - AX1) + Sqr(AY2 - AY1)));
end;

function TMap.GetNearTownName(const AX, AY: Integer): string;
var
  I, LDist, LMax: Integer;
begin
  Result := '';
  try
    LMax := Width;
    Result := '';
    for I := 0 to Length(Industry) - 1 do
      if (Industry[I].IndustryType = inTown) then
      begin
        LDist := GetDist(Industry[I].X, Industry[I].Y, AX, AY);
        if (LDist < LMax) then
        begin
          Result := Industry[I].Name;
          LMax := LDist;
        end;
      end;
  except
    on E: Exception do
      Log.Add('TMap.GetNearTownName', E.Message);
  end;
end;

function TMap.GetTileEnum: TTileEnum;
var
  LX, LY: Integer;
begin
  Result := tlGrass;
  try
    LX := EnsureRange(Game.Map.Left + terminal_state(TK_MOUSE_X), 0, FWidth);
    LY := EnsureRange(Game.Map.Top + terminal_state(TK_MOUSE_Y), 0, FHeight);
    Result := FTile[LX][LY];
  except
    on E: Exception do
      Log.Add('TMap.GetTile', E.Message);
  end;
end;

end.
