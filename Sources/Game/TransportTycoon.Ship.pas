unit TransportTycoon.Ship;

interface

uses
  TransportTycoon.Vehicle,
  TransportTycoon.Order;

type
  TShipBase = record
    Name: string;
    Passengers: Word;
    BagsOfMail: Word;
    Cost: Word;
    RunningCost: Word;
    Speed: Word;
    Since: Word;
  end;

const
  ShipBase: array [0 .. 0] of TShipBase = (
    // #1
    (Name: ''; Passengers: 120; BagsOfMail: 10; Cost: 25000;
    RunningCost: 90 * 12; Speed: 50; Since: 1950)
    //
    );

type
  TShip = class(TVehicle)
  private
    FT: Integer;
    FDistance: Integer;
    FState: string;
    FLastAirportId: Integer;
    FPassengers: Integer;
    FMaxPassengers: Integer;
    FBagsOfMail: Integer;
    FMaxBagsOfMail: Integer;
    FOrderIndex: Integer;
  public
    Order: array of TOrder;
    constructor Create(const AName: string; const AX, AY, ID: Integer);
    function Move(const AX, AY: Integer): Boolean; override;
    property Distance: Integer read FDistance;
    property Passengers: Integer read FPassengers write FPassengers;
    property MaxPassengers: Integer read FMaxPassengers;
    property BagsOfMail: Integer read FBagsOfMail write FBagsOfMail;
    property MaxBagsOfMail: Integer read FMaxBagsOfMail;
    property State: string read FState;
    property LastDockId: Integer write FLastAirportId;
    property OrderIndex: Integer read FOrderIndex;
    procedure Step; override;
    procedure Load;
    procedure UnLoad;
    procedure AddOrder(const TownIndex: Integer); overload;
    procedure AddOrder(const TownIndex: Integer; const AName: string;
      const AX, AY: Integer); overload;
    procedure DelOrder(const AOrderIndex: Integer);
    function IsOrder(const TownIndex: Integer): Boolean;
  end;

implementation

uses
  SysUtils,
  TransportTycoon.Map,
  TransportTycoon.Game,
  TransportTycoon.Finances,
  TransportTycoon.PathFind;

function IsPath(X, Y: Integer): Boolean; stdcall;
begin
  Result := Game.Map.Cell[X][Y] in [tlTown, tlWater] + IndustryTiles;
end;

procedure TShip.AddOrder(const TownIndex: Integer; const AName: string;
  const AX, AY: Integer);
begin

end;

procedure TShip.AddOrder(const TownIndex: Integer);
begin

end;

constructor TShip.Create(const AName: string; const AX, AY, ID: Integer);
begin
  inherited Create(AName, AX, AY);
  FT := 0;
  FState := 'Wait';
  FMaxPassengers := ShipBase[ID].Passengers;
  FPassengers := 0;
  FMaxBagsOfMail := ShipBase[ID].BagsOfMail;
  FBagsOfMail := 0;
  FOrderIndex := 0;
  LastDockId := 0;
  FDistance := 0;
end;

procedure TShip.DelOrder(const AOrderIndex: Integer);
begin

end;

function TShip.IsOrder(const TownIndex: Integer): Boolean;
begin

end;

procedure TShip.Load;
begin

end;

function TShip.Move(const AX, AY: Integer): Boolean;
begin

end;

procedure TShip.Step;
begin
  inherited;

end;

procedure TShip.UnLoad;
begin

end;

end.
