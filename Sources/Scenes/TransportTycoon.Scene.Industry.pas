unit TransportTycoon.Scene.Industry;

interface

uses
  TransportTycoon.Scenes;

type

  { TSceneIndustry }

  TSceneIndustry = class(TScene)
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

{ TSceneIndustry }

var
  Industry: TIndustry;

procedure TSceneIndustry.Render;
begin
  DrawMap(Self.Width, Self.Height - 1);

  Industry := Game.Map.Industry[Game.Map.CurrentIndustry];

  DrawFrame(20, 8, 40, 13);
  DrawTitle(10, Industry.Name);

  with Industry do
  begin

  end;

  AddButton(18, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneIndustry.Update(var Key: Word);
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
    begin
      if (MX >= 35) and (MX <= 45) then
        Key := TK_ESCAPE;
    end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scWorld);
  end;
end;

end.
