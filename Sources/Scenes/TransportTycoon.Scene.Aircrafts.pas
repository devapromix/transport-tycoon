unit TransportTycoon.Scene.Aircrafts;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneAircrafts = class(TScene)
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

procedure TSceneAircrafts.Render;
var
  I: Integer;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(10, 7, 60, 15);

  DrawTitle(Game.CompanyName + ' AIRCRAFTS');

  for I := 0 to Length(Game.Vehicles.Aircraft) - 1 do
    DrawButton(12, I + 11, Chr(Ord('A') + I), Game.Vehicles.Aircraft[I].Name);

  AddButton(19, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneAircrafts.Update(var Key: Word);
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (MX >= 12) and (MX <= 38) then
      case MY of
        11 .. 17:
          Key := TK_A + (MY - 11);
      end;
    if (GetButtonsY = MY) then
      if (MX >= 35) and (MX <= 45) then
        Key := TK_ESCAPE;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scWorld);
    TK_A .. TK_G:
      begin
        if Key - TK_A > Length(Game.Vehicles.Aircraft) - 1 then
          Exit;
        Game.Vehicles.CurrentVehicle := Key - TK_A;
        Scenes.SetScene(scAircraft);
      end;
  end;
end;

end.
