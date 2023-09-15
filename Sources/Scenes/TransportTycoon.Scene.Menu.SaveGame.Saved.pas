unit TransportTycoon.Scene.Menu.SaveGame.Saved;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Game;

type

  { TSceneSaveGameSavedMenu }

  TSceneSaveGameSavedMenu = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var AKey: Word); override;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal;

{ TSceneSaveGameSavedMenu }

procedure TSceneSaveGameSavedMenu.Render;
begin
  DrawFrame(25, 10, 30, 9);
  DrawTitle(12, 'SAVE CURRENT GAME');
  DrawText(14, 'Game saved!');
  AddButton(16, 'Enter', 'Close');
  DrawText(35, 21, '[[ESC]] CLOSE', False);
end;

procedure TSceneSaveGameSavedMenu.Update(var AKey: Word);
begin
  if (GetButtonsY = MY) then
  begin
    case MX of
      34 .. 46:
        AKey := TK_ENTER;
    end;
  end;

  case AKey of
    TK_ENTER:
      begin
        Game.IsPause := False;
        // FSubScene := sscDefault;
        Scenes.SetScene(scWorld);
      end;
  end;
end;

end.
