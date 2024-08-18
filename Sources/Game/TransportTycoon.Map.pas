unit TransportTycoon.Map;

interface

uses
  System.Generics.Collections,
  TransportTycoon.Industries,
  TransportTycoon.MapObject,
  TransportTycoon.Construct;

type
  TTileEnum = (tlGrass, tlDirt, tlOakTree, tlPineTree, tlBush, tlRock, tlSand,
    tlWater, tlCanal, tlAqueduct, tlDeepWater, tlRoad, tlRoadTunnel,
    tlRoadBridge, tlTownIndustry, tlForestIndustry, tlSawmillIndustry,
    tlCoalMineIndustry, tlPowerPlantIndustry);

const
  LandTiles = [tlGrass, tlDirt, tlSand];
  MountainTiles = [tlRock];
  WaterTiles = [tlWater, tlCanal, tlDeepWater, tlAqueduct];
  RoadTiles = [tlRoad];
  TreeTiles = [tlOakTree, tlPineTree, tlBush];
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
    (Name: 'Oak'; Glyph: 't'; Color: 'green'; BkColor: 'darkest green'),
    //
    (Name: 'Pine'; Glyph: 'f'; Color: 'dark green'; BkColor: 'darkest green'),
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
    (Name: 'Aqueduct'; Glyph: '='; Color: 'lighter blue';
    BkColor: 'darkest blue'),
    //
    (Name: 'Deep Water'; Glyph: '='; Color: 'dark blue';
    BkColor: 'darkest blue'),
    //
    (Name: 'Road'; Glyph: '*'; Color: 'light gray'; BkColor: 'darkest gray'),
    //
    (Name: 'Road Tunnel'; Glyph: '~'; Color: 'dark gray';
    BkColor: 'darkest gray'),
    //
    (Name: 'Road Bridge'; Glyph: '-'; Color: 'light gray';
    BkColor: 'darkest gray'),
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

type
  TConstructRec = record
    Name: string;
    StatName: string;
    HotKey: string;
    Cost: Word;
    AffectedTiles: set of TTileEnum;
    ResultTile: TTileEnum;
    InfrastructureCategory: TInfrastructureCategory;
  end;

const
  Construct: array [TConstructEnum] of TConstructRec = (
    // Clear Land
    (Name: 'Clear Land'; StatName: ''; HotKey: 'X'; Cost: 100;
    AffectedTiles: TreeTiles; ResultTile: tlDirt;
    InfrastructureCategory: icLandscaping),
    // Lowering Land
    (Name: 'Lowering Land'; StatName: ''; HotKey: 'L'; Cost: 3000;
    AffectedTiles: TreeTiles + LandTiles; ResultTile: tlWater;
    InfrastructureCategory: icLandscaping),
    // Build Canal
    (Name: 'Build Canal'; StatName: 'Canals'; HotKey: 'C'; Cost: 2000;
    AffectedTiles: TreeTiles + LandTiles; ResultTile: tlCanal;
    InfrastructureCategory: icWaterways),
    // Build Aqueduct
    (Name: 'Build Aqueduct'; StatName: 'Aqueducts'; HotKey: 'A'; Cost: 4000;
    AffectedTiles: TreeTiles + LandTiles + RoadTiles; ResultTile: tlAqueduct;
    InfrastructureCategory: icWaterways),
    // Build Road
    (Name: 'Build Road'; StatName: 'Roads'; HotKey: 'R'; Cost: 250;
    AffectedTiles: TreeTiles + LandTiles; ResultTile: tlRoad;
    InfrastructureCategory: icRoadways),
    // Build Road Tunnel
    (Name: 'Build Road Tunnel'; StatName: 'Tunnels'; HotKey: 'T'; Cost: 5000;
    AffectedTiles: MountainTiles; ResultTile: tlRoadTunnel;
    InfrastructureCategory: icRoadways),
    // Build Road Bridge
    (Name: 'Build Road Bridge'; StatName: 'Road Bridges'; HotKey: 'B';
    Cost: 1500; AffectedTiles: WaterTiles + RoadTiles; ResultTile: tlRoadBridge;
    InfrastructureCategory: icRoadways)
    //
    );

