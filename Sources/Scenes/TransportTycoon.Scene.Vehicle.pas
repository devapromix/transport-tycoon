unit TransportTycoon.Scene.Vehicle;

interface

uses
  TransportTycoon.Scenes;

type

  { TSceneVehicle }

  TSceneVehicle = class(TScene)
  private
    FIsDetails: Boolean;
  public
    procedure Render; override;
    procedure Update(var AKey: Word); override;
    property IsDetails: Boolean read FIsDetails write FIsDetails;
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

  DrawGameBar;
end;

procedure TSceneVehicle.Update(var AKey: Word);
begin
  if (AKey = TK_MOUSE_LEFT) then
  begin
    case MX of
      29 .. 71:
        case MY of
          11 .. 17:
            AKey := TK_A + (MY - 11);
        end;
    end;
    case MX of
      27 .. 39:
        case MY of
          19:
            AKey := TK_O;
        end;
      43 .. 53:
        case MY of
          19:
            AKey := TK_ESCAPE;
        end;
    end;
    case MX of
      7 .. 23:
        case MY of
          19:
            AKey := TK_L;
        end;
      57 .. 72:
        case MY of
          19:
            AKey := TK_V;
        end;
    end;
  end;
end;

end.
