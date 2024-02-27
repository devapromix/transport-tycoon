unit TransportTycoon.Scene.Industries;

interface

uses
  TransportTycoon.Scenes;

type

  { TSceneIndustries }

  TSceneIndustries = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var AKey: Word); override;
  end;

implementation

uses
  BearLibTerminal,
  SysUtils,
  TransportTycoon.Game,
  TransportTycoon.Industries;

{ TSceneIndustries }

procedure TSceneIndustries.Render;
var
  LIndustry, LY: Integer;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);

  DrawFrame(25, 4, 30, 21);

  DrawTitle(6, 'INDUSTRIES');

  LY := 0;
  for LIndustry := 0 to Length(Game.Map.Industry) - 1 do
    if (Game.Map.Industry[LIndustry].IndustryType <> inTown) then
    begin
      DrawButton(27, LY + 8, Chr(Ord('A') + LY),
        StrLim(Game.Map.Industry[LIndustry].Name, 22));
      Inc(LY);
    end;

  AddButton(22, 'Esc', 'Close');

  DrawGameBar;
end;

procedure TSceneIndustries.Update(var AKey: Word);
var
  LIndustry: Integer;
begin
  if (AKey = TK_MOUSE_LEFT) then
  begin
    case MX of
      27 .. 51:
        case MY of
          8 .. 18:
            AKey := TK_A + (MY - 8);
        end;
    end;
    if (GetButtonsY = MY) then
      case MX of
        35 .. 45:
          AKey := TK_ESCAPE;
      end;
  end;
  case AKey of
    TK_ESCAPE:
      Scenes.SetScene(scWorld);
    TK_A .. TK_K:
      with Game.Map do
      begin
        LIndustry := AKey - TK_A;
        if (LIndustry < Length(Industry) - TownCount) then
        begin
          CurrentIndustry := TownCount + LIndustry;
          ScrollTo(Industry[CurrentIndustry].X, Industry[CurrentIndustry].Y);
          Scenes.SetScene(scIndustry);
        end;
      end;
  end;
end;

end.
