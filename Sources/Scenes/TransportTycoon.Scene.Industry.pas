unit TransportTycoon.Scene.Industry;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Industries;

type

  { TSceneIndustry }

  TSceneIndustry = class(TScene)
  private
    FIndustry: TIndustry;
  public
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  BearLibTerminal,
  SysUtils,
  TransportTycoon.Game;

{ TSceneIndustry }

procedure TSceneIndustry.Render;
begin
  DrawMap(Self.Width, Self.Height - 1);

  FIndustry := Game.Map.Industry[Game.Map.CurrentIndustry];

  with FIndustry do
  begin
    DrawFrame(20, 8, 40, 13);
    DrawTitle(10, Name);

    DrawButton(34, 12, Dock.HasBuilding, 'D',
      'Dock: ' + DockSizeStr[Dock.Level]);
  end;

  AddButton(18, 'B', 'Build');
  AddButton(18, 'ESC', 'Close');

  DrawBar;
end;

procedure TSceneIndustry.Update(var Key: Word);
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
    begin
      if (MX >= 29) and (MX <= 37) then
        case MY of
          18:
            Key := TK_B;
        end;
      if (MX >= 41) and (MX <= 51) then
        case MY of
          18:
            Key := TK_ESCAPE;
        end;
    end;
    if (MX >= 34) and (MX <= 56) then
      case MY of
        12:
          Key := TK_D;
      end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scWorld);
    TK_B:
      Scenes.SetScene(scBuildNearIndustry);
    TK_D:
      if FIndustry.Dock.HasBuilding then
        Scenes.SetScene(scDock, scIndustry);
  end;
end;

end.
