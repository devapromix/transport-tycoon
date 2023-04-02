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
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Game;

{ TSceneBuildNearIndustry }

procedure TSceneBuildNearIndustry.Render;
var
  S: string;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);

  DrawFrame(15, 7, 50, 15);

  FIndustry := Game.Map.Industry[Game.Map.CurrentIndustry];
  DrawTitle('BUILD IN ' + FIndustry.Name);
  // Dock
  S := '';
  if FIndustry.Dock.Level = 0 then
    S := ' ($' + IntToStr(FIndustry.Dock.Cost) + ')';
  DrawButton(17, 11, FIndustry.Dock.CanBuild(FIndustry.X, FIndustry.Y), 'D',
    'Build Dock' + S);
  // Truck Loading Bay
  S := '';
  if FIndustry.TruckLoadingBay.Level = 0 then
    S := ' ($' + IntToStr(FIndustry.TruckLoadingBay.Cost) + ')';
  DrawButton(17, 12, FIndustry.TruckLoadingBay.CanBuild, 'L',
    'Build Truck Loading Bay' + S);

  AddButton(19, 'Esc', 'Close');

  DrawGameBar;
end;

procedure TSceneBuildNearIndustry.Update(var Key: Word);
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
    begin
      case MX of
        35 .. 45:
          case MY of
            19:
              Key := TK_ESCAPE;
          end;
      end;
    end;
    case MX of
      17 .. 62:
        case MY of
          11:
            Key := TK_D;
          12:
            Key := TK_L;
        end;
    end;
  end;
  case Key of
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
