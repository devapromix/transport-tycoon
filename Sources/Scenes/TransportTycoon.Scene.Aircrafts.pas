unit TransportTycoon.Scene.Aircrafts;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Scene.Vehicles;

type

  { TSceneAircrafts }

  TSceneAircrafts = class(TSceneVehicles)
  private

  public
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  BearLibTerminal,
  SysUtils,
  TransportTycoon.Game;

{ TSceneAircrafts }

procedure TSceneAircrafts.Render;
var
  I: Integer;
begin
  inherited Render;
  DrawTitle(Game.Company.Name + ' AIRCRAFTS');
  for I := 0 to Length(Game.Vehicles.Aircraft) - 1 do
    DrawButton(12, I + 11, Chr(Ord('A') + I), Game.Vehicles.Aircraft[I].Name);
end;

procedure TSceneAircrafts.Update(var Key: Word);
var
  I: Integer;
begin
  inherited Update(Key);
  case Key of
    TK_A .. TK_G:
      begin
        I := Key - TK_A;
        if I > Length(Game.Vehicles.Aircraft) - 1 then
          Exit;
        Game.Vehicles.CurrentVehicle := I;
        with Game.Vehicles.Aircraft[I] do
          ScrollTo(X, Y);
        Scenes.SetScene(scAircraft, scAircrafts);
      end;
  end;
end;

end.