const
  Direction: array [TDirectionEnum] of TLocation = ((X: 1; Y: 0), (X: - 1;
    Y: 0), (X: 0; Y: 1), (X: 0; Y: - 1), (X: 1; Y: 1), (X: - 1; Y: 1), (X: 1;
    Y: - 1), (X: - 1; Y: - 1), (X: 0; Y: 0));

type

  { TMap }

  TMap = class(TObject)
  private
    FNoOfInd: TMapNoOfInd;
    FTop: Integer;
    FWidth: Integer;
    FHeight: Integer;
    FLeft: Integer;
    FLastColor: string;
    FLastBkColor: string;
    FNoOfTowns: Integer;
    FRivers: TMapRivers;
    FSeaLevel: TMapSeaLevel;
    FMapSize: TMapSize;
    FCurrentIndustry: Integer;
    FIndustryList: TObjectList<TIndustry>;
    FTileEnum: array of array of TTileEnum;
    function IsIndustryLocation(const AX, AY: Integer): Boolean;
    function IsTownLocation(const AX, AY: Integer): Boolean;
    function IsLandTile(const AX, AY: Integer): Boolean;
    procedure AddSpot(const AX, AY: Integer; const ATileEnum: TTileEnum);
    procedure AddTree(const AX, AY: Integer);
    procedure Resize;
    function SizeCoef: Integer;
    function MapIndCount: Integer;
    procedure AddRiver(const ADirectionEnum: TDirectionEnum);
    procedure AddIndustries();
    function GetRandomTreeEnum(): TTileEnum;
  public
    Industry: array of TIndustry;
    constructor Create;
    destructor Destroy; override;
    property Top: Integer read FTop write FTop;
    property Left: Integer read FLeft write FLeft;
    property Height: Integer read FHeight;
    property Width: Integer read FWidth;
    property CurrentIndustry: Integer read FCurrentIndustry
      write FCurrentIndustry;
    property IndustryList: TObjectList<TIndustry> read FIndustryList
      write FIndustryList;
    property MapSize: TMapSize read FMapSize write FMapSize;
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
    procedure PrevNoOfInd;
    procedure NextNoOfTowns;
    procedure PrevNoOfTowns;
    procedure NextSeaLevel;
    procedure PrevSeaLevel;
    procedure NextRivers;
    procedure PrevRivers;
    procedure NextSize;
    procedure PrevSize;
    function MapTownCount: Integer;
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
    procedure DrawTile(const AX, AY: Integer; const AFlag: Boolean = True);
  end;

implementation

uses
  Math,
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Log,
  TransportTycoon.Game,
  TransportTycoon.Finances,
  TransportTycoon.Palette,
  TransportTycoon.Races;

{ TMap }

function TMap.GetRandomTreeEnum(): TTileEnum;
begin
  if Math.RandomRange(0, 2) = 0 then
    Result := tlOakTree
  else
    Result := tlPineTree;
end;

function TMap.IsTownName(const ATownName: string): Boolean;
var
  LIndustry: Integer;
begin
  Result := False;
  try
    for LIndustry := 0 to Length(Industry) - 1 do
      if (Industry[LIndustry].IndustryType = inTown) then
        if Industry[LIndustry].Name = ATownName then
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
        if (FTileEnum[LX][LY] = ATileEnum) then
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
    Result := FTileEnum[AX][AY] in [tlTownIndustry, tlRoad, tlRoadTunnel,
      tlRoadBridge, tlAqueduct] + IndustryTiles;
  except
    on E: Exception do
      Log.Add('TMap.IsRoadVehiclePath', E.Message);
  end;
end;

function TMap.IsShipPath(const AX, AY: Integer): Boolean;
begin
  Result := True;
  try
    Result := FTileEnum[AX][AY] in [tlTownIndustry, tlWater, tlCanal,
      tlDeepWater, tlRoadBridge, tlAqueduct] + IndustryTiles;
  except
    on E: Exception do
      Log.Add('TMap.IsShipPath', E.Message);
  end;
