unit TransportTycoon.Scene.Menu.OpenGame;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Game;

type

  { TSceneOpenGameMenu }

  TSceneOpenGameMenu = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var AKey: Word); override;
    class procedure Load;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal;

var
  FCurrentSlot: TSlot;

  { TSceneOpenGameMenu }

class procedure TSceneOpenGameMenu.Load;
begin
  if Game.IsGame then
    Scenes.SetScene(scOpenGamePromptMenu)
  else
    Game.Load(FCurrentSlot);
end;

procedure TSceneOpenGameMenu.Render;
var
  LSlot: TSlot;
begin
  Game.Map.Draw(Self.ScreenWidth, Self.ScreenHeight);

  DrawFrame('OPEN SAVED GAME', 60, 18, True);

  for LSlot := Low(TSlot) to High(TSlot) do
    DrawButton(12, LSlot + 10, (Game.GetSlotStr(LSlot) <> Game.EmptySlotStr),
      Chr(Ord('A') + LSlot), Game.GetSlotStr(LSlot));
end;

procedure TSceneOpenGameMenu.Update(var AKey: Word);
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
      Scenes.SetScene(scMainMenu);
    TK_A .. TK_J:
      begin
        FCurrentSlot := AKey - TK_A;
        if (FCurrentSlot >= 0) and (FCurrentSlot <= 9) then
          if Game.IsSlotFileExists(FCurrentSlot) then
            Load;
      end;
  end;
end;

end.
