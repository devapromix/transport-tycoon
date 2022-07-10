unit TransportTycoon.Scene.BuildInTown;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Industries;

type

  { TSceneBuildInTown }

  TSceneBuildInTown = class(TScene)
  private
    FTown: TTownIndustry;
  public
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  Math,
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Game;

{ TSceneBuildInTown }

procedure TSceneBuildInTown.Render;
var
  N: Integer;
  S: string;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(15, 7, 50, 15);

  FTown := TTownIndustry(Game.Map.Industry[Game.Map.CurrentIndustry]);
  DrawTitle('BUILD IN ' + FTown.Name);

  S := '';
  N := Math.EnsureRange(FTown.Airport.Level + 1, 0, 5);
  if FTown.Airport.Level < FTown.Airport.MaxLevel then
    S := ' ($' + IntToStr(FTown.Airport.Cost) + ')';
  DrawButton(17, 11, FTown.Airport.CanBuild, 'A',
    'Build ' + AirportSizeStr[N] + S);

  S := '';
  if FTown.Dock.Level = 0 then
    S := ' ($' + IntToStr(FTown.Dock.Cost) + ')';
  DrawButton(17, 12, FTown.Dock.CanBuild(FTown.X, FTown.Y), 'B',
    'Build Dock' + S);

  if (Game.Map.CurrentIndustry = Game.Company.TownID) then
    DrawButton(17, 17, FTown.HQ.CanBuild, 'G', 'Build Company Headquarters ($' +
      IntToStr(FTown.HQ.Cost) + ')');

  AddButton(19, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneBuildInTown.Update(var Key: Word);
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
      case MX of
        35 .. 45:
          Key := TK_ESCAPE;
      end;
    case MX of
      17 .. 62:
        case MY of
          11:
            Key := TK_A;
          12:
            Key := TK_B;
          17:
            Key := TK_G;
        end;
    end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scTown);
    TK_A:
      begin
        if FTown.Airport.CanBuild then
        begin
          FTown.Airport.Build;
          Scenes.SetScene(scAirport, scTown);
        end;
      end;
    TK_B:
      begin
        if FTown.Dock.CanBuild(FTown.X, FTown.Y) then
        begin
          FTown.Dock.Build;
          Scenes.SetScene(scDock, scTown);
        end;
      end;
    TK_G:
      begin
        if FTown.HQ.CanBuild and (Game.Map.CurrentIndustry = Game.Company.TownID)
        then
        begin
          FTown.HQ.Build;
          Scenes.SetScene(scCompany, scTown);
        end;
      end;
  end;
end;

end.