end;

procedure TMap.NextNoOfInd;
begin
  if (FNoOfInd = niHigh) then
    FNoOfInd := niVeryLow
  else
    Inc(FNoOfInd);
end;

procedure TMap.PrevNoOfInd;
begin
  if (FNoOfInd = niVeryLow) then
    FNoOfInd := niHigh
  else
    Dec(FNoOfInd);
end;

procedure TMap.NextNoOfTowns;
begin
  Inc(FNoOfTowns);
  if (FNoOfTowns > 4) then
    FNoOfTowns := 1;
end;

procedure TMap.PrevNoOfTowns;
begin
  if (FNoOfTowns = 1) then
    FNoOfTowns := 4
  else
    Dec(FNoOfTowns);
end;

procedure TMap.NextRivers;
begin
  if (FRivers = mrMany) then
    FRivers := mrNone
  else
    Inc(FRivers);
end;

procedure TMap.PrevRivers;
begin
  if (FRivers = mrNone) then
    FRivers := mrMany
  else
    Dec(FRivers);
end;

procedure TMap.NextSeaLevel;
begin
  if (FSeaLevel = msHigh) then
    FSeaLevel := msVeryLow
  else
    Inc(FSeaLevel);
end;

procedure TMap.PrevSeaLevel;
begin
  if (FSeaLevel = msVeryLow) then
    FSeaLevel := msHigh
  else
    Dec(FSeaLevel);
end;

procedure TMap.NextSize;
begin
  if (FMapSize = msLarge) then
    FMapSize := msTiny
  else
    Inc(FMapSize);
end;

procedure TMap.PrevSize;
begin
  if (FMapSize = msTiny) then
    FMapSize := msLarge
  else
    Dec(FMapSize);
end;

procedure TMap.Resize;
begin
  try
    FTop := 0;
    FLeft := 0;
    FWidth := MapSizeInt[MapSize];
    FHeight := MapSizeInt[MapSize];
    SetLength(FTileEnum, FWidth, FHeight);
    FLastColor := '';
    FLastBkColor := '';
  except
    on E: Exception do
      Log.Add('TMap.Resize', E.Message);
  end;
end;

function TMap.SizeCoef: Integer;
begin
  Result := (Ord(MapSize) + 1) * (Ord(MapSize) + 1);
end;

function TMap.MapIndCount: Integer;
begin
  Result := MapNoOfInd[NoOfInd];
  if (MapSize = msTiny) then
    Result := MapNoOfInd[niVeryLow];
  if (MapSize = msSmall) then
    Result := MapNoOfInd[niLow];
end;

function TMap.MapTownCount: Integer;
begin
  Result := MapNoOfTownsInt[NoOfTowns];
  if (MapSize = msSmall) then
    Result := MapNoOfTownsInt[2];
  if (MapSize = msMedium) then
    Result := MapNoOfTownsInt[3];
  if (MapSize = msLarge) then
    Result := MapNoOfTownsInt[4];
end;

function TMap.IsLandTile(const AX, AY: Integer): Boolean;
begin
  Result := False;
  try
    Result := FTileEnum[AX][AY] in LandTiles;
  except
    on E: Exception do
      Log.Add('TMap.IsLandTile', E.Message);
  end;
end;

function TMap.IsIndustryLocation(const AX, AY: Integer): Boolean;
var
  LIndustry: Integer;
begin
  Result := False;
  try
    for LIndustry := 0 to Length(Industry) - 1 do
      if Industry[LIndustry].InLocation(AX, AY) or
        (GetDist(Industry[LIndustry].X, Industry[LIndustry].Y, AX, AY) <
        (Self.Width div 10)) then
        Exit(True);
  except
    on E: Exception do
      Log.Add('TMap.IsIndustryLocation', E.Message);
  end;
end;

function TMap.IsTownLocation(const AX, AY: Integer): Boolean;
var
  LIndustry: Integer;
