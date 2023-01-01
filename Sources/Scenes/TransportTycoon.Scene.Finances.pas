unit TransportTycoon.Scene.Finances;

interface

uses
  TransportTycoon.Scenes;

type

  { TSceneFinances }

  TSceneFinances = class(TScene)
  private
    procedure DrawIncome(const AX, AYear: Word);
    procedure DrawRunningCosts(const AX, AYear: Word);
    procedure DrawLoanInterest(const AX, AYear: Word);
  public
    procedure Render; override;
    procedure Update(var AKey: Word); override;
  end;

implementation

uses
  Math,
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Game,
  TransportTycoon.Finances;

const
  PX: array [0 .. 2] of Word = (40, 50, 60);

  { TSceneFinances }

procedure TSceneFinances.DrawIncome(const AX, AYear: Word);
begin
  DrawText(10, 5, 'Road Vehicle Income:');
  DrawMoney(AX + 8, 5, Game.Finances.Value(ttRoadVehicleIncome, AYear));
  DrawText(10, 6, 'Train Income:');
  DrawMoney(AX + 8, 6, Game.Finances.Value(ttTrainIncome, AYear));
  DrawText(10, 7, 'Ship Income:');
  DrawMoney(AX + 8, 7, Game.Finances.Value(ttShipIncome, AYear));
  DrawText(10, 8, 'Aircraft Income:');
  DrawMoney(AX + 8, 8, Game.Finances.Value(ttAircraftIncome, AYear));
  DrawText(AX, 8, '_________');
  DrawText(30, 9, 'Total:');
  DrawMoney(AX + 8, 9, Game.Finances.Values([ttRoadVehicleIncome, ttTrainIncome,
    ttShipIncome, ttAircraftIncome], AYear));
end;

procedure TSceneFinances.DrawLoanInterest(const AX, AYear: Word);
begin
  DrawText(10, 17, 'Loan Interest:');
  DrawMoney(AX + 8, 17, -Game.Finances.Value(ttLoanInterest, AYear));
  DrawText(10, 18, 'Construction:');
  DrawMoney(AX + 8, 18, -Game.Finances.Value(ttConstruction, AYear));
  DrawText(10, 19, 'New Vehicles:');
  DrawMoney(AX + 8, 19, -Game.Finances.Value(ttNewVehicles, AYear));
  DrawText(AX, 19, '_________');
  DrawText(30, 20, 'Total:');
  DrawMoney(AX + 8, 20, Game.Finances.Values([ttRoadVehicleIncome,
    ttTrainIncome, ttShipIncome, ttAircraftIncome], AYear) -
    Game.Finances.Values([ttRoadVehicleRunningCosts, ttTrainRunningCosts,
    ttShipRunningCosts, ttAircraftRunningCosts, ttConstruction, ttNewVehicles,
    ttLoanInterest], AYear));
end;

procedure TSceneFinances.DrawRunningCosts(const AX, AYear: Word);
begin
  DrawText(10, 11, 'Road Vehicle Running Costs:');
  DrawMoney(AX + 8, 11, -Game.Finances.Value(ttRoadVehicleRunningCosts, AYear));
  DrawText(10, 12, 'Train Running Costs:');
  DrawMoney(AX + 8, 12, -Game.Finances.Value(ttTrainRunningCosts, AYear));
  DrawText(10, 13, 'Ship Running Costs:');
  DrawMoney(AX + 8, 13, -Game.Finances.Value(ttShipRunningCosts, AYear));
  DrawText(10, 14, 'Aircraft Running Costs:');
  DrawMoney(AX + 8, 14, -Game.Finances.Value(ttAircraftRunningCosts, AYear));
  DrawText(AX, 14, '_________');
  DrawText(30, 15, 'Total:');
  DrawMoney(AX + 8, 15, -Game.Finances.Values([ttRoadVehicleRunningCosts,
    ttTrainRunningCosts, ttShipRunningCosts, ttAircraftRunningCosts], AYear));
end;

procedure TSceneFinances.Render;
var
  LColumn, LYear, LLastYear: Word;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);

  DrawFrame(8, 0, 64, 29);
  DrawTitle(2, Game.Company.Name + ' Finances');

  terminal_composition(TK_ON);

  LColumn := 0;
  for LLastYear := EnsureRange(Game.Finances.Count - 1, 0, 2) downto 0 do
  begin
    LYear := Game.Calendar.Year - LLastYear;
    DrawText(PX[LColumn] + 5, 4, IntToStr(LYear));
    DrawText(PX[LColumn] + 5, 4, '____');
    DrawIncome(PX[LColumn], LYear);
    DrawRunningCosts(PX[LColumn], LYear);
    DrawLoanInterest(PX[LColumn], LYear);
    Inc(LColumn);
  end;

  DrawText(10, 22, 'Bank Balance:');
  DrawMoney(38, 22, Game.Money);
  DrawText(10, 23, 'Loan:');
  DrawText(30, 23, '_________');

  DrawMoney(38, 23, Game.Loan);
  DrawText(40, 23, Format('Max. Loan: $%d', [Game.MaxLoan]));
  DrawMoney(38, 24, Game.Money - Game.Loan);
  terminal_composition(TK_OFF);

  AddButton(26, Game.CanBorrow, 'B', 'BORROW');
  AddButton(26, Game.CanRepay, 'R', 'REPAY');
  AddButton(26, 'ESC', 'CLOSE');

  DrawGameBar;
end;

procedure TSceneFinances.Update(var AKey: Word);
begin
  if (AKey = TK_MOUSE_LEFT) then
    if (GetButtonsY = MY) then
      case MX of
        22 .. 31:
          AKey := TK_B;
        35 .. 43:
          AKey := TK_R;
        47 .. 57:
          AKey := TK_ESCAPE;
      end;
  case AKey of
    TK_ESCAPE:
      Scenes.SetScene(scWorld);
    TK_B:
      Game.Borrow;
    TK_R:
      Game.Repay;
  end;

end;

end.
