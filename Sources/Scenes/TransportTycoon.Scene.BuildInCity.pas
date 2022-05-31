unit TransportTycoon.Scene.BuildInCity;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneBuildInCity = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var Key: word); override;
  end;

implementation

uses
  BearLibTerminal,
  TransportTycoon.Game,
  TransportTycoon.Scene.World;

{ TSceneBuildInCity }

procedure TSceneBuildInCity.Render;
begin
  Game.Map.Draw(Self.Width, Self.Height - 1);

  DrawFrame(10, 5, 60, 15);
  DrawTitle('BUILD');

  DrawText(38, 17, 'CLOSE');

  TSceneWorld(Scenes.GetScene(scWorld)).DrawBar;
end;

procedure TSceneBuildInCity.Update(var Key: word);
begin
  if (Key = TK_MOUSE_LEFT) and (MX >= 38) and (MX <= 42) then
    case MY of
      17:
        begin
          Scenes.SetScene(scCity);
        end;
    end;
end;

end.
