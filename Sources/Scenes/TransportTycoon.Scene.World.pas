unit TransportTycoon.Scene.World;

interface

uses
  TransportTycoon.Scenes;

type

  { TSceneWorld }

  TSceneWorld = class(TScene)
  private
    procedure TownInfo(const ATownID: Integer);
    procedure IndustryInfo(const AIndustryIndex: Integer);
    procedure VehicleInfo(const AVehicleName: string);
    procedure TileInfo(const ATileName: string);
    procedure DrawTileBkColor(const ABkColor: string = 'gray');
  public
    procedure Render; override;
    procedure Update(var AKey: Word); override;
    class procedure GlobalKeys(var AKey: Word);
  end;

implementation

uses
  Math,
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Log,
  TransportTycoon.Map,
  TransportTycoon.Game,
  TransportTycoon.Industries,
  TransportTycoon.Construct,
  TransportTycoon.Scene.Menu.Settings,
  TransportTycoon.Stations,
  TransportTycoon.Palette,
  TransportTycoon.RoadVehicle,
  TransportTycoon.Vehicle;

{ TSceneWorld }

procedure TSceneWorld.TileInfo(const ATileName: string);
begin
  try
    DrawText(50, ScreenHeight - 1, StrLim(ATileName, 10), TK_ALIGN_CENTER);
  except
    on E: Exception do
      Log.Add('TSceneWorld.TileInfo', E.Message);
  end;
end;

procedure TSceneWorld.VehicleInfo(const AVehicleName: string);
var
  LX, LY, LNameLength: Integer;
begin
  try
    LNameLength := EnsureRange(Length(AVehicleName) + 8, 20, 40);
    TileInfo(AVehicleName);
    if (MY < ScreenHeight - 10) then
      LY := MY + 1
    else
      LY := MY - 5;
    if (MX < ScreenWidth - (ScreenWidth div 2)) then
      LX := MX + 1
    else
      LX := MX - LNameLength;
    terminal_bkcolor(TPalette.Background);
    DrawFrame(LX, LY, LNameLength, 5);
    DrawText(LX + (LNameLength div 2), LY + 2,
      '[c=yellow]' + UpperCase(AVehicleName) + '[/c]', TK_ALIGN_CENTER);
    DrawText(MX, MY, '@', 'yellow', 'gray');
  except
    on E: Exception do
      Log.Add('TSceneWorld.VehicleInfo', E.Message);
  end;
end;

procedure TSceneWorld.TownInfo(const ATownID: Integer);
var
  LX, LY, LNameLength: Integer;
  LTownName: string;
begin
  try
    if ATownID < 0 then
      Exit;
    LTownName := Game.Map.Industry[ATownID].Name;
    LNameLength := EnsureRange(Length(LTownName) + 8, 20, 40);
    TileInfo(LTownName);
    if (MY < ScreenHeight - 10) then
      LY := MY + 1
    else
      LY := MY - 7;
    if (MX < ScreenWidth - (ScreenWidth div 2)) then
      LX := MX + 1
    else
      LX := MX - LNameLength;
    terminal_bkcolor(TPalette.Background);
    DrawFrame(LX, LY, LNameLength, 7);
    DrawText(LX + (LNameLength div 2), LY + 2,
      '[c=yellow]' + UpperCase(LTownName) + '[/c]', TK_ALIGN_CENTER);
    DrawText(LX + (LNameLength div 2), LY + 4,
      'Pop.: ' + IntToStr(TTownIndustry(Game.Map.Industry[ATownID]).Population),
      TK_ALIGN_CENTER);
    DrawText(MX, MY, '#', 'yellow', 'gray');
  except
    on E: Exception do
      Log.Add('TSceneWorld.TownInfo', E.Message);
  end;
end;

procedure TSceneWorld.DrawTileBkColor(const ABkColor: string = 'gray');
begin
  terminal_bkcolor(ABkColor);
  terminal_put(MX, MY, $2588);
end;

