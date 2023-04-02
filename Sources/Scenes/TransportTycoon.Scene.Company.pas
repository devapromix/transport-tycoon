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
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  BearLibTerminal,
  SysUtils,
  TransportTycoon.Game,
  TransportTycoon.Industries,
  TransportTycoon.Races;

procedure TSceneCompany.AddStatLine(const AConstructEnum: TConstructEnum);
const
  StatStr: array [TConstructEnum] of string = ('', 'Canals', 'Roads', 'Tunnels',
    'Road Bridges');
begin
  if Game.Company.Stat.GetStat(AConstructEnum) = 0 then
    Exit;
  DrawText(FX, FY, StatStr[AConstructEnum] + ': ' +
    IntToStr(Game.Company.Stat.GetStat(AConstructEnum)));
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

  DrawFrame(20, 8, 40, 14);
  DrawTitle(10, Game.Company.Name);
  DrawText(22, 12, 'Race: ' + GameRaceStr[Game.Race]);
  DrawText(40, 12, 'Inavgurated: ' + IntToStr(Game.Company.Inavgurated));
  FX := 22;
  FY := 14;
  for LConstructEnum := Succ(Low(TConstructEnum)) to High(TConstructEnum) do
    AddStatLine(LConstructEnum);

  if TTownIndustry(Game.Map.Industry[Game.Company.TownID]).HQ.IsBuilding then
    DrawText(22, 17, 'Company headquarters in ' + Game.Map.Industry
      [Game.Company.TownID].Name);

  AddButton(19, 'Esc', 'Close');

  DrawGameBar;
end;

procedure TSceneCompany.Update(var Key: Word);
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
  end;
  case Key of
    TK_ESCAPE:
      Scenes.Back;
  end;
end;

end.
