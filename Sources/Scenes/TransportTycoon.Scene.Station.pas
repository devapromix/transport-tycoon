unit TransportTycoon.Scene.Station;

interface

uses
  TransportTycoon.Scenes;

type

  { TSceneStation }

  TSceneStation = class(TScene)
  public
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  BearLibTerminal,
  SysUtils;

{ TSceneStation }

procedure TSceneStation.Render;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);
  DrawFrame(5, 7, 70, 15);
end;

procedure TSceneStation.Update(var Key: Word);
var
  I: Integer;
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    case MX of
      37 .. 71:
        begin
          I := MY - 11;
          case MY of
            11 .. 17:
              Key := TK_A + I;
          end;
        end;
    end;
  end;
end;

end.
