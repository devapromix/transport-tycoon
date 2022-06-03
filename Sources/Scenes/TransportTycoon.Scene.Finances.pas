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
  TransportTycoon.Game,
  TransportTycoon.Finances;

procedure TSceneFinances.Render;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(8, 1, 64, 22);
  DrawTitle(3, Game.CompanyName + ' Finances');

  DrawText(40, 5, IntToStr(Game.Year));
  DrawText(50, 5, IntToStr(Game.Year + 1));
  DrawText(60, 5, IntToStr(Game.Year + 2));

  DrawButton(10, 7, False, 'I', 'Transport Income:');
  DrawMoney(40, 7, Game.Finances.Values([ttRoadVehicleIncome, ttTrainIncome,
    ttShipIncome, ttAircraftIncome]));
  DrawButton(10, 9, False, 'C', 'Transport Running Costs:');
  DrawMoney(40, 9, Game.Finances.Values([ttRoadVehicleRunningCosts,
    ttTrainRunningCosts, ttShipRunningCosts, ttAircraftRunningCosts]));

  DrawText(10, 11, 'Loan Interest:');
  DrawMoney(40, 11, -Game.Finances.Value[ttLoanInterest]);
  DrawText(10, 12, 'Construction:');
  DrawMoney(40, 12, -Game.Finances.Value[ttConstruction]);
  DrawText(10, 13, 'New Vehicles:');
  DrawMoney(40, 13, -Game.Finances.Value[ttNewVehicles]);
  DrawText(30, 14, 'Total:');
  DrawMoney(40, 14, Game.Finances.Values([ttRoadVehicleIncome, ttTrainIncome,
    ttShipIncome, ttAircraftIncome]) - Game.Finances.Values
    ([ttRoadVehicleRunningCosts, ttTrainRunningCosts, ttShipRunningCosts,
    ttAircraftRunningCosts, ttConstruction, ttNewVehicles, ttLoanInterest]));

  DrawText(10, 16, 'Bank Balance:');
  DrawMoney(30, 16, Game.Money);
  DrawText(10, 17, 'Loan:');
  DrawMoney(30, 17, Game.Loan);
  DrawText(40, 17, Format('Max. Loan: $%d', [Game.MaxLoan]));
  DrawMoney(30, 18, Game.Money - Game.Loan);

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
    TK_I:
      ;
    TK_C:
      ;
    TK_B:
      ;
    TK_R:
      ;
  end;

end;

end.
