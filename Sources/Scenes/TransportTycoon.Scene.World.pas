unit TransportTycoon.Scene.World;

interface

uses
  TransportTycoon.Scenes;

type

  { TSceneWorld }

  TSceneWorld = class(TScene)
  private
    procedure ClearLand;
    procedure TownInfo(const X, Y, TownID: Word);
    procedure IndustryInfo(const X, Y, IndustryID: Word);
    procedure AircraftInfo(const X, Y, AircraftID: Word);
    procedure TileInfo(const S: string);
  public
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  BearLibTerminal,
  SysUtils,
  TransportTycoon.Map,
  TransportTycoon.Game,
  TransportTycoon.Finances;

{ TSceneWorld }

procedure TSceneWorld.AircraftInfo(const X, Y, AircraftID: Word);
begin
  terminal_bkcolor('darkest gray');
  DrawFrame(X, Y, 40, 5);
  DrawText(X + 20, Y + 2, '[c=yellow]' + UpperCase(Game.Vehicles.Aircraft
    [AircraftID].Name) + '[/c]', TK_ALIGN_CENTER);
  terminal_color('yellow');
  terminal_bkcolor('gray');
  terminal_put(MX, MY, '@');
end;

procedure TSceneWorld.ClearLand;
begin
  if (Game.Money >= 100) then
  begin
    Game.Map.Cell[RX][RY] := tlDirt;
    Game.ModifyMoney(ttConstruction, -100);
  end;
end;

procedure TSceneWorld.TileInfo(const S: string);
begin
  DrawText(45, Height - 1, S, TK_ALIGN_CENTER);
end;

procedure TSceneWorld.TownInfo(const X, Y, TownID: Word);
begin
  terminal_bkcolor('darkest gray');
  DrawFrame(X, Y, 20, 7);
  DrawText(X + 10, Y + 2, '[c=yellow]' + UpperCase(Game.Map.City[TownID].Name) +
    '[/c]', TK_ALIGN_CENTER);
  DrawText(X + 10, Y + 4, 'Pop.: ' + IntToStr(Game.Map.City[TownID].Population),
    TK_ALIGN_CENTER);
  terminal_color('yellow');
  terminal_bkcolor('gray');
  terminal_put(MX, MY, '#');
end;

procedure TSceneWorld.IndustryInfo(const X, Y, IndustryID: Word);
begin
  terminal_bkcolor('darkest gray');
  DrawFrame(X, Y, 20, 5);
  DrawText(X + 10, Y + 2, '[c=yellow]' + UpperCase(Game.Map.Industry[IndustryID]
    .Name) + '[/c]', TK_ALIGN_CENTER);
  terminal_color('yellow');
  terminal_bkcolor('gray');
  terminal_put(MX, MY, Tile[Game.Map.Cell[MX][MY]].Tile);
end;

procedure TSceneWorld.Render;
var
  I, VX, VY: Integer;
begin
  DrawMap(Self.Width, Self.Height - 1);

  if Game.IsClearLand then
  begin
    terminal_bkcolor('red');
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
    if Tile[Game.Map.Cell[RX][RY]].Tile = Tile[tlCity].Tile then
    begin
      I := Game.Map.GetCurrentCity(RX, RY);
      TileInfo(Game.Map.City[I].Name);
      if (MY < Height - 10) then
        VY := MY + 1
      else
        VY := MY - 7;
      if (MX < Width - (Width div 2)) then
        VX := MX + 1
      else
        VX := MX - 20;
      TownInfo(VX, VY, I);
    end
    else if Game.Map.Cell[RX][RY] in IndustryTiles then
    begin
      I := Game.Map.GetCurrentIndustry(RX, RY);
      TileInfo(Game.Map.Industry[I].Name);
      if (MY < Height - 10) then
        VY := MY + 1
      else
        VY := MY - 7;
      if (MX < Width - (Width div 2)) then
        VX := MX + 1
      else
        VX := MX - 20;
      IndustryInfo(VX, VY, I);
    end
    else
    begin
      I := Game.Vehicles.GetCurrentAircraft(RX, RY);
      if I >= 0 then
      begin
        TileInfo(Format('Aircraft #%d',
          [Game.Vehicles.Aircraft[I].VehicleID + 1]));
        if (MY < Height - 10) then
          VY := MY + 1
        else
          VY := MY - 7;
        if (MX < Width - (Width div 2)) then
          VX := MX + 1
        else
          VX := MX - 20;
        AircraftInfo(VX, VY, I);
      end
      else
        TileInfo(Tile[Game.Map.Cell[RX][RY]].Name);
    end;
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
      if (MX >= 70) then
        Key := TK_ESCAPE;
      if (MX <= 10) then
        Key := TK_F;
      if (MX >= 25) and (MX <= 34) then
        Key := TK_P;
    end
    else
    begin
      if not Game.IsClearLand then
      begin
        if (Game.Map.Cell[RX][RY] = tlCity) then
        begin
          if Game.Map.EnterInCity(RX, RY) then
            Scenes.SetScene(scCity);
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
          Scenes.SetScene(scAircraft);
          Exit;
        end;
      end;
      if (Game.Map.Cell[RX][RY] in [tlTree, tlSmallTree, tlBush]) then
      begin
        if not Game.IsClearLand then
          Exit;
        ClearLand;
        Scenes.Render;
        Exit;
      end;
    end;
  end;
  if (Key = TK_MOUSE_RIGHT) then
  begin
    if Game.IsClearLand then
    begin
      Game.IsClearLand := False;
      Scenes.Render;
      Exit;
    end;
  end;
  case Key of
    TK_ESCAPE:
      begin
        if Game.IsClearLand then
        begin
          Game.IsClearLand := False;
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
    TK_F:
      Scenes.SetScene(scFinances);
    TK_G:
      Scenes.SetScene(scCompany);
    TK_N:
      Scenes.SetScene(scTowns);
    TK_P:
      begin
        Game.IsPause := not Game.IsPause;
        Scenes.Render
      end;
  end;
end;

end.
