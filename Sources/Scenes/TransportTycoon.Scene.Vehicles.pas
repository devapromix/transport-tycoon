unit TransportTycoon.Scene.Vehicles;

interface

uses
  TransportTycoon.Scenes;

type

  { TSceneVehicles }

  TSceneVehicles = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var AKey: Word); override;
  end;

implementation

uses
  BearLibTerminal;

{ TSceneVehicles }

procedure TSceneVehicles.Render;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);
  DrawFrame(10, 7, 60, 15);
  AddButton(19, 'Esc', 'Close');
  DrawGameBar;
end;

procedure TSceneVehicles.Update(var AKey: Word);
begin
  if (AKey = TK_MOUSE_LEFT) then
  begin
    if (MX >= 12) and (MX <= 38) then
      case MY of
        11 .. 17:
          AKey := TK_A + (MY - 11);
      end;
    if (GetButtonsY = MY) then
      if (MX >= 35) and (MX <= 45) then
        AKey := TK_ESCAPE;
  end;
  case AKey of
    TK_ESCAPE:
      Scenes.SetScene(scWorld);
  end;
end;

end.