begin
  Result := False;
  try
    for LIndustry := 0 to Length(Industry) - 1 do
      if (Industry[LIndustry].IndustryType = inTown) then
        if Industry[LIndustry].InLocation(AX, AY) or
          (GetDist(Industry[LIndustry].X, Industry[LIndustry].Y, AX, AY) < 15)
        then
          Exit(True);
  except
    on E: Exception do
      Log.Add('TMap.IsTownLocation', E.Message);
  end;
end;

constructor TMap.Create;
var
  LIndustry: Integer;
begin
  FMapSize := msTiny;
  FSeaLevel := msVeryLow;
  FNoOfTowns := 1;
  FRivers := mrNone;
  FNoOfInd := niVeryLow;
  Resize;
  FIndustryList := TObjectList<TIndustry>.Create;
end;

destructor TMap.Destroy;
var
  LIndustry: Integer;
begin
  FIndustryList.Free;
  for LIndustry := 0 to Length(Industry) - 1 do
    FreeAndNil(Industry[LIndustry]);
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
        FTileEnum[LX][LY] := tlGrass;
  except
    on E: Exception do
      Log.Add('TMap.Clear', E.Message);
  end;
end;

procedure TMap.BuildConstruct(const AX, AY: Integer;
  AConstructEnum: TConstructEnum);
var
  LMoney: Word;
begin
  try
    if AY = 0 then
      Exit;
    if not(FTileEnum[AX][AY] in Construct[AConstructEnum].AffectedTiles) then
      Exit;
    LMoney := Construct[AConstructEnum].Cost;
    if not(AConstructEnum in [ceClearLand]) and (FTileEnum[AX][AY] in TreeTiles)
    then
      Inc(LMoney, Construct[ceClearLand].Cost);
    if (Game.Money >= LMoney) then
    begin
      FTileEnum[AX][AY] := Construct[AConstructEnum].ResultTile;
      Game.ModifyMoney(ttConstruction, -LMoney);
      Game.Company.IncStatistic(AConstructEnum);
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

procedure TMap.DrawTile(const AX, AY: Integer; const AFlag: Boolean = True);
var
  LX, LY: Integer;
  LIsFlag: Boolean;
begin
  try
    LX := EnsureRange(Left + AX, 0, MapSizeInt[Game.Map.MapSize]);
    LY := EnsureRange(Top + AY, 0, MapSizeInt[Game.Map.MapSize]);
    LIsFlag := (AX = 0) and (AY = 0);
    if not AFlag then
    begin
      terminal_color(TPalette.Background);
    end
    else
    begin
      if LIsFlag or (Tile[FTileEnum[LX][LY]].BkColor <> FLastBkColor) then
      begin
        terminal_bkcolor(Tile[FTileEnum[LX][LY]].BkColor);
        FLastBkColor := Tile[FTileEnum[LX][LY]].BkColor;
      end;
      if LIsFlag or (Tile[FTileEnum[LX][LY]].Color <> FLastColor) then
      begin
        terminal_color(Tile[FTileEnum[LX][LY]].Color);
        FLastColor := Tile[FTileEnum[LX][LY]].Color;
      end;
    end;
    terminal_put(AX, AY, Tile[FTileEnum[LX][LY]].Glyph);
  except
    on E: Exception do
      Log.Add('TMap.DrawTile', E.Message);
  end;
end;

procedure TMap.AddRiver(const ADirectionEnum: TDirectionEnum);
var
  LPos, LX, LY, LStart, LFinish: Integer;