class procedure TSceneWorld.GlobalKeys(var AKey: Word);
begin
  try
    case AKey of
      TK_A:
        if Game.Vehicles.GotAircrafts then
          Scenes.SetScene(scAircrafts);
      TK_B:
        Scenes.SetScene(scBuildMenu);
      TK_D:
        begin
          TSceneSettingsMenu(Scenes.GetScene(scSettingsMenu)).IsShowBar := True;
          Scenes.SetScene(scSettingsMenu, scWorld);
        end;
      TK_F:
        Scenes.SetScene(scFinances);
      TK_G:
        Scenes.SetScene(scCompany, scWorld);
      TK_I:
        Scenes.SetScene(scIndustries);
      TK_N:
        Scenes.SetScene(scTowns);
      TK_U:
        Scenes.SetScene(scSaveGameMenu);
      TK_P:
        begin
          Game.IsPause := not Game.IsPause;
          Scenes.Render;
        end;
      TK_R:
        if Game.Vehicles.GotRoadVehicles then
          Scenes.SetScene(scRoadVehicles);
      TK_S:
        if Game.Vehicles.GotShips then
          Scenes.SetScene(scShips);
      TK_X:
        begin
          Game.Construct.Build(ceClearLand);
          Scenes.SetScene(scWorld);
        end;
    end;
  except
    on E: Exception do
      Log.Add('TSceneWorld.GlobalKeys', E.Message);
  end;
end;

procedure TSceneWorld.IndustryInfo(const AIndustryIndex: Integer);
var
  LX, LY, LNameLength: Integer;
  LIndustryName: string;
begin
  try
    if AIndustryIndex < 0 then
      Exit;
    LIndustryName := Game.Map.Industry[AIndustryIndex].Name;
    LNameLength := Length(LIndustryName) + 8;
    TileInfo(LIndustryName);
    if (MY < ScreenHeight - 10) then
      LY := MY + 1
    else
      LY := MY - 5;
    if (MX < ScreenWidth - (ScreenWidth div 2)) then
      LX := MX + 1
    else
      LX := MX - LNameLength;
    terminal_bkcolor(TPalette.Background);
    DrawFrame(LX, LY, LNameLength, 5);
    DrawText(LX + (LNameLength div 2), LY + 2,
      '[c=yellow]' + UpperCase(LIndustryName) + '[/c]', TK_ALIGN_CENTER);
    DrawText(MX, MY, Tile[Game.Map.GetTileEnum].Glyph, 'yellow', 'gray');
  except
    on E: Exception do
      Log.Add('TSceneWorld.IndustryInfo', E.Message);
  end;
end;

procedure TSceneWorld.Render;
var
  LVehicleName: string;
begin
  try
    DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);

    if Game.Construct.IsBuild(ceClearLand) then
    begin
      if (Game.Map.GetTileEnum in TreeTiles) then
        DrawTileBkColor('light red')
      else
        DrawTileBkColor;
    end
    else if Game.Construct.IsBuild(ceBuildCanal) or
      Game.Construct.IsBuild(ceBuildRoad) or
      Game.Construct.IsBuild(ceBuildRoadBridge) or
      Game.Construct.IsBuild(ceBuildRoadTunnel) then
    begin
      if (Game.Map.GetTileEnum in TreeTiles + LandTiles) then
        DrawTileBkColor('light yellow')
      else
        DrawTileBkColor;
    end
    else if Game.IsOrder then
      terminal_bkcolor('light yellow')
    else
      DrawTileBkColor;

    terminal_color('black');
    terminal_put(MX, MY, Tile[Game.Map.GetTileEnum].Glyph);

    DrawGameBar;
    if Game.Construct.IsConstruct then
      DrawBuildBar;

    if (MY < Self.ScreenHeight - 1) then
    begin
      if Game.Map.GetTileEnum = tlTownIndustry then
        TownInfo(Game.Map.GetCurrentIndustry(RX, RY))
      else if Game.Map.GetTileEnum in IndustryTiles then
        IndustryInfo(Game.Map.GetCurrentIndustry(RX, RY))
      else if Game.Vehicles.IsVehicleOnMap(RX, RY, LVehicleName) then
        VehicleInfo(LVehicleName)
      else
        TileInfo(Tile[Game.Map.GetTileEnum].Name);
    end;
    if (MY = Self.ScreenHeight - 2) then
      Scroll(drSouth);
    if (MY = 0) and not Game.Construct.IsConstruct then
      Scroll(drNorth);
    if (MY = 1) and Game.Construct.IsConstruct then
      Scroll(drNorth);
    if (MX = Self.ScreenWidth - 1) then
      Scroll(drEast);
    if (MX = 0) then
      Scroll(drWest);
  except
    on E: Exception do
      Log.Add('TSceneWorld.Render', E.Message);
  end;
