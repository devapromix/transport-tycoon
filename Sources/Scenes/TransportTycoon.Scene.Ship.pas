unit TransportTycoon.Scene.Ship;

interface

uses
  TransportTycoon.Scenes;

type

  { TSceneShip }

  TSceneShip = class(TScene)
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
  TransportTycoon.Ship;

{ TSceneShip }

procedure TSceneShip.Render;
begin

end;

procedure TSceneShip.Update(var Key: Word);
begin

end;

end.
