unit TransportTycoon.Scene.Menu.OpenGame;

interface

uses
  TransportTycoon.Scenes;

type

  { TSceneOpenGameMenu }

  TSceneOpenGameMenu = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var AKey: Word); override;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Game;

{ TSceneOpenGameMenu }

procedure TSceneOpenGameMenu.Render;
var
  LSlot: TSlot;
begin
  Game.Map.Draw(Self.ScreenWidth, Self.ScreenHeight);

  DrawFrame(10, 6, 60, 18);
  DrawTitle(8, 'OPEN SAVED GAME');

  for LSlot := Low(TSlot) to High(TSlot) do
    DrawButton(12, LSlot + 10, (Game.GetSlotStr(LSlot) <> 'EMPTY SLOT'),
      Chr(Ord('A') + LSlot), Game.GetSlotStr(LSlot));

  AddButton(21, 'Esc', 'Close');
end;

procedure TSceneOpenGameMenu.Update(var AKey: Word);
var
  LSlot: Integer;
begin
  if (AKey = TK_MOUSE_LEFT) then
  begin
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
        LSlot := AKey - TK_A;
        if (LSlot >= 0) and (LSlot <= 9) then
          Game.Load(LSlot);
      end;
  end;
end;

end.
