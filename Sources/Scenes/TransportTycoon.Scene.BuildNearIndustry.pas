unit TransportTycoon.Scene.BuildNearIndustry;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Industries;

type

  { TSceneBuildNearIndustry }

  TSceneBuildNearIndustry = class(TScene)
  private
    FIndustry: TIndustry;
  public
    procedure Render; override;
    procedure Update(var AKey: Word); override;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Game;

{ TSceneBuildNearIndustry }

procedure TSceneBuildNearIndustry.Render;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);

  DrawFrame(15, 7, 50, 15);

  FIndustry := Game.Map.Industry[Game.Map.CurrentIndustry];
  DrawTitle('BUILD IN ' + FIndustry.Name);
  // Dock
  DrawBuildingTitle('Dock', 'D', 11, FIndustry.Dock.CanBuild(FIndustry.X,
    FIndustry.Y), FIndustry.Dock.Cost, FIndustry.Dock.Level = 0);
  // Truck Loading Bay
  DrawBuildingTitle('Truck Loading Bay', 'L', 12,
    FIndustry.TruckLoadingBay.CanBuild, FIndustry.TruckLoadingBay.Cost,
    FIndustry.TruckLoadingBay.Level = 0);

  AddButton(19, 'Esc', 'Close');

  DrawGameBar;
end;

procedure TSceneBuildNearIndustry.Update(var AKey: Word);
begin
  if (AKey = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
    begin
      case MX of
        35 .. 45:
          case MY of
            19:
              AKey := TK_ESCAPE;
          end;
      end;
    end;
    case MX of
      17 .. 62:
        case MY of
          11:
            AKey := TK_D;
          12:
            AKey := TK_L;
        end;
    end;
  end;
  case AKey of
    TK_ESCAPE:
      Scenes.SetScene(scIndustry);
    TK_D:
      begin
        if FIndustry.Dock.CanBuild(FIndustry.X, FIndustry.Y) then
        begin
          FIndustry.Dock.Build;
          Scenes.SetScene(scDock, scIndustry);
        end;
      end;
    TK_L:
      begin
        if FIndustry.TruckLoadingBay.CanBuild then
        begin
          FIndustry.TruckLoadingBay.Build;
          Scenes.SetScene(scTruckLoadingBay, scIndustry);
        end;
      end;
  end;
end;

end.
