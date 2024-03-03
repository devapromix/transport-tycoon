unit TransportTycoon.Scene.Menu.Main;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneMainMenu = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var AKey: Word); override;
  end;

implementation

uses
  BearLibTerminal,
  SysUtils,
  TransportTycoon.Game,
  TransportTycoon.Scene.Menu.Settings,
  TransportTycoon.Scene.Dialog;

procedure Close();
begin
  terminal_close();
end;

procedure TSceneMainMenu.Render;
begin
  Game.Map.Draw(Self.ScreenWidth, Self.ScreenHeight);

  DrawFrame('TRANSPORT TYCOON', 40, 12);

  DrawButton(13, 'ENTER', 'NEW GAME');
  DrawButton(14, Game.IsGame, 'ESC', 'CONTINUE');
  DrawButton(15, 'L', 'OPEN GAME');
  DrawButton(16, 'D', 'SETTINGS');
  DrawButton(17, 'Q', 'QUIT');

  DrawText(19, 'By Apromix 2022-2024');
end;

procedure TSceneMainMenu.Update(var AKey: Word);
begin
  if (AKey = TK_MOUSE_LEFT) then
    case MX of
      32 .. 47:
        case MY of
          13:
            AKey := TK_ENTER;
          14:
            AKey := TK_ESCAPE;
          15:
            AKey := TK_L;
          16:
            AKey := TK_D;
          17:
            AKey := TK_Q;
        end;
    end;
  case AKey of
    TK_ESCAPE:
      if Game.IsGame then
      begin
        Game.IsPause := False;
        Scenes.SetScene(scWorld);
      end;
    TK_ENTER:
      begin
        Game.IsGame := False;
        Game.LoadSettings;
        Scenes.SetScene(scGenMenu);
      end;
    TK_L:
      begin
        Game.ScanSaveDir;
        Scenes.SetScene(scOpenGameMenu);
      end;
    TK_D:
      begin
        TSceneSettingsMenu(Scenes.GetScene(scSettingsMenu)).IsShowBar := False;
        Scenes.SetScene(scSettingsMenu, scMainMenu);
      end;
    TK_Q:
      TSceneDialogPrompt.Ask('Quit', 'Leave the game?', scMainMenu, nil);
      // @Close);
  end;
end;

end.
