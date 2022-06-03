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

  DrawFrame(10, 1, 60, 22);
  DrawTitle(3, Game.CompanyName + ' Finances');

  DrawText(40, 5, IntToStr(Game.Year));
  DrawText(50, 5, IntToStr(Game.Year + 1));
  DrawText(60, 5, IntToStr(Game.Year + 2));

  DrawText(12, 7, 'Road Vehicle Running Costs:');
  DrawMoney(40, 7, Game.AircraftIncome + 200000);
  DrawText(12, 8, 'Train Income:');
  DrawMoney(40, 8, Game.AircraftIncome);
  DrawText(12, 9, 'Ship Income:');
  DrawMoney(40, 9, Game.AircraftIncome);
  DrawText(12, 10, 'Aircraft Income:');
  DrawMoney(40, 10, Game.AircraftIncome + 2000);
  DrawText(30, 11, 'Total:');
  DrawMoney(40, 11, Game.AircraftIncome + 2000);

  DrawText(12, 13, 'Construction:');
  DrawMoney(40, 13, -Game.Construction);
  DrawText(12, 14, 'New Vehicles:');
  DrawMoney(40, 14, -Game.NewVehicles);
  DrawText(12, 15, 'Other:');
  DrawMoney(40, 15, -Game.Other);
  DrawText(30, 16, 'Total:');
  DrawMoney(40, 16, -(Game.Construction + Game.NewVehicles + Game.Other));

  DrawText(12, 18, 'Bank Balance: $' + IntToStr(Game.Money));
  DrawText(40, 18, Format('Loan: $%d/$%d', [100000, 100000]));

  DrawButton(20, 'ESC', 'CLOSE');

  DrawBar;
end;

procedure TSceneFinances.Update(var Key: Word);
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (MX >= 36) and (MX <= 46) then
      case MY of
        20:
          Key := TK_ESCAPE;
      end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scWorld);
  end;

end;

end.
