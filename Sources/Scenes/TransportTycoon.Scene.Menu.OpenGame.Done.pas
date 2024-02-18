unit TransportTycoon.Scene.Menu.OpenGame.Done;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Game;

type

  { TSceneOpenGameDoneMenu }

  TSceneOpenGameDoneMenu = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var AKey: Word); override;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal;

{ TSceneOpenGameDoneMenu }

procedure TSceneOpenGameDoneMenu.Render;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);

  DrawFrame(25, 10, 30, 9);

  DrawTitle(12, Game.Company.Name);
  DrawText(14, 'Game opened!');
  AddButton(16, 'Enter', 'Close');
  DrawText(35, 21, '[[ESC]] CLOSE', False);

  DrawGameBar;
end;

procedure TSceneOpenGameDoneMenu.Update(var AKey: Word);
begin
  if (AKey = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
    begin
      case MX of
        34 .. 46:
          AKey := TK_ENTER;
      end;
    end;
  end;
  case AKey of
    TK_ENTER:
      begin
        Game.IsPause := False;
        Scenes.SetScene(scWorld);
      end;
  end;
end;

end.
