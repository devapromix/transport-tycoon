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
  SysUtils,
  TransportTycoon.Game,
  TransportTycoon.Finances;

procedure TSceneFinances.Render;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(8, 0, 64, 29);
  DrawTitle(2, Game.Company.Name + ' Finances');

  terminal_composition(TK_ON);
  DrawText(45, 4, IntToStr(Game.Calendar.Year));
  DrawText(55, 4, IntToStr(Game.Calendar.Year + 1));
  DrawText(65, 4, IntToStr(Game.Calendar.Year + 2));
  DrawText(45, 4, '____');
  DrawText(55, 4, '____');
  DrawText(65, 4, '____');

  DrawText(10, 5, 'Road Vehicle Income:');
  DrawMoney(48, 5, Game.Finances.Value[ttRoadVehicleIncome]);
  DrawText(10, 6, 'Train Income:');
  DrawMoney(48, 6, Game.Finances.Value[ttTrainIncome]);
  DrawText(10, 7, 'Ship Income:');
  DrawMoney(48, 7, Game.Finances.Value[ttShipIncome]);
  DrawText(10, 8, 'Aircraft Income:');
  DrawMoney(48, 8, Game.Finances.Value[ttAircraftIncome]);
  DrawText(40, 8, '_________');
  DrawText(50, 8, '_________');
  DrawText(60, 8, '_________');
  DrawText(30, 9, 'Total:');
  DrawMoney(48, 9, Game.Finances.Values([ttRoadVehicleIncome, ttTrainIncome,
    ttShipIncome, ttAircraftIncome]));

  DrawText(10, 11, 'Road Vehicle Running Costs:');
  DrawMoney(48, 11, -Game.Finances.Value[ttRoadVehicleRunningCosts]);
  DrawText(10, 12, 'Train Running Costs:');
  DrawMoney(48, 12, -Game.Finances.Value[ttTrainRunningCosts]);
  DrawText(10, 13, 'Ship Running Costs:');
  DrawMoney(48, 13, -Game.Finances.Value[ttShipRunningCosts]);
  DrawText(10, 14, 'Aircraft Running Costs:');
  DrawMoney(48, 14, -Game.Finances.Value[ttAircraftRunningCosts]);
  DrawText(40, 14, '_________');
  DrawText(50, 14, '_________');
  DrawText(60, 14, '_________');
  DrawText(30, 15, 'Total:');
  DrawMoney(48, 15, -Game.Finances.Values([ttRoadVehicleRunningCosts,
    ttTrainRunningCosts, ttShipRunningCosts, ttAircraftRunningCosts]));

  DrawText(10, 17, 'Loan Interest:');
  DrawMoney(48, 17, -Game.Finances.Value[ttLoanInterest]);
  DrawText(10, 18, 'Construction:');
  DrawMoney(48, 18, -Game.Finances.Value[ttConstruction]);
  DrawText(10, 19, 'New Vehicles:');
  DrawMoney(48, 19, -Game.Finances.Value[ttNewVehicles]);
  DrawText(40, 19, '_________');
  DrawText(50, 19, '_________');
  DrawText(60, 19, '_________');
  DrawText(30, 20, 'Total:');
  DrawMoney(48, 20, Game.Finances.Values([ttRoadVehicleIncome, ttTrainIncome,
    ttShipIncome, ttAircraftIncome]) - Game.Finances.Values
    ([ttRoadVehicleRunningCosts, ttTrainRunningCosts, ttShipRunningCosts,
    ttAircraftRunningCosts, ttConstruction, ttNewVehicles, ttLoanInterest]));

  DrawText(10, 22, 'Bank Balance:');
  DrawMoney(38, 22, Game.Money);
  DrawText(10, 23, 'Loan:');
  DrawText(30, 23, '_________');

  DrawMoney(38, 23, Game.Loan);
  DrawText(40, 23, Format('Max. Loan: $%d', [Game.MaxLoan]));
  DrawMoney(38, 24, Game.Money - Game.Loan);
  terminal_composition(TK_OFF);

  AddButton(26, 'B', 'BORROW');
  AddButton(26, 'R', 'REPAY');
  AddButton(26, 'ESC', 'CLOSE');

  DrawBar;
end;

procedure TSceneFinances.Update(var Key: Word);
begin
  if (Key = TK_MOUSE_LEFT) then
    if (GetButtonsY = MY) then
    begin
      if (MX >= 22) and (MX <= 31) then
        Key := TK_B;
      if (MX >= 35) and (MX <= 43) then
        Key := TK_R;
      if (MX >= 47) and (MX <= 57) then
        Key := TK_ESCAPE;
    end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scWorld);
    TK_B:
      Game.Borrow;
    TK_R:
      Game.Repay;
  end;

end;

end.
