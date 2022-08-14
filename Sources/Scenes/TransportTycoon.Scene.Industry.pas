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
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);

  FIndustry := Game.Map.Industry[Game.Map.CurrentIndustry];

  DrawFrame(10, 8, 60, 13);

  with FIndustry do
  begin
    DrawTitle(10, Name);

    DrawButton(34, 12, 35, Dock.IsBuilding, Dock.IsBuilding, 'D', 'Dock');
    DrawButton(34, 13, 35, TruckLoadingBay.IsBuilding,
      TruckLoadingBay.IsBuilding, 'L', 'Truck Loading Bay');
  end;

  IndustryInfo(FIndustry, 12, 16);

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
          13:
            Key := TK_L;
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
    TK_L:
      if FIndustry.TruckLoadingBay.IsBuilding then
        Scenes.SetScene(scTruckLoadingBay, scIndustry);
  end;
end;

end.
