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

  DrawFrame(8, 0, 64, 29);
  DrawTitle(2, Game.CompanyName + ' Finances');

  DrawText(40, 4, IntToStr(Game.Year));
  DrawText(50, 4, IntToStr(Game.Year + 1));
  DrawText(60, 4, IntToStr(Game.Year + 2));

  terminal_composition(TK_ON);
  DrawText(10, 5, 'Road Vehicle Income:');
  DrawMoney(40, 5, Game.Finances.Value[ttRoadVehicleIncome]);
  DrawText(10, 6, 'Train Income:');
  DrawMoney(40, 6, Game.Finances.Value[ttTrainIncome]);
  DrawText(10, 7, 'Ship Income:');
  DrawMoney(40, 7, Game.Finances.Value[ttShipIncome]);
  DrawText(10, 8, 'Aircraft Income:');
  DrawMoney(40, 8, Game.Finances.Value[ttAircraftIncome]);
  DrawText(40, 8, '_________');
  DrawText(50, 8, '_________');
  DrawText(60, 8, '_________');
  DrawText(30, 9, 'Total:');

  DrawText(10, 11, 'Road Vehicle Running Costs:');
  DrawMoney(40, 11, -Game.Finances.Value[ttRoadVehicleRunningCosts]);
  DrawText(10, 12, 'Train Running Costs:');
  DrawMoney(40, 12, -Game.Finances.Value[ttTrainRunningCosts]);
  DrawText(10, 13, 'Ship Running Costs:');
  DrawMoney(40, 13, -Game.Finances.Value[ttShipRunningCosts]);
  DrawText(10, 14, 'Aircraft Running Costs:');
  DrawMoney(40, 14, -Game.Finances.Value[ttAircraftRunningCosts]);
  DrawText(40, 14, '_________');
  DrawText(50, 14, '_________');
  DrawText(60, 14, '_________');
  DrawText(30, 15, 'Total:');

  DrawText(10, 17, 'Loan Interest:');
  DrawMoney(40, 17, -Game.Finances.Value[ttLoanInterest]);
  DrawText(10, 18, 'Construction:');
  DrawMoney(40, 18, -Game.Finances.Value[ttConstruction]);
  DrawText(10, 19, 'New Vehicles:');
  DrawMoney(40, 19, -Game.Finances.Value[ttNewVehicles]);
  DrawText(40, 19, '_________');
  DrawText(50, 19, '_________');
  DrawText(60, 19, '_________');
  DrawText(30, 20, 'Total:');
  DrawMoney(40, 20, Game.Finances.Values([ttRoadVehicleIncome, ttTrainIncome,
    ttShipIncome, ttAircraftIncome]) - Game.Finances.Values
    ([ttRoadVehicleRunningCosts, ttTrainRunningCosts, ttShipRunningCosts,
    ttAircraftRunningCosts, ttConstruction, ttNewVehicles, ttLoanInterest]));

  DrawText(10, 22, 'Bank Balance:');
  DrawMoney(30, 22, Game.Money);
  DrawText(10, 23, 'Loan:');
  DrawText(30, 23, '_________');

  DrawMoney(30, 23, Game.Loan);
  DrawText(40, 23, Format('Max. Loan: $%d', [Game.MaxLoan]));
  DrawMoney(30, 24, Game.Money - Game.Loan);
  terminal_composition(TK_OFF);

  AddButton(26, 'ESC', 'CLOSE');

  DrawBar;
end;

procedure TSceneFinances.Update(var Key: Word);
begin
  if (Key = TK_MOUSE_LEFT) then
    if (GetButtonsY = MY) then
    begin
      if (MX >= 35) and (MX <= 45) then
        Key := TK_ESCAPE;
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
