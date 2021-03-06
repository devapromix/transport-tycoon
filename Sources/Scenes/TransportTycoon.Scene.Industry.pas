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
    procedure IndustryInfo(const AIndustry: TIndustry; const AX, AY: Integer);
  end;

implementation

uses
  BearLibTerminal,
  SysUtils,
  TransportTycoon.Game;

{ TSceneIndustry }

procedure TSceneIndustry.IndustryInfo(const AIndustry: TIndustry;
  const AX, AY: Integer);
var
  I: Integer;
begin
  I := AY;
  if AIndustry.Produces <> [] then
  begin
    DrawText(AX, I, 'Produces: ' + AIndustry.GetCargoStr(AIndustry.Produces));
    Dec(I);
  end;
  if AIndustry.Accepts <> [] then
  begin
    DrawText(AX, I, 'Accepts: ' + AIndustry.GetCargoStr(AIndustry.Accepts));
    Dec(I);
  end;
end;

procedure TSceneIndustry.Render;
begin
  DrawMap(Self.Width, Self.Height - 1);

  FIndustry := Game.Map.Industry[Game.Map.CurrentIndustry];

  with FIndustry do
  begin
    DrawFrame(20, 8, 40, 13);
    DrawTitle(10, Name);

    DrawButton(34, 12, Dock.IsBuilding, 'D',
      'Dock: ' + DockSizeStr[Dock.Level]);
  end;

  IndustryInfo(FIndustry, 22, 16);

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
      case MX of
        29 .. 37:
          Key := TK_B;
        41 .. 51:
          Key := TK_ESCAPE;
      end;
    end;
    case MX of
      34 .. 56:
        case MY of
          12:
            Key := TK_D;
        end;
    end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scWorld);
    TK_B:
      Scenes.SetScene(scBuildNearIndustry);
    TK_D:
      if FIndustry.Dock.IsBuilding then
        Scenes.SetScene(scDock, scIndustry);
  end;
end;

end.
