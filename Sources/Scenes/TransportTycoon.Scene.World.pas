unit TransportTycoon.Scene.World;

interface

uses
  TransportTycoon.Scenes;

type

  { TSceneWorld }

  TSceneWorld = class(TScene)
  private
    procedure TownInfo(const TownID: Word);
    procedure IndustryInfo(const IndustryID: Word);
    procedure VehicleInfo(const VehicleName: string);
    procedure TileInfo(S: string);
  public
    procedure Render; override;
    procedure Update(var Key: Word); override;
    class procedure GlobalKeys(var Key: Word);
  end;

implementation

uses
  Math,
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Map,
  TransportTycoon.Game,
  TransportTycoon.Industries,
  TransportTycoon.Construct;

{ TSceneWorld }

procedure TSceneWorld.TileInfo(S: string);
var
  L: Integer;
begin
  L := Length(S);
  if L > 18 then
    S := Trim(Copy(S, 1, 14)) + '...';
  DrawText(45, Height - 1, S, TK_ALIGN_CENTER);
end;

procedure TSceneWorld.VehicleInfo(const VehicleName: string);
var
  VX, VY, L: Integer;
begin
  L := EnsureRange(Length(VehicleName) + 8, 20, 40);
  TileInfo(VehicleName);
  if (MY < Height - 10) then
    VY := MY + 1
  else
    VY := MY - 5;
  if (MX < Width - (Width div 2)) then
    VX := MX + 1
  else
    VX := MX - L;
  terminal_bkcolor('darkest gray');
  DrawFrame(VX, VY, L, 5);
  DrawText(VX + (L div 2), VY + 2, '[c=yellow]' + UpperCase(VehicleName) +
    '[/c]', TK_ALIGN_CENTER);
  DrawText(MX, MY, '@', 'yellow', 'gray');
end;

procedure TSceneWorld.TownInfo(const TownID: Word);
var
  VX, VY, L: Integer;
  S: string;
begin
  S := Game.Map.Industry[TownID].Name;
  L := EnsureRange(Length(S) + 8, 20, 40);
  TileInfo(S);
  if (MY < Height - 10) then
    VY := MY + 1
  else
    VY := MY - 7;
  if (MX < Width - (Width div 2)) then
    VX := MX + 1
  else
    VX := MX - L;
  terminal_bkcolor('darkest gray');
  DrawFrame(VX, VY, L, 7);
  DrawText(VX + (L div 2), VY + 2, '[c=yellow]' + UpperCase(S) + '[/c]',
    TK_ALIGN_CENTER);
  DrawText(VX + (L div 2), VY + 4,
    'Pop.: ' + IntToStr(TTownIndustry(Game.Map.Industry[TownID]).Population),
    TK_ALIGN_CENTER);
  DrawText(MX, MY, '#', 'yellow', 'gray');
end;

class procedure TSceneWorld.GlobalKeys(var Key: Word);
begin
  case Key of
    TK_A:
      if Game.Vehicles.GotAircrafts then
        Scenes.SetScene(scAircrafts);
    TK_S:
      if Game.Vehicles.GotShips then
        Scenes.SetScene(scShips);
    TK_F:
      Scenes.SetScene(scFinances);
    TK_G:
      Scenes.SetScene(scCompany, scWorld);
    TK_N:
      Scenes.SetScene(scTowns);
    TK_I:
      Scenes.SetScene(scIndustries);
    TK_B:
      Scenes.SetScene(scBuildMenu);
    TK_D:
      Scenes.SetScene(scSettingsMenu, scWorld);
    TK_X:
      begin
        Game.Construct.Build(ceClearLand);
        Scenes.SetScene(scWorld);
      end;
    TK_P:
      begin
        Game.IsPause := not Game.IsPause;
        Scenes.Render;
      end;
  end;
end;

procedure TSceneWorld.IndustryInfo(const IndustryID: Word);
var
  VX, VY, L: Integer;
  S: string;
begin
  S := Game.Map.Industry[IndustryID].Name;
  L := Length(S) + 8;
  TileInfo(S);
  if (MY < Height - 10) then
    VY := MY + 1
  else
    VY := MY - 5;
  if (MX < Width - (Width div 2)) then
    VX := MX + 1
  else
    VX := MX - L;
  terminal_bkcolor('darkest gray');
  DrawFrame(VX, VY, L, 5);
  DrawText(VX + (L div 2), VY + 2, '[c=yellow]' + UpperCase(S) + '[/c]',
    TK_ALIGN_CENTER);
  DrawText(MX, MY, Tile[Game.Map.Cell[RX][RY]].Tile, 'yellow', 'gray');
