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

  DrawFrame(20, 8, 40, 13);
  DrawTitle(10, 'TRANSPORT TYCOON');

  DrawButton(13, 'ENTER', 'NEW GAME');
  DrawButton(14, Game.IsGame, 'ESC', 'CONTINUE');
  terminal_color('white');
  DrawButton(15, 'Q', 'QUIT');

  DrawText(18, 'Apromix (C) 2022');
end;

procedure TSceneMainMenu.Update(var Key: word);
begin
  if (Key = TK_MOUSE_LEFT) then
    case MY of
      13:
        Key := TK_ENTER;
      14:
        Key := TK_ESCAPE;
      15:
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
        Game.Calendar.Clear;
        Game.IsGame := False;
        Game.LoadSettings;
        Scenes.SetScene(scGenMenu);
      end;
    TK_Q:
      terminal_close();
  end;
end;

end.
