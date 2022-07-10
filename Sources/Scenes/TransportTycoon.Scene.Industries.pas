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
    procedure Update(var Key: Word); override;
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
  I, J: Integer;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(25, 4, 30, 21);

  DrawTitle(6, 'INDUSTRIES');

  J := 0;
  for I := 0 to Length(Game.Map.Industry) - 1 do
    if (Game.Map.Industry[I].IndustryType <> inTown) then
    begin
      DrawButton(27, J + 8, Chr(Ord('A') + J), Game.Map.Industry[I].Name);
      Inc(J);
    end;

  AddButton(22, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneIndustries.Update(var Key: Word);
var
  I: Integer;
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    case MX of
      27 .. 51:
        case MY of
          8 .. 18:
            Key := TK_A + (MY - 8);
        end;
    end;
    if (GetButtonsY = MY) then
      case MX of
        35 .. 45:
          Key := TK_ESCAPE;
      end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scWorld);
    TK_A .. TK_K:
      with Game.Map do
      begin
        I := Key - TK_A;
        if (I < Length(Industry) - TownCount) then
        begin
          CurrentIndustry := TownCount + I;
          ScrollTo(Industry[CurrentIndustry].X, Industry[CurrentIndustry].Y);
          Scenes.SetScene(scIndustry);
        end;
      end;
  end;
end;

end.
