unit TransportTycoon.Scene.Menu.SaveGame;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Game;

type

  { TSceneSaveGameMenu }

  TSceneSaveGameMenu = class(TScene)
  private
    procedure Save;
  public
    procedure Render; override;
    procedure Update(var AKey: Word); override;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal;

var
  FCurrentSlot: TSlot;

  { TSceneSaveGameMenu }

procedure TSceneSaveGameMenu.Render;
var
  LSlot: TSlot;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);

  DrawFrame(10, 6, 60, 18);

  DrawTitle(8, 'SAVE CURRENT GAME');
  for LSlot := Low(TSlot) to High(TSlot) do
    DrawButton(12, LSlot + 10, True, Chr(Ord('A') + LSlot),
      Game.GetSlotStr(LSlot));

  AddButton(21, 'Esc', 'Close');

  DrawGameBar;
end;

procedure TSceneSaveGameMenu.Save;
begin
  // FSubScene := sscSaved;
  Game.Save(FCurrentSlot);
end;

procedure TSceneSaveGameMenu.Update(var AKey: Word);
begin
  if (AKey = TK_MOUSE_LEFT) then
  begin
    case MX of
      12 .. 66:
        case MY of
          10 .. 19:
            AKey := TK_A + (MY - 10);
        end;
    end;
    if (GetButtonsY = MY) then
    begin
      case MX of
        35 .. 45:
          AKey := TK_ESCAPE;
      end;
    end;
  end;
  case AKey of
    TK_ESCAPE:
      begin
        Game.IsPause := False;
        Scenes.SetScene(scWorld);
      end;
    TK_A .. TK_J:
      begin
        FCurrentSlot := AKey - TK_A;
        if (FCurrentSlot >= 0) and (FCurrentSlot <= 9) then
          // if Game.IsSlotFileExists(FCurrentSlot) then
          // FSubScene := sscPrompt
          // else
          // Save;
      end;
  end;
end;

end.
