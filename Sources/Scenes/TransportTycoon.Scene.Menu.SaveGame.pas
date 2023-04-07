unit TransportTycoon.Scene.Menu.SaveGame;

interface

uses
  TransportTycoon.Scenes;

type
  TSaveMenuSubScene = (sscDefault, sscPrompt, sscSaved);

type

  { TSceneSaveGameMenu }

  TSceneSaveGameMenu = class(TScene)
  private
    FDialog: Byte;
  public
    procedure Render; override;
    procedure Update(var AKey: Word); override;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Game;

var
  LSubScene: TSaveMenuSubScene = sscSaved;

  { TSceneSaveGameMenu }

procedure TSceneSaveGameMenu.Render;
var
  LSlot: TSlot;
const
  LY = 10;
begin
  Game.Map.Draw(Self.ScreenWidth, Self.ScreenHeight);
  case LSubScene of
    sscDefault:
      begin
        DrawFrame(10, 6, 60, 18);
        DrawTitle(8, 'SAVE CURRENT GAME');

        for LSlot := Low(TSlot) to High(TSlot) do
          DrawButton(12, LSlot + 10, True, Chr(Ord('A') + LSlot),
            Game.GetSlotStr(LSlot));
        AddButton(21, 'Esc', 'Close');
      end;
    sscPrompt:
      ;
    sscSaved:
      begin
        DrawFrame(20, LY, 40, 9);
        DrawTitle(LY + 2, 'SAVE CURRENT GAME');
        DrawText(LY + 4, 'Game saved!');
        AddButton(LY + 6, 'Esc', 'Close');
      end;
  end;
end;

procedure TSceneSaveGameMenu.Update(var AKey: Word);
var
  LSlot: Integer;
begin
  if (AKey = TK_MOUSE_LEFT) then
  begin
    case LSubScene of
      sscDefault:
        if (GetButtonsY = MY) then
        begin
          case MX of
            35 .. 45:
              AKey := TK_ESCAPE;
          end;
        end;
    end;
  end;
  case LSubScene of
    sscDefault:
      case AKey of
        TK_ESCAPE:
          Scenes.SetScene(scWorld);
        TK_A .. TK_J:
          begin
            LSlot := AKey - TK_A;
            if (LSlot >= 0) and (LSlot <= 9) then
              Game.Save(LSlot);
          end;
      end;
    sscSaved:
      case AKey of
        TK_ESCAPE:
          Scenes.SetScene(scWorld);
      end;
  end;
end;

end.
