unit TransportTycoon.Scene.BuildMenu;

interface

uses
  TransportTycoon.Scenes;

type

  { TSceneBuildMenu }

  TSceneBuildMenu = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Game,
  TransportTycoon.Construct;

{ TSceneBuildMenu }

procedure TSceneBuildMenu.Render;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);

  DrawFrame(20, 8, 40, 13);
  DrawTitle(10, Game.Company.Name);

  DrawButton(22, 12, 'C', 'Build Canal');
  DrawButton(22, 13, 'R', 'Build Road');

  DrawButton(22, 16, 'X', 'Clear land');

  AddButton(18, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneBuildMenu.Update(var Key: Word);
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
    begin
      case MX of
        35 .. 45:
          Key := TK_ESCAPE;
      end;
    end;
    case MX of
      22 .. 56:
        case MY of
          12:
            Key := TK_C;
          13:
            Key := TK_R;
          16:
            Key := TK_X;
        end;
    end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.Back;
    TK_C:
      begin
        Game.Construct.Build(ceBuildCanal);
        Scenes.SetScene(scWorld);
      end;
    TK_R:
      begin
        Game.Construct.Build(ceBuildRoad);
        Scenes.SetScene(scWorld);
      end;
    TK_X:
      begin
        Game.Construct.Build(ceClearLand);
        Scenes.SetScene(scWorld);
      end;
  end;
end;

end.