begin
  LX := 0;
  LY := 0;
  LStart := 0;
  LFinish := 0;
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
    for LPos := LStart to LFinish do
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
      if (FTileEnum[LX][LY] in [tlWater, tlRock]) then
        Break;
      FTileEnum[LX][LY] := tlWater;
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
  LX, LY, I, J, LNum, LCoef: Integer;
  LTownName: string;
  LTownRace: TRaceEnum;
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
    for LY := 0 to FHeight - 1 do
    begin
      for LX := 0 to FWidth - 1 do
      begin
        case Math.RandomRange(0, 15) of
          0 .. 1:
            FTileEnum[LX][LY] := tlDirt;
          2 .. 3:
            FTileEnum[LX][LY] := tlSand;
          4 .. 6:
            AddTree(LX, LY);
        else
          FTileEnum[LX][LY] := tlGrass;
        end;
      end;
      if (SeaLevel > msVeryLow) then
      begin
        J := Math.RandomRange(0, 4) + Math.RandomRange(0, 2) + LCoef;
        for LX := 0 to J do
          if LX < J div 2 then
            FTileEnum[LX][LY] := tlDeepWater
          else
            FTileEnum[LX][LY] := tlWater;
        J := Math.RandomRange(0, 4) + Math.RandomRange(0, 2) + LCoef;
        for LX := FWidth - 1 downto FWidth - J - 1 do
          if LX > FWidth - (J div 2) then
            FTileEnum[LX][LY] := tlDeepWater
          else
            FTileEnum[LX][LY] := tlWater;
      end;
    end;
    for I := 0 to 14 do
    begin
      LX := Math.RandomRange((SizeCoef + 10), FWidth - (SizeCoef + 10));
      LY := Math.RandomRange((SizeCoef + 10), FHeight - (SizeCoef + 10));
      case RandomRange(0, 4) of
        0:
          AddSpot(LX, LY, tlDirt);
        1:
          AddSpot(LX, LY, tlRock);
        2:
          AddSpot(LX, LY, tlWater);
      else
        AddSpot(LX, LY, tlSand);
      end;
    end;
    if (SeaLevel > msVeryLow) then
    begin
      for LX := 0 to FWidth - 1 do
      begin
        J := Math.RandomRange(0, 4) + Math.RandomRange(0, 2) + LCoef;
        for LY := 0 to J do
          if LY < J div 2 then
            FTileEnum[LX][LY] := tlDeepWater
          else
            FTileEnum[LX][LY] := tlWater;
        J := Math.RandomRange(0, 4) + Math.RandomRange(0, 2) + LCoef;
        for LY := FHeight - 1 downto FHeight - J - 1 do
          if LY > FHeight - (J div 2) then
            FTileEnum[LX][LY] := tlDeepWater
          else
            FTileEnum[LX][LY] := tlWater;
      end;
      LCoef := SizeCoef * 9;
      if (SeaLevel = msHigh) then
        LCoef := SizeCoef * 25;
      if (SeaLevel >= msNormal) then
      begin
        for I := 0 to LCoef do
        begin
          LX := Math.RandomRange(10, FWidth - 11);
          LY := Math.RandomRange(10, FWidth - 11);
          AddSpot(LX, LY, tlWater);
        end;
      end;
      for LY := 1 to FHeight - 2 do
      begin
        for LX := 1 to FWidth - 2 do
        begin
          if (FTileEnum[LX][LY] <> tlWater) and
            (((FTileEnum[LX + 1][LY] = tlWater) and
            (FTileEnum[LX - 1][LY] = tlWater)) or
            ((FTileEnum[LX][LY + 1] = tlWater) and
            (FTileEnum[LX][LY - 1] = tlWater))) then
            FTileEnum[LX][LY] := tlWater;
        end;
      end;
      for LY := 1 to FHeight - 2 do
      begin
        for LX := 1 to FWidth - 2 do
        begin
          if (FTileEnum[LX][LY] <> tlWater) and
            (((FTileEnum[LX + 1][LY] = tlWater) and
            (FTileEnum[LX - 1][LY] = tlWater) and
            (FTileEnum[LX][LY + 1] = tlWater) and
            (FTileEnum[LX][LY - 1] = tlWater))) then
            FTileEnum[LX][LY] := tlWater;
        end;
      end;
    end;
    // Rivers
    if AMapType = mtRandom then
      J := MapRiversInt[TMapRivers(RandomRange(0, 4))]
    else
      J := MapRiversInt[Rivers];
    for I := 0 to J - 1 do
      AddRiver(TDirectionEnum(RandomRange(0, 4)));
    // Towns
    FIndustryList.Clear;
    for I := 0 to Length(Industry) - 1 do
      FreeAndNil(Industry[I]);
    SetLength(Industry, 0);
    for I := 0 to MapTownCount - 1 do
    begin
      if Game = nil then
        LTownRace := reHuman
      else
      begin
        if I = 0 then
          LTownRace := Game.Race
        else
          LTownRace := TRaceEnum(Math.RandomRange(0, Ord(High(TRaceEnum)) + 1));
        if (Math.RandomRange(1, 3) = 1) and (LTownRace = Game.Race) and
          (Game <> nil) then
          Game.Company.TownIndex := I;
      end;
      repeat
        LTownName := TTownIndustry.GenName(LTownRace);

        LX := (Math.RandomRange(1, FWidth div 10) * 10) +
          (Math.RandomRange(0, 10) - 5);
        LY := (Math.RandomRange(1, FHeight div 10) * 10) +
          (Math.RandomRange(0, 10) - 5);

        for LNum := 2 to 5 do
        begin
          if (FTileEnum[LX - LNum][LY] = tlWater) then
          begin
            LX := LX - (LNum - 1);
            Break;
          end;
          if (FTileEnum[LX + LNum][LY] = tlWater) then
          begin
            LX := LX + (LNum - 1);
            Break;
          end;
          if (FTileEnum[LX][LY - LNum] = tlWater) then
          begin
            LY := LY - (LNum - 1);
            Break;
          end;
          if (FTileEnum[LX][LY + LNum] = tlWater) then
          begin
            LY := LY + (LNum - 1);
            Break;
          end;
        end;

      until not IsTownName(LTownName) and not IsTownLocation(LX, LY) and
        IsLandTile(LX, LY);
      SetLength(Industry, I + 1);
      FTileEnum[LX][LY] := tlTownIndustry;
      Industry[I] := TTownIndustry.Create(LTownName, LTownRace, LX, LY);
      FIndustryList.Add(TTownIndustry.Create(LTownName, LTownRace, LX, LY));
    end;
    // Industries
    AddIndustries();
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
        FTileEnum[LX][LY] := ATileEnum;
      end;
      if (RandomRange(0, 6) = 0) and (LX < FWidth - (SizeCoef + 10)) then
      begin
        LX := LX + 1;
        FTileEnum[LX][LY] := ATileEnum;
      end;
      if (RandomRange(0, 6) = 0) and (LY > (SizeCoef + 10)) then
      begin
        LY := LY - 1;
        FTileEnum[LX][LY] := ATileEnum;
      end;
      if (RandomRange(0, 6) = 0) and (LY < FHeight - (SizeCoef + 10)) then
      begin
        LY := LY + 1;
        FTileEnum[LX][LY] := ATileEnum;
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
    case RandomRange(0, 3) of
      0:
        FTileEnum[AX][AY] := GetRandomTreeEnum();
    else
      FTileEnum[AX][AY] := tlBush;
    end;
  except
    on E: Exception do
      Log.Add('TMap.AddTree', E.Message);
  end;
