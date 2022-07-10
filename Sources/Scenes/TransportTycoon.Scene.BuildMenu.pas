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
  TransportTycoon.Game;

{ TSceneBuildMenu }

procedure TSceneBuildMenu.Render;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(20, 8, 40, 13);
  DrawTitle(10, Game.Company.Name);

  DrawButton(22, 12, 'C', 'Build Canals');

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
        end;
    end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.Back;
    TK_C:
      begin
        Game.IsBuildCanals := True;
        Game.IsClearLand := False;
        Scenes.SetScene(scWorld);
      end;
  end;
end;

end.