end;

procedure TSceneWorld.Update(var AKey: Word);
var
  LCurrentVehicle: Integer;
  LCurrentIndustry: Integer;
  LIsFlag: Boolean;
  LStation: TStation;
  LConstruct: TConstructEnum;
begin
  try
    if (AKey = TK_MOUSE_LEFT) then
    begin
      if (MY = Self.ScreenHeight - 1) then
      begin
        case MX of
          70 .. 79:
            AKey := TK_ESCAPE;
          0 .. 10:
            AKey := TK_F;
          25 .. 33:
            AKey := TK_B;
          35 .. 44:
            AKey := TK_P;
        end;
      end
      else
      begin
        if not Game.Construct.IsConstruct then
        begin
          if (Game.Map.GetTileEnum = tlTownIndustry) then
          begin
            if Game.Map.EnterInIndustry(RX, RY) then
              if Game.IsOrder then
              begin
                with Game.Vehicles do
                begin
                  LCurrentIndustry := Game.Map.GetCurrentIndustry(RX, RY);
                  case Scenes.CurrentVehicleScene of
                    scAircraft:
                      begin
                        LStation :=
                          TTownIndustry
                          (Game.Map.Industry[LCurrentIndustry]).Airport;
                        LIsFlag :=
                          not(Aircraft[CurrentVehicle].Orders.IsOrder
                          (LCurrentIndustry) or not LStation.IsBuilding);
                        if LIsFlag then
                          with Game.Vehicles do
                          begin
                            if LStation.IsBuilding then
                            begin
                              Aircraft[CurrentVehicle]
                                .AddOrder(LCurrentIndustry);
                              Game.IsOrder := False;
                            end;
                          end;
                        Scenes.SetScene(scAircraft, scWorld);
                      end;
                    scShip:
                      begin
                        LStation :=
                          TTownIndustry
                          (Game.Map.Industry[LCurrentIndustry]).Dock;
                        LIsFlag :=
                          not(Ship[CurrentVehicle].Orders.IsOrder
                          (LCurrentIndustry) or not LStation.IsBuilding);
                        if LIsFlag then
                          with Game.Vehicles do
                          begin
                            if LStation.IsBuilding then
                            begin
                              Ship[CurrentVehicle].AddOrder(LCurrentIndustry);
                              Game.IsOrder := False;
                            end;
                          end;
                        Scenes.SetScene(scShip, scWorld);
                      end;
                    scRoadVehicle:
                      begin
                        if RoadVehicleBase
                          [RoadVehicle[CurrentVehicle].VehicleID].VehicleType = vtBus
                        then
                          LStation :=
                            TTownIndustry(Game.Map.Industry[LCurrentIndustry])
                            .BusStation
                        else
                          LStation :=
                            TTownIndustry(Game.Map.Industry[LCurrentIndustry])
                            .TruckLoadingBay;
                        LIsFlag :=
                          not(RoadVehicle[CurrentVehicle].Orders.IsOrder
                          (LCurrentIndustry) or not LStation.IsBuilding);
                        if LIsFlag then
                          with Game.Vehicles do
                          begin
                            if LStation.IsBuilding then
                            begin
                              RoadVehicle[CurrentVehicle]
                                .AddOrder(LCurrentIndustry);
                              Game.IsOrder := False;
                            end;
                          end;
                        Scenes.SetScene(scRoadVehicle, scWorld);
                      end;
                  end;
                end;
              end
              else
                Scenes.SetScene(scTown);
            Exit;
          end;
          if (Game.Map.GetTileEnum in IndustryTiles) then
          begin
            if Game.Map.EnterInIndustry(RX, RY) then
              if Game.IsOrder then
              begin
                with Game.Vehicles do
                begin
                  LCurrentIndustry := Game.Map.GetCurrentIndustry(RX, RY);
                  case Scenes.CurrentVehicleScene of
                    scShip:
                      begin
                        LStation := Game.Map.Industry[LCurrentIndustry].Dock;
                        LIsFlag :=
                          not(Ship[CurrentVehicle].Orders.IsOrder
                          (LCurrentIndustry) or not LStation.IsBuilding);
                        if LIsFlag then
                          with Game.Vehicles do
                          begin
                            if LStation.IsBuilding then
                            begin
                              Ship[CurrentVehicle].AddOrder(LCurrentIndustry);
                              Game.IsOrder := False;
                            end;
                          end;
                        Scenes.SetScene(scShip, scWorld);
                      end;
                    scRoadVehicle:
                      begin
                        LStation := Game.Map.Industry[LCurrentIndustry]
                          .TruckLoadingBay;
                        LIsFlag :=
                          not(RoadVehicle[CurrentVehicle].Orders.IsOrder
                          (LCurrentIndustry) or not LStation.IsBuilding);
                        if LIsFlag then
                          with Game.Vehicles do
                          begin
                            if LStation.IsBuilding then
                            begin
                              RoadVehicle[CurrentVehicle]
                                .AddOrder(LCurrentIndustry);
                              Game.IsOrder := False;
                            end;
                          end;
                        Scenes.SetScene(scRoadVehicle, scWorld);
                      end;
                  end;
                end;
              end
              else
                Scenes.SetScene(scIndustry);
            Exit;
          end;
          LCurrentVehicle := Game.Vehicles.GetCurrentAircraft(RX, RY);
          if LCurrentVehicle >= 0 then
          begin
            Game.Vehicles.CurrentVehicle := LCurrentVehicle;
            Scenes.SetScene(scAircraft, scWorld);
            Exit;
          end;
          LCurrentVehicle := Game.Vehicles.GetCurrentShip(RX, RY);
          if LCurrentVehicle >= 0 then
          begin
            Game.Vehicles.CurrentVehicle := LCurrentVehicle;
            Scenes.SetScene(scShip, scWorld);
            Exit;
          end;
          LCurrentVehicle := Game.Vehicles.GetCurrentRoadVehicle(RX, RY);
          if LCurrentVehicle >= 0 then
          begin
            Game.Vehicles.CurrentVehicle := LCurrentVehicle;
            Scenes.SetScene(scRoadVehicle, scWorld);
            Exit;
          end;
        end;
        for LConstruct := Low(TConstructEnum) to High(TConstructEnum) do
          if Game.Construct.IsBuild(LConstruct) then
          begin
            Game.Map.BuildConstruct(RX, RY, LConstruct);
            Scenes.Render;
            Exit;
          end;
      end;
    end;
    if (AKey = TK_MOUSE_RIGHT) then
    begin
      if Game.Construct.IsConstruct then
      begin
        Game.Construct.Clear;
        Scenes.Render;
        Exit;
      end
      else if Game.IsOrder then
        Game.IsOrder := False;
    end;
    case AKey of
      TK_ESCAPE:
        begin
          if Game.Construct.IsConstruct then
          begin
            Game.Construct.Clear;
            Scenes.Render;
            Exit;
          end
          else if Game.IsOrder then
          begin
            Game.IsOrder := False;
            Exit;
          end;
          Scenes.SetScene(scGameMenu);
        end;
      TK_LEFT:
        Scroll(drWest);
      TK_RIGHT:
        Scroll(drEast);
      TK_UP:
        Scroll(drNorth);
      TK_DOWN:
        Scroll(drSouth);
    end;
    GlobalKeys(AKey);
  except
    on E: Exception do
      Log.Add('TSceneWorld.Update', E.Message);
  end;
end;

end.
