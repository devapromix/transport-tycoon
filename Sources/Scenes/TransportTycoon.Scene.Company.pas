unit TransportTycoon.Scene.Company;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Construct,
  TransportTycoon.Company;

type
  TSceneCompany = class(TScene)
  private
    FX: Integer;
    FY: Integer;
    procedure AddStatLine(const AConstructEnum: TConstructEnum);
  public
    procedure Render; override;
    procedure Update(var AKey: Word); override;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Game,
  TransportTycoon.Industries,
  TransportTycoon.Races,
  TransportTycoon.Map;

procedure TSceneCompany.AddStatLine(const AConstructEnum: TConstructEnum);
begin
  if (Game.Company.GetStatistic(AConstructEnum) = 0) or
    (Construct[AConstructEnum].StatName = '') then
    Exit;
  DrawText(FX, FY, Construct[AConstructEnum].StatName + ': ' +
    IntToStr(Game.Company.GetStatistic(AConstructEnum)));
  if FX = 40 then
  begin
    FX := 22;
    Inc(FY);
    Exit;
  end;
  if FX = 22 then
    FX := 40;
end;

procedure TSceneCompany.Render;
var
  LConstructEnum: TConstructEnum;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);

  DrawFrame(Game.Company.GetName, 40, 14, True);
  DrawText(22, 12, 'Race: ' + GameRaceStr[Game.Race]);
  DrawText(40, 12, 'Inavgurated: ' + IntToStr(Game.Company.Inavgurated));
  FX := 22;
  FY := 14;
  for LConstructEnum := Succ(Low(TConstructEnum)) to High(TConstructEnum) do
    AddStatLine(LConstructEnum);

  if TTownIndustry(Game.Map.Industry[Game.Company.TownIndex]).HQ.IsBuilding then
    DrawText(22, 17, 'Company headquarters in ' + Game.Map.Industry
      [Game.Company.TownIndex].Name);

  DrawGameBar;
end;

procedure TSceneCompany.Update(var AKey: Word);
begin
  if (AKey = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
    begin
      case MX of
        35 .. 45:
          AKey := TK_ESCAPE;
      end;
    end;
  end;
  case AKey of
    TK_ESCAPE:
      Scenes.Back;
  end;
end;

end.
