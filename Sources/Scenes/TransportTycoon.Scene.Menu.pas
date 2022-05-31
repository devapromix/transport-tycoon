unit TransportTycoon.Scene.Menu;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneMenu = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var Key: word); override;
  end;

implementation

uses
  BearLibTerminal,
  SysUtils,
  TransportTycoon.Game;

procedure TSceneMenu.Render;
begin
  DrawFrame(10, 5, 60, 15);
  DrawTitle('TRANSPORT TYCOON');

  DrawButton(11, 'ENTER', 'NEW GAME');
  if not Game.IsGame then
    terminal_color('dark gray');
  DrawButton(12, 'ESC', 'CONTINUE');
  terminal_color('white');
  DrawButton(13, 'Q', 'QUIT');

  DrawText(32, 17, 'APROMIX (C) 2022');
end;

procedure TSceneMenu.Update(var Key: word);
begin
  if (Key = TK_MOUSE_LEFT) then
    case MY of
      11:
        Key := TK_ENTER;
      12:
        Key := TK_ESCAPE;
      13:
        Key := TK_Q;
    end;
  case Key of
    TK_ESCAPE:
      if Game.IsGame then
      begin
        Game.IsPause := False;
        Scenes.SetScene(scWorld);
      end;
    TK_ENTER:
      begin
        Game.New;
        Game.IsGame := False;
        Scenes.SetScene(scGen);
      end;
    TK_Q:
      terminal_close();
  end;
end;

end.
