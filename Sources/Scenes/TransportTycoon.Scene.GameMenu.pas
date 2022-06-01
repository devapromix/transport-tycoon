unit TransportTycoon.Scene.GameMenu;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneGameMenu = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var Key: word); override;
  end;

implementation

uses
  BearLibTerminal,
  Math,
  SysUtils,
  TransportTycoon.Game,
  TransportTycoon.Scene.World;

{ TSceneGameMenu }

procedure TSceneGameMenu.Render;
begin
  Game.Map.Draw(Self.Width, Self.Height - 1);

  DrawFrame(10, 5, 60, 15);
  DrawTitle('TRANSPORT TYCOON');

  DrawButton(12, 9, '?', 'COMPANY FINANCES INFO');
  DrawButton(42, 9, '?', 'GENERAL COMPANY INFO');

  DrawButton(42, 15, 'X', 'CLEAR LAND');

  DrawButton(29, 17, 'Q', 'QUIT');
  DrawText(38, 17, '|');
  DrawButton(40, 17, 'ESC', 'CLOSE');

  TSceneWorld(Scenes.GetScene(scWorld)).DrawBar;
end;

procedure TSceneGameMenu.Update(var Key: word);
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (MX >= 29) and (MX <= 36) then
      case MY of
        17:
          Key := TK_Q;
      end;
    if (MX >= 40) and (MX <= 50) then
      case MY of
        17:
          Key := TK_ESCAPE;
      end;
  end;
  case Key of
    TK_ESCAPE:
      begin
        Scenes.SetScene(scWorld);
      end;
    TK_Q:
      begin
        Game.IsPause := True;
        Scenes.SetScene(scMainMenu);
      end;
    TK_X:
      begin
        Game.IsClearLand := True;
        Scenes.SetScene(scWorld);
      end;
  end;
end;

end.