end;

procedure TMap.Grows;
var
  LIndustry: Integer;
begin
  try
    for LIndustry := 0 to Length(Industry) - 1 do
      Industry[LIndustry].Grows;
  except
    on E: Exception do
      Log.Add('TMap.Grows', E.Message);
  end;
end;

function TMap.GetCurrentIndustry(const AX, AY: Integer): Integer;
var
  LIndustry: Integer;
begin
  Result := -1;
  try
    for LIndustry := 0 to Length(Industry) - 1 do
      if Industry[LIndustry].InLocation(AX, AY) then
        Exit(LIndustry);
  except
    on E: Exception do
      Log.Add('TMap.GetCurrentIndustry', E.Message);
  end;
end;

function TMap.TownCount: Integer;
var
  LIndustry: Integer;
begin
  Result := 0;
  try
    for LIndustry := 0 to Length(Industry) - 1 do
      if (Industry[LIndustry].IndustryType = inTown) then
        Result := Result + 1;
  except
    on E: Exception do
      Log.Add('TMap.TownCount', E.Message);
  end;
end;

function TMap.WorldPop: Integer;
var
  LIndustry: Integer;
begin
  Result := 0;
  try
    for LIndustry := 0 to Length(Industry) - 1 do
      if (Industry[LIndustry].IndustryType = inTown) then
        Result := Result + TTownIndustry(Industry[LIndustry]).Population;
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
  LIndustry, LDist, LMax: Integer;
