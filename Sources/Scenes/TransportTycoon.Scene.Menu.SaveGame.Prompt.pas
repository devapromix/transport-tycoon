unit TransportTycoon.Scene.Menu.SaveGame.Prompt;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Game;

type

  { TSceneSaveGameMenu }

  TSceneSaveGamePromptMenu = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var AKey: Word); override;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Scene.Menu.SaveGame;

{ TSceneSaveGameMenu }

procedure TSceneSaveGamePromptMenu.Render;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);

  DrawFrame('SAVE CURRENT GAME', 40, 9);
  DrawText(15, 'Replace saved game?');
  AddButton(17, 'Enter', 'Replace');
  AddButton(17, 'Esc', 'Cancel');

  DrawGameBar;
end;

procedure TSceneSaveGamePromptMenu.Update(var AKey: Word);
begin
  if (AKey = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
    begin
      case MX of
        25 .. 39:
          AKey := TK_ENTER;
        43 .. 54:
          AKey := TK_ESCAPE;
      end;
    end;
  end;
  case AKey of
    TK_ESCAPE:
      Scenes.SetScene(scSaveGameMenu);
    TK_ENTER:
      TSceneSaveGameMenu.Save;
  end;
end;

end.
