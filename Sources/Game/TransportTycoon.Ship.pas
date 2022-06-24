unit TransportTycoon.Ship;

interface

uses
  TransportTycoon.Vehicle,
  TransportTycoon.Order;

type
  TShip = class(TVehicle)
  private

  public
    constructor Create(const AName: string; const AX, AY, ID: Integer);
  end;

implementation

uses
  SysUtils,
  TransportTycoon.Game,
  TransportTycoon.Finances,
  TransportTycoon.PathFind,
  TransportTycoon.Map;

function IsPath(X, Y: Integer): Boolean; stdcall;
begin
  Result := Game.Map.Cell[X][Y] in [tlTown, tlWater] + IndustryTiles;
end;

constructor TShip.Create(const AName: string; const AX, AY, ID: Integer);
begin
  inherited Create(AName, AX, AY);
end;

end.
