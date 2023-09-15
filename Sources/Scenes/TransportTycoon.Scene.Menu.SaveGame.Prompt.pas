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
  BearLibTerminal;

{ TSceneSaveGameMenu }

procedure TSceneSaveGamePromptMenu.Render;
var
  LSlot: TSlot;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);

  DrawFrame(10, 6, 60, 18);

  DrawTitle(8, 'SAVE CURRENT GAME');
  for LSlot := Low(TSlot) to High(TSlot) do
    DrawButton(12, LSlot + 10, True, Chr(Ord('A') + LSlot),
      Game.GetSlotStr(LSlot));

  DrawFrame(20, 10, 40, 9);
  DrawTitle(12, 'SAVE CURRENT GAME');
  DrawText(14, 'Replace saved game?');
  AddButton(16, 'Enter', 'Replace');
  AddButton(16, 'Esc', 'Cancel');
  DrawText(35, 21, '[[ESC]] CLOSE', False);

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
  //case AKey of
    //TK_ESCAPE:
      //FSubScene := sscDefault;
    //TK_ENTER:
      //Save;
  //end;
end;

end.
