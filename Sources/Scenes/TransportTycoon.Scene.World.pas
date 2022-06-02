unit TransportTycoon.Scene.World;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneWorld = class(TScene)
  private
    procedure ClearLand;
  public
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  BearLibTerminal,
  SysUtils,
  TransportTycoon.Map,
  TransportTycoon.Game;

procedure TSceneWorld.ClearLand;
begin
  if (Game.Money >= 10) then
  begin
    Game.Map.Cell[MX][Game.Map.Top + MY] := tlDirt;
    Game.ModifyMoney(-10);
  end;
end;

procedure TSceneWorld.Render;
var
  I: Integer;
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
  terminal_put(MX, MY, Tile[Game.Map.Cell[MX][Game.Map.Top + MY]].Tile);

  DrawBar;

  if Tile[Game.Map.Cell[MX][Game.Map.Top + MY]].Tile = Tile[tlCity].Tile then
    DrawText(30, 24, Game.Map.City[Game.Map.GetCurrentCity(MX,
      Game.Map.Top + MY)].Name)
  else
    DrawText(30, 24, Tile[Game.Map.Cell[MX][Game.Map.Top + MY]].Name);
end;

procedure TSceneWorld.Update(var Key: Word);
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (MY = 24) and (MX >= 70) then
      Key := TK_ESCAPE;
    if (Game.Map.Cell[MX][Game.Map.Top + MY] = tlCity) and not Game.IsClearLand
    then
    begin
      if Game.Map.EnterInCity(MX, Game.Map.Top + MY) then
        Scenes.SetScene(scCity);
    end;
    if (Game.Map.Cell[MX][Game.Map.Top + MY] in [tlTree, tlSmallTree, tlBush])
    then
    begin
      ClearLand;
      Scenes.Render;
      Exit;
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
      ;
    TK_RIGHT:
      ;
    TK_UP:
      if (Game.Map.Top > 0) then
        Game.Map.Top := Game.Map.Top - 1;
    TK_DOWN:
      if (Game.Map.Top <= Game.Map.Height - Self.Height) then
        Game.Map.Top := Game.Map.Top + 1;
  end;
end;

end.
