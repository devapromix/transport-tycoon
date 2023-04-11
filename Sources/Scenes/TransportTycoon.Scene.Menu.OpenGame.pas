unit TransportTycoon.Scene.Menu.OpenGame;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Game;

type
  TOpenMenuSubScene = (oscDefault);

type

  { TSceneOpenGameMenu }

  TSceneOpenGameMenu = class(TScene)
  private
    FSubScene: TOpenMenuSubScene;
    FCurrentSlot: TSlot;
    procedure Load(const ASlot: TSlot);
  public
    constructor Create;
    procedure Render; override;
    procedure Update(var AKey: Word); override;
  end;

implementation

uses
  SysUtils, dialogs,
  BearLibTerminal;

{ TSceneOpenGameMenu }

constructor TSceneOpenGameMenu.Create;
begin
  FSubScene := oscDefault;
end;

procedure TSceneOpenGameMenu.Load(const ASlot: TSlot);
begin
  FSubScene := oscDefault;
  ShowMessage(IntToStr(ASlot));
end;

procedure TSceneOpenGameMenu.Render;
var
  LSlot: TSlot;
begin
  Game.Map.Draw(Self.ScreenWidth, Self.ScreenHeight);

  DrawFrame(10, 6, 60, 18);

  DrawTitle(8, 'OPEN SAVED GAME');
  for LSlot := Low(TSlot) to High(TSlot) do
    DrawButton(12, LSlot + 10, (Game.GetSlotStr(LSlot) <> Game.EmptySlotStr),
      Chr(Ord('A') + LSlot), Game.GetSlotStr(LSlot));

  case FSubScene of
    oscDefault:
      AddButton(21, 'Esc', 'Close');
  end;
end;

procedure TSceneOpenGameMenu.Update(var AKey: Word);
var
  LSlot: TSlot;
begin
  if (AKey = TK_MOUSE_LEFT) then
  begin
    case FSubScene of
      oscDefault:
        begin
          case MX of
            12 .. 66:
              case MY of
                10 .. 19:
                  AKey := TK_A + (MY - 10);
              end;
          end;
          if (GetButtonsY = MY) then
          begin
            case MX of
              35 .. 45:
                AKey := TK_ESCAPE;
            end;
          end;
        end;
    end;
    case FSubScene of
      oscDefault:
        case AKey of
          TK_ESCAPE:
            Scenes.SetScene(scMainMenu);
          TK_A .. TK_J:
            begin
              LSlot := AKey - TK_A;
              Game.Load(LSlot);
            end;
        end;

    end;
  end;
end;

end.
