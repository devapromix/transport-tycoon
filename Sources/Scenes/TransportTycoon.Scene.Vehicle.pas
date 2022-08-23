unit TransportTycoon.Scene.Vehicle;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneVehicle = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  BearLibTerminal,
  SysUtils;

{ TSceneVehicle }

procedure TSceneVehicle.Render;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);
  DrawFrame(5, 7, 70, 15);

  AddButton(19, 'O', 'Add Order');
  AddButton(19, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneVehicle.Update(var Key: Word);
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    case MX of
      29 .. 71:
        case MY of
          11 .. 17:
            Key := TK_A + (MY - 11);
        end;
    end;
    case MX of
      27 .. 39:
        case MY of
          19:
            Key := TK_O;
        end;
      43 .. 53:
        case MY of
          19:
            Key := TK_ESCAPE;
        end;
    end;
    case MX of
      7 .. 25:
        case MY of
          17:
            Key := TK_L;
        end;
    end;
  end;
end;

end.
