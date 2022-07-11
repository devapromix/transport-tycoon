unit TransportTycoon.Scene.Finances;

interface

uses
  TransportTycoon.Scenes;

type

  { TSceneFinances }

  TSceneFinances = class(TScene)
  private
    procedure DrawIncome(const X, Year: Word);
    procedure DrawRunningCosts(const X, Year: Word);
    procedure DrawLoanInterest(const X, Year: Word);
  public
    procedure Render; override;
    procedure Update(var Key: Word); override;
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

procedure TSceneFinances.DrawIncome(const X, Year: Word);
begin
  DrawText(10, 5, 'Road Vehicle Income:');
  DrawMoney(X + 8, 5, Game.Finances.Value(ttRoadVehicleIncome, Year));
  DrawText(10, 6, 'Train Income:');
  DrawMoney(X + 8, 6, Game.Finances.Value(ttTrainIncome, Year));
  DrawText(10, 7, 'Ship Income:');
  DrawMoney(X + 8, 7, Game.Finances.Value(ttShipIncome, Year));
  DrawText(10, 8, 'Aircraft Income:');
  DrawMoney(X + 8, 8, Game.Finances.Value(ttAircraftIncome, Year));
  DrawText(X, 8, '_________');
  DrawText(30, 9, 'Total:');
  DrawMoney(X + 8, 9, Game.Finances.Values([ttRoadVehicleIncome, ttTrainIncome,
    ttShipIncome, ttAircraftIncome], Year));
end;

procedure TSceneFinances.DrawLoanInterest(const X, Year: Word);
begin
  DrawText(10, 17, 'Loan Interest:');
  DrawMoney(X + 8, 17, -Game.Finances.Value(ttLoanInterest, Year));
  DrawText(10, 18, 'Construction:');
  DrawMoney(X + 8, 18, -Game.Finances.Value(ttConstruction, Year));
  DrawText(10, 19, 'New Vehicles:');
  DrawMoney(X + 8, 19, -Game.Finances.Value(ttNewVehicles, Year));
  DrawText(X, 19, '_________');
  DrawText(30, 20, 'Total:');
  DrawMoney(X + 8, 20, Game.Finances.Values([ttRoadVehicleIncome, ttTrainIncome,
    ttShipIncome, ttAircraftIncome], Year) - Game.Finances.Values
    ([ttRoadVehicleRunningCosts, ttTrainRunningCosts, ttShipRunningCosts,
    ttAircraftRunningCosts, ttConstruction, ttNewVehicles,
    ttLoanInterest], Year));
end;

procedure TSceneFinances.DrawRunningCosts(const X, Year: Word);
begin
  DrawText(10, 11, 'Road Vehicle Running Costs:');
  DrawMoney(X + 8, 11, -Game.Finances.Value(ttRoadVehicleRunningCosts, Year));
  DrawText(10, 12, 'Train Running Costs:');
  DrawMoney(X + 8, 12, -Game.Finances.Value(ttTrainRunningCosts, Year));
  DrawText(10, 13, 'Ship Running Costs:');
  DrawMoney(X + 8, 13, -Game.Finances.Value(ttShipRunningCosts, Year));
  DrawText(10, 14, 'Aircraft Running Costs:');
  DrawMoney(X + 8, 14, -Game.Finances.Value(ttAircraftRunningCosts, Year));
  DrawText(X, 14, '_________');
  DrawText(30, 15, 'Total:');
  DrawMoney(X + 8, 15, -Game.Finances.Values([ttRoadVehicleRunningCosts,
    ttTrainRunningCosts, ttShipRunningCosts, ttAircraftRunningCosts], Year));
end;

procedure TSceneFinances.Render;
var
  I, J, Year: Word;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(8, 0, 64, 29);
  DrawTitle(2, Game.Company.Name + ' Finances');

  terminal_composition(TK_ON);

  J := 0;
  for I := EnsureRange(Game.Finances.Count - 1, 0, 2) downto 0 do
  begin
    Year := Game.Calendar.Year - I;
    DrawText(PX[J] + 5, 4, IntToStr(Year));
    DrawText(PX[J] + 5, 4, '____');
    DrawIncome(PX[J], Year);
    DrawRunningCosts(PX[J], Year);
    DrawLoanInterest(PX[J], Year);
    Inc(J);
  end;

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
      case MX of
        22 .. 31:
          Key := TK_B;
        35 .. 43:
          Key := TK_R;
        47 .. 57:
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
