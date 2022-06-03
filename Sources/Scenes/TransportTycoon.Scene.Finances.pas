unit TransportTycoon.Scene.Finances;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneFinances = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  BearLibTerminal,
  Math,
  SysUtils,
  TransportTycoon.Game;

procedure TSceneFinances.Render;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(10, 5, 60, 15);
  DrawTitle(Game.CompanyName + ' Finances');

  DrawText(12, 9, 'Aircraft Income:');
  DrawMoney(30, 9, Game.AircraftIncome);

  DrawText(12, 11, 'Construction:');
  DrawMoney(30, 11, -Game.Construction);
  DrawText(12, 12, 'New Vehicles:');
  DrawMoney(30, 12, -Game.NewVehicles);

  DrawText(12, 14, 'Bank Balance: $' + IntToStr(Game.Money));

  DrawButton(17, 'ESC', 'CLOSE');

  DrawBar;
end;

procedure TSceneFinances.Update(var Key: Word);
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (MX >= 36) and (MX <= 46) then
      case MY of
        17:
          Key := TK_ESCAPE;
      end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scWorld);
  end;

end;

end.
