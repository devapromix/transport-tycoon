unit TransportTycoon.Scene.World;

interface

uses
  TransportTycoon.Scenes;

type

  { TSceneWorld }

  TSceneWorld = class(TScene)
  private
    procedure TownInfo(const TownID: Integer);
    procedure IndustryInfo(const IndustryID: Integer);
    procedure VehicleInfo(const VehicleName: string);
    procedure TileInfo(const S: string);
    procedure DrawTileBkColor(const BkColor: string = 'gray');
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

procedure TSceneWorld.TileInfo(const S: string);
begin
  try
    DrawText(45, ScreenHeight - 1, StrLim(S, 18), TK_ALIGN_CENTER);
  except
    on E: Exception do
      Log.Add('TSceneWorld.TileInfo', E.Message);
  end;
end;

procedure TSceneWorld.VehicleInfo(const VehicleName: string);
var
  VX, VY, L: Integer;
begin
  try
    L := EnsureRange(Length(VehicleName) + 8, 20, 40);
    TileInfo(VehicleName);
    if (MY < ScreenHeight - 10) then
      VY := MY + 1
    else
      VY := MY - 5;
    if (MX < ScreenWidth - (ScreenWidth div 2)) then
      VX := MX + 1
    else
      VX := MX - L;
    terminal_bkcolor(TPalette.Background);
    DrawFrame(VX, VY, L, 5);
    DrawText(VX + (L div 2), VY + 2, '[c=yellow]' + UpperCase(VehicleName) +
      '[/c]', TK_ALIGN_CENTER);
    DrawText(MX, MY, '@', 'yellow', 'gray');
  except
    on E: Exception do
      Log.Add('TSceneWorld.VehicleInfo', E.Message);
  end;
end;

procedure TSceneWorld.TownInfo(const TownID: Integer);
var
  VX, VY, L: Integer;
  TownName: string;
begin
  try
    if TownID < 0 then
      Exit;
    TownName := Game.Map.Industry[TownID].Name;
    L := EnsureRange(Length(TownName) + 8, 20, 40);
    TileInfo(TownName);
    if (MY < ScreenHeight - 10) then
      VY := MY + 1
    else
      VY := MY - 7;
    if (MX < ScreenWidth - (ScreenWidth div 2)) then
      VX := MX + 1
    else
      VX := MX - L;
    terminal_bkcolor(TPalette.Background);
    DrawFrame(VX, VY, L, 7);
    DrawText(VX + (L div 2), VY + 2, '[c=yellow]' + UpperCase(TownName) +
      '[/c]', TK_ALIGN_CENTER);
    DrawText(VX + (L div 2), VY + 4,
      'Pop.: ' + IntToStr(TTownIndustry(Game.Map.Industry[TownID]).Population),
      TK_ALIGN_CENTER);
    DrawText(MX, MY, '#', 'yellow', 'gray');
  except
    on E: Exception do
      Log.Add('TSceneWorld.TownInfo', E.Message);
  end;
end;

procedure TSceneWorld.DrawTileBkColor(const BkColor: string = 'gray');
begin
  terminal_bkcolor(BkColor);
  terminal_put(MX, MY, $2588);
end;

class procedure TSceneWorld.GlobalKeys(var Key: Word);
begin
  try
    case Key of
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

procedure TSceneWorld.IndustryInfo(const IndustryID: Integer);
var
  VX, VY, L: Integer;
  IndustryName: string;
begin
  try
    if IndustryID < 0 then
      Exit;
    IndustryName := Game.Map.Industry[IndustryID].Name;
    L := Length(IndustryName) + 8;
    TileInfo(IndustryName);
    if (MY < ScreenHeight - 10) then
      VY := MY + 1
    else
      VY := MY - 5;
    if (MX < ScreenWidth - (ScreenWidth div 2)) then
      VX := MX + 1
    else
      VX := MX - L;
    terminal_bkcolor(TPalette.Background);
    DrawFrame(VX, VY, L, 5);
    DrawText(VX + (L div 2), VY + 2, '[c=yellow]' + UpperCase(IndustryName) +
      '[/c]', TK_ALIGN_CENTER);
    DrawText(MX, MY, Tile[Game.Map.GetTile].Tile, 'yellow', 'gray');
  except
    on E: Exception do
      Log.Add('TSceneWorld.IndustryInfo', E.Message);
  end;
end;

procedure TSceneWorld.Render;
var
  VehicleName: string;
