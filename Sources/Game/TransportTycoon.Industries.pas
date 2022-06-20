unit TransportTycoon.Industries;

interface

uses
  TransportTycoon.MapObject;

type
  TCargo = (cgNone, cgCoal);

type
  TIndustry = class(TMapObject)
  private
    FProduces: TCargo;
    FAccepts: TCargo;
  public
    constructor Create(const AName: string; const AX, AY: Integer);
    property Accepts: TCargo read FAccepts;
    property Produces: TCargo read FProduces;
  end;

implementation

uses
  SysUtils;

constructor TIndustry.Create(const AName: string; const AX, AY: Integer);
begin
  inherited Create(AName, AX, AY);
  FAccepts := cgNone;
  FProduces := cgNone;
end;

end.
