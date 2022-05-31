unit TransportTycoon.Scene.City;

interface

uses
  TransportTycoon.Scenes;

type

  TSceneCity = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var Key: word); override;
  end;

implementation

uses
  BearLibTerminal,
  TransportTycoon.Game;

procedure TSceneCity.Render;
begin
  Game.Map.Draw(Self.Width, Self.Height - 1);

  DrawFrame(10, 5, 60, 15);
  DrawTitle('EDINTON');

  DrawText(34, 17, 'BUILD | CLOSE');

  TSceneGame(Scenes.GetScene(scGame)).DrawBar;

end;

procedure TSceneCity.Update(var Key: word);
begin
  if (Key = TK_MOUSE_LEFT) and (MX >= 34) and (MX <= 39) then
    case MY of
      17:
        begin
          Scenes.SetScene(scBuildInCity);
        end;
    end;
  if (Key = TK_MOUSE_LEFT) and (MX >= 41) and (MX <= 46) then
    case MY of
      17:
        begin
          Scenes.SetScene(scGame);
        end;
    end;
end;

end.
