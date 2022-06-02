unit TransportTycoon.Scene.MainMenu;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneMainMenu = class(TScene)
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

procedure TSceneMainMenu.Render;
begin
  Game.Map.Draw(Self.Width, Self.Height);

  DrawFrame(10, 5, 60, 15);
  DrawTitle('TRANSPORT TYCOON');

  DrawButton(11, 'ENTER', 'NEW GAME');
  DrawButton(12, Game.IsGame, 'ESC', 'CONTINUE');
  terminal_color('white');
  DrawButton(13, 'Q', 'QUIT');

  DrawText(32, 17, 'APROMIX (C) 2022');
end;

procedure TSceneMainMenu.Update(var Key: word);
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
