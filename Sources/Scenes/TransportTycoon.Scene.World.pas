unit TransportTycoon.Scene.World;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneWorld = class(TScene)
  private
  public
    procedure DrawBar;
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  BearLibTerminal,
  SysUtils,
  TransportTycoon.Map,
  TransportTycoon.Game;

{ TSceneWorld }

procedure TSceneWorld.DrawBar;
begin
  terminal_color('white');
  terminal_bkcolor('black');
  terminal_clear_area(0, 24, 80, 1);
  DrawText(0, 24, Format('$%d', [Game.Money]));
  DrawText(12, 24, Format('Turn:%d', [Game.Turn]));
  DrawText(56, 24, Format('%s %d, %d', [MonStr[Game.Month], Game.Day,
    Game.Year]));
  DrawButton(70, 24, 'ESC', 'MENU');
end;

procedure TSceneWorld.Render;
begin
  Game.Map.Draw(Self.Width, Self.Height - 1);

  terminal_bkcolor('gray');
  terminal_put(MX, MY, $2588);
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
    if Game.Map.Cell[MX][Game.Map.Top + MY] = tlCity then
    begin
      if Game.Map.EnterInCity(MX, Game.Map.Top + MY) then
        Scenes.SetScene(scCity);
    end;
  end;
  case Key of
    TK_ESCAPE:
      begin
        Game.IsPause := True;
        Scenes.SetScene(scMenu);
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
