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
    procedure Update(var Key: Word); override;
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
  DrawBar;
end;

procedure TSceneVehicles.Update(var Key: Word);
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
  end;
end;

end.