end;

procedure TSceneWorld.Render;
var
  VehicleName: string;
begin
  DrawMap(Self.Width, Self.Height - 1);

  if Game.Construct.IsBuild(ceClearLand) then
  begin
    terminal_bkcolor('red');
    terminal_put(MX, MY, $2588);
  end
  else if Game.Construct.IsBuild(ceBuildCanal) then
  begin
    terminal_bkcolor('light blue');
    terminal_put(MX, MY, $2588);
  end
  else
  begin
    terminal_bkcolor('gray');
    terminal_put(MX, MY, $2588);
  end;
  terminal_color('black');
  terminal_put(MX, MY, Tile[Game.Map.Cell[RX][RY]].Tile);

  DrawBar;

  if (MY < Self.Height - 1) then
  begin
    if Game.Map.Cell[RX][RY] = tlTownIndustry then
      TownInfo(Game.Map.GetCurrentIndustry(RX, RY))
    else if Game.Map.Cell[RX][RY] in IndustryTiles then
      IndustryInfo(Game.Map.GetCurrentIndustry(RX, RY))
    else if Game.Vehicles.IsVehicleOnMap(RX, RY, VehicleName) then
      VehicleInfo(VehicleName)
    else
      TileInfo(Tile[Game.Map.Cell[RX][RY]].Name);
  end;
  if (MY = Self.Height - 2) then
    ScrollDown;
  if (MY = 0) then
    ScrollUp;
  if (MX = Self.Width - 1) then
    ScrollRight;
  if (MX = 0) then
    ScrollLeft;
end;

procedure TSceneWorld.Update(var Key: Word);
var
  I: Integer;
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (MY = Self.Height - 1) then
    begin
      case MX of
        70 .. 79:
          Key := TK_ESCAPE;
        0 .. 10:
          Key := TK_F;
        25 .. 34:
          Key := TK_P;
      end;
    end
    else
    begin
      if not Game.Construct.IsConstruct then
      begin
        if (Game.Map.Cell[RX][RY] = tlTownIndustry) then
        begin
          if Game.Map.EnterInIndustry(RX, RY) then
            Scenes.SetScene(scTown);
          Exit;
        end;
        if (Game.Map.Cell[RX][RY] in IndustryTiles) then
        begin
          if Game.Map.EnterInIndustry(RX, RY) then
            Scenes.SetScene(scIndustry);
          Exit;
        end;
        I := Game.Vehicles.GetCurrentAircraft(RX, RY);
        if I >= 0 then
        begin
          Game.Vehicles.CurrentVehicle := I;
          Scenes.SetScene(scAircraft, scWorld);
          Exit;
        end;
        I := Game.Vehicles.GetCurrentShip(RX, RY);
        if I >= 0 then
        begin
          Game.Vehicles.CurrentVehicle := I;
          Scenes.SetScene(scShip, scWorld);
          Exit;
        end;
      end;
      if (Game.Map.Cell[RX][RY] in TreeTiles) then
      begin
        if Game.Construct.IsBuild(ceClearLand) then
        begin
          Game.Map.ClearLand(RX, RY);
          Scenes.Render;
          Exit;
        end;
      end;
      if (Game.Map.Cell[RX][RY] in LandTiles + TreeTiles) then
      begin
        if Game.Construct.IsBuild(ceBuildCanal) then
        begin
          Game.Map.BuildCanals(RX, RY);
          Scenes.Render;
          Exit;
        end;
      end;
    end;
  end;
  if (Key = TK_MOUSE_RIGHT) then
  begin
    if Game.Construct.IsConstruct then
    begin
      Game.Construct.Clear;
      Scenes.Render;
      Exit;
    end;
  end;
  case Key of
    TK_ESCAPE:
      begin
        if Game.Construct.IsConstruct then
        begin
          Game.Construct.Clear;
          Scenes.Render;
          Exit;
        end;
        Scenes.SetScene(scGameMenu);
      end;
    TK_LEFT:
      ScrollLeft;
    TK_RIGHT:
      ScrollRight;
    TK_UP:
      ScrollUp;
    TK_DOWN:
      ScrollDown;
  end;
  GlobalKeys(Key);
end;

end.
