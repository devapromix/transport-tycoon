unit TransportTycoon.Calendar;

interface

const
  MonStr: array [1 .. 12] of string = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');

type
  TCalendar = class(TObject)
  private
    FDay: Word;
    FYear: Word;
    FMonth: Word;
    function DaysPerMonth(const AMonth: Byte): Byte;
  public const
    StartYear = 1950;
    FinishYear = 2050;
  public
    constructor Create;
    procedure Clear;
    procedure Step;
    property Day: Word read FDay write FDay;
    property Month: Word read FMonth write FMonth;
    property Year: Word read FYear write FYear;
    function GetDate: string;
    procedure PrevYear;
    procedure NextYear;
    procedure OnMonth();
    procedure OnYear();
  end;

implementation

uses
  SysUtils,
  TransportTycoon.Game,
  TransportTycoon.Finances,
  TransportTycoon.Scenes;

procedure TCalendar.Clear;
begin
  FDay := 1;
  FMonth := 1;
  FYear := StartYear;
end;

constructor TCalendar.Create;
begin
  Clear;
end;

function TCalendar.DaysPerMonth(const AMonth: Byte): Byte;
const
  DaysInMonth: array [1 .. 12] of Byte = (31, 28, 31, 30, 31, 30, 31, 31, 30,
    31, 30, 31);
begin
  Result := DaysInMonth[AMonth];
end;

function TCalendar.GetDate: string;
begin
  Result := Format('%s %d, %d', [MonStr[Game.Calendar.Month], Game.Calendar.Day,
    Game.Calendar.Year]);
end;

procedure TCalendar.NextYear;
begin
  if FYear < FinishYear then
    Inc(FYear);
end;

procedure TCalendar.OnMonth;
begin
  Game.Map.Grows;
  Game.Vehicles.RunningCosts;
  Game.ModifyMoney(ttLoanInterest, -(Game.Loan div 600));
end;

procedure TCalendar.OnYear;
begin
  Scenes.SetScene(scFinances);
end;

procedure TCalendar.PrevYear;
begin
  if FYear > StartYear then
    Dec(FYear);
end;

procedure TCalendar.Step;
begin
  Inc(FDay);
  if (FDay > DaysPerMonth(FMonth)) then
  begin
    FDay := 1;
    Inc(FMonth);
    OnMonth;
  end;
  if (FMonth > 12) then
  begin
    FMonth := 1;
    Inc(FYear);
    OnYear;
  end;
end;

end.