begin
  Result := '';
  try
    LMax := Width;
    Result := '';
    for LIndustry := 0 to Length(Industry) - 1 do
      if (Industry[LIndustry].IndustryType = inTown) then
      begin
        LDist := GetDist(Industry[LIndustry].X, Industry[LIndustry].Y, AX, AY);
        if (LDist < LMax) then
        begin
          Result := Industry[LIndustry].Name;
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
    Result := FTileEnum[LX][LY];
  except
    on E: Exception do
      Log.Add('TMap.GetTile', E.Message);
  end;
end;

procedure TMap.AddIndustries();
var
  LIndustryType: TIndustryType;
  LTownName: string;
  LX, LY, LIndustry, LIndustryCounter: Integer;
begin
  LIndustryCounter := TownCount();
  for LIndustry := 0 to MapIndCount - 1 do
  begin
    for LIndustryType := Succ(Low(TIndustryType)) to High(TIndustryType) do
    begin
      repeat
        LX := (Math.RandomRange(1, FWidth div 10) * 10) +
          (Math.RandomRange(0, 10) - 5);
        LY := (Math.RandomRange(1, FHeight div 10) * 10) +
          (Math.RandomRange(0, 10) - 5);
      until IsLandTile(LX, LY) and not IsTownLocation(LX, LY) and
        not IsIndustryLocation(LX, LY);
      case LIndustryType of
        inCoalMine:
          begin
            Self.AddSpot(LX, LY, tlRock);
            LTownName := GetNearTownName(LX, LY);
            SetLength(Industry, LIndustryCounter + 1);
            FTileEnum[LX][LY] := tlCoalMineIndustry;
            Industry[LIndustryCounter] := TCoalMineIndustry.Create
              (LTownName, LX, LY);
            Inc(LIndustryCounter);
            FIndustryList.Add(TCoalMineIndustry.Create(LTownName, LX, LY));
          end;
        inPowerPlant:
          begin
            LTownName := GetNearTownName(LX, LY);
            SetLength(Industry, LIndustryCounter + 1);
            FTileEnum[LX][LY] := tlPowerPlantIndustry;
            Industry[LIndustryCounter] := TPowerPlantIndustry.Create
              (LTownName, LX, LY);
            Inc(LIndustryCounter);
            FIndustryList.Add(TPowerPlantIndustry.Create(LTownName, LX, LY));
          end;
        inForest:
          begin
            Self.AddSpot(LX, LY, GetRandomTreeEnum());
            LTownName := GetNearTownName(LX, LY);
            SetLength(Industry, LIndustryCounter + 1);
            FTileEnum[LX][LY] := tlForestIndustry;
            Industry[LIndustryCounter] :=
              TForestIndustry.Create(LTownName, LX, LY);
            Inc(LIndustryCounter);
            FIndustryList.Add(TForestIndustry.Create(LTownName, LX, LY));
          end;
        inSawmill:
          begin
            LTownName := GetNearTownName(LX, LY);
            SetLength(Industry, LIndustryCounter + 1);
            FTileEnum[LX][LY] := tlSawmillIndustry;
            Industry[LIndustryCounter] :=
              TSawmillIndustry.Create(LTownName, LX, LY);
            Inc(LIndustryCounter);
            FIndustryList.Add(TSawmillIndustry.Create(LTownName, LX, LY));
          end;
      end;
    end;
  end;
end;

end.
