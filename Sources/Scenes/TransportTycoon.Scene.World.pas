unit TransportTycoon.Scene.World;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneWorld = class(TScene)
  private
    procedure ClearLand;
    procedure TownInfo(const X, Y, TownID: Word);
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

procedure TSceneWorld.ClearLand;
begin
  if (Game.Money >= 100) then
  begin
    Game.Map.Cell[Game.Map.Left + MX][Game.Map.Top + MY] := tlDirt;
    Game.ModifyMoney(ttConstruction, -100);
  end;
end;

procedure TSceneWorld.TownInfo(const X, Y, TownID: Word);
begin
  terminal_bkcolor('darkest gray');
  DrawFrame(X, Y, 20, 7);
  DrawText(X + 10, Y + 2, '[c=yellow]' + UpperCase(Game.Map.City[TownID].Name) +
    '[/c]', TK_ALIGN_CENTER);
  DrawText(X + 10, Y + 4, 'Pop.: ' + IntToStr(Game.Map.City[TownID].Population),
    TK_ALIGN_CENTER);
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
  terminal_put(MX, MY, Tile[Game.Map.Cell[Game.Map.Left + MX][Game.Map.Top +
    MY]].Tile);

  DrawBar;

  if (MY < Self.Height - 1) then
  begin
    if Tile[Game.Map.Cell[Game.Map.Left + MX][Game.Map.Top + MY]].Tile = Tile
      [tlCity].Tile then
    begin
      I := Game.Map.GetCurrentCity(Game.Map.Left + MX, Game.Map.Top + MY);
      DrawText(40, Height - 1, Game.Map.City[I].Name);
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
    else
      DrawText(40, Height - 1,
        Tile[Game.Map.Cell[Game.Map.Left + MX][Game.Map.Top + MY]].Name);
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
  VX, VY, I: Integer;
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
      VX := Game.Map.Left + MX;
      VY := Game.Map.Top + MY;
      if not Game.IsClearLand then
      begin
        I := Game.Vehicles.GetCurrentAircraft(VX, VY);
        if I >= 0 then
        begin
          Game.Vehicles.CurrentVehicle := I;
          Scenes.SetScene(scAircraft);
          Exit;
        end;
      end;
      if not Game.IsClearLand and (Game.Map.Cell[VX][VY] = tlCity) then
      begin
        if Game.Map.EnterInCity(VX, VY) then
          Scenes.SetScene(scCity);
      end;
      if (Game.Map.Cell[VX][VY] in [tlTree, tlSmallTree, tlBush]) then
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
