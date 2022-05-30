unit TransportTycoon.Game;

interface

uses
  Classes,
  SysUtils,
  TransportTycoon.Map;

type

  { TGame }

  TGame = class(TObject)
  private

  public
    Map: TMap;
    Turn: Integer;
    Money: Integer;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
  end;

var
  Game: TGame;

implementation


{ TGame }

constructor TGame.Create;
begin
  Map := TMap.Create;
  Self.Clear;
end;

destructor TGame.Destroy;
begin
  Map.Free;
  inherited Destroy;
end;

procedure TGame.Clear;
begin
  Turn := 0;
  Money := 100000;
  Map.Gen;
end;

initialization
  Game := TGame.Create;

finalization
  Game.Free;

end.
