unit TransportTycoon.Scene.Menu.OpenGame.Prompt;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Game;

type

  { TSceneOpenGameMenu }

  TSceneOpenGamePromptMenu = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var AKey: Word); override;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Scene.Menu.OpenGame;

{ TSceneOpenGamePromptMenu }

procedure TSceneOpenGamePromptMenu.Render;
begin
  Game.Map.Draw(Self.ScreenWidth, Self.ScreenHeight);

  DrawFrame('OPEN SAVED GAME', 40, 9);
  DrawText(15, 'Continue?');
  AddButton(17, 'Enter', 'Open');
  AddButton(17, 'Esc', 'Cancel');
end;

procedure TSceneOpenGamePromptMenu.Update(var AKey: Word);
begin
  if (AKey = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
    begin
      case MX of
        27 .. 38:
          AKey := TK_ENTER;
        42 .. 53:
          AKey := TK_ESCAPE;
      end;
    end;
  end;
  case AKey of
    TK_ESCAPE:
      Scenes.SetScene(scOpenGameMenu);
    TK_ENTER:
      begin
        Game.IsGame := False;
        TSceneOpenGameMenu.Load;
      end;
  end;
end;

end.
