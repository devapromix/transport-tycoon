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
  public const
    StartYear = 1950;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Step;
    property Day: Word read FDay write FDay;
    property Month: Word read FMonth write FMonth;
    property Year: Word read FYear write FYear;
    function GetDate: string;
    procedure NextYear;
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

destructor TCalendar.Destroy;
begin

  inherited;
end;

function TCalendar.GetDate: string;
begin
  Result := Format('%s %d, %d', [MonStr[Game.Calendar.Month], Game.Calendar.Day,
    Game.Calendar.Year]);
end;

procedure TCalendar.NextYear;
begin
  Inc(FYear);
end;

procedure TCalendar.Step;
begin
  Inc(FDay);
  if FDay > 30 then
  begin
    FDay := 1;
    Inc(FMonth);
    Game.CityGrow;
    Game.Vehicles.RunningCosts;
    Game.ModifyMoney(ttLoanInterest, -(Game.Loan div 600));
  end;
  if FMonth > 12 then
  begin
    FMonth := 1;
    Inc(FYear);
    Scenes.SetScene(scFinances);
  end;
end;

end.