begin
  try
    DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);

    if Game.Construct.IsBuild(ceClearLand) then
    begin
      if (Game.Map.GetTile in TreeTiles) then
        DrawTileBkColor('light red')
      else
        DrawTileBkColor;
    end
    else if Game.Construct.IsBuild(ceBuildCanal) or
      Game.Construct.IsBuild(ceBuildRoad) or
      Game.Construct.IsBuild(ceBuildRoadBridge) or
      Game.Construct.IsBuild(ceBuildRoadTunnel) then
    begin
      if (Game.Map.GetTile in TreeTiles + LandTiles) then
        DrawTileBkColor('light yellow')
      else
        DrawTileBkColor;
    end
    else if Game.IsOrder then
      terminal_bkcolor('light yellow')
    else
      DrawTileBkColor;

    terminal_color('black');
    terminal_put(MX, MY, Tile[Game.Map.GetTile].Tile);

    DrawBar;

    if (MY < Self.ScreenHeight - 1) then
    begin
      if Game.Map.GetTile = tlTownIndustry then
        TownInfo(Game.Map.GetCurrentIndustry(RX, RY))
      else if Game.Map.GetTile in IndustryTiles then
        IndustryInfo(Game.Map.GetCurrentIndustry(RX, RY))
      else if Game.Vehicles.IsVehicleOnMap(RX, RY, VehicleName) then
        VehicleInfo(VehicleName)
      else
        TileInfo(Tile[Game.Map.GetTile].Name);
    end;
    if (MY = Self.ScreenHeight - 2) then
      ScrollDown;
    if (MY = 0) then
      ScrollUp;
    if (MX = Self.ScreenWidth - 1) then
      ScrollRight;
    if (MX = 0) then
      ScrollLeft;
  except
    on E: Exception do
      Log.Add('TSceneWorld.Render', E.Message);
  end;
end;

procedure TSceneWorld.Update(var Key: Word);
var
  I: Integer;
  F: Boolean;
  Station: TStation;
  Construct: TConstructEnum;
begin
  try
    if (Key = TK_MOUSE_LEFT) then
    begin
      if (MY = Self.ScreenHeight - 1) then
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
          if (Game.Map.GetTile = tlTownIndustry) then
          begin
            if Game.Map.EnterInIndustry(RX, RY) then
              if Game.IsOrder then
              begin
                with Game.Vehicles do
                begin
                  I := Game.Map.GetCurrentIndustry(RX, RY);
                  case Scenes.CurrentVehicleScene of
                    scAircraft:
                      begin
                        Station := TTownIndustry(Game.Map.Industry[I]).Airport;
                        F := not(Aircraft[CurrentVehicle].Orders.IsOrder(I) or
                          not Station.IsBuilding);
                        if F then
                          with Game.Vehicles do
                          begin
                            if Station.IsBuilding then
                            begin
                              Aircraft[CurrentVehicle].AddOrder(I);
                              Game.IsOrder := False;
                            end;
                          end;
                        Scenes.SetScene(scAircraft, scWorld);
                      end;
                    scShip:
                      begin
                        Station := TTownIndustry(Game.Map.Industry[I]).Dock;
                        F := not(Ship[CurrentVehicle].Orders.IsOrder(I) or
                          not Station.IsBuilding);
                        if F then
                          with Game.Vehicles do
                          begin
                            if Station.IsBuilding then
                            begin
                              Ship[CurrentVehicle].AddOrder(I);
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
                          Station := TTownIndustry(Game.Map.Industry[I])
                            .BusStation
                        else
                          Station := TTownIndustry(Game.Map.Industry[I])
                            .TruckLoadingBay;
                        F := not(RoadVehicle[CurrentVehicle].Orders.IsOrder(I)
                          or not Station.IsBuilding);
                        if F then
                          with Game.Vehicles do
                          begin
                            if Station.IsBuilding then
                            begin
                              RoadVehicle[CurrentVehicle].AddOrder(I);
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
          if (Game.Map.GetTile in IndustryTiles) then
          begin
            if Game.Map.EnterInIndustry(RX, RY) then
              if Game.IsOrder then
              begin
                with Game.Vehicles do
                begin
                  I := Game.Map.GetCurrentIndustry(RX, RY);
                  case Scenes.CurrentVehicleScene of
                    scShip:
                      begin
                        Station := Game.Map.Industry[I].Dock;
                        F := not(Ship[CurrentVehicle].Orders.IsOrder(I) or
                          not Station.IsBuilding);
                        if F then
                          with Game.Vehicles do
                          begin
                            if Station.IsBuilding then
                            begin
                              Ship[CurrentVehicle].AddOrder(I);
                              Game.IsOrder := False;
                            end;
                          end;
                        Scenes.SetScene(scShip, scWorld);
                      end;
                    scRoadVehicle:
                      begin
                        Station := Game.Map.Industry[I].TruckLoadingBay;
                        F := not(RoadVehicle[CurrentVehicle].Orders.IsOrder(I)
                          or not Station.IsBuilding);
                        if F then
                          with Game.Vehicles do
                          begin
                            if Station.IsBuilding then
                            begin
                              RoadVehicle[CurrentVehicle].AddOrder(I);
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
          I := Game.Vehicles.GetCurrentRoadVehicle(RX, RY);
          if I >= 0 then
          begin
            Game.Vehicles.CurrentVehicle := I;
            Scenes.SetScene(scRoadVehicle, scWorld);
            Exit;
          end;
        end;
        for Construct := Low(TConstructEnum) to High(TConstructEnum) do
          if Game.Construct.IsBuild(Construct) then
          begin
            Game.Map.BuildConstruct(RX, RY, Construct);
            Scenes.Render;
            Exit;
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
      end
      else if Game.IsOrder then
        Game.IsOrder := False;
    end;
    case Key of
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
        ScrollLeft;
      TK_RIGHT:
        ScrollRight;
      TK_UP:
        ScrollUp;
      TK_DOWN:
        ScrollDown;
    end;
    GlobalKeys(Key);
  except
    on E: Exception do
      Log.Add('TSceneWorld.Update', E.Message);
  end;
end;

end.
