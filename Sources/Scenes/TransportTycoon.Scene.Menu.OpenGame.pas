unit TransportTycoon.Scene.Menu.OpenGame;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Game;

type
  TOpenMenuSubScene = (oscDefault, oscPrompt);

type

  { TSceneOpenGameMenu }

  TSceneOpenGameMenu = class(TScene)
  private
    FSubScene: TOpenMenuSubScene;
    FCurrentSlot: TSlot;
    procedure Load;
  public
    constructor Create;
    procedure Render; override;
    procedure Update(var AKey: Word); override;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal;

{ TSceneOpenGameMenu }

constructor TSceneOpenGameMenu.Create;
begin
  FSubScene := oscDefault;
end;

procedure TSceneOpenGameMenu.Load;
begin
  if Game.IsGame then
  begin
    FSubScene := oscPrompt;
  end
  else
  begin
    FSubScene := oscDefault;
    Game.Load(FCurrentSlot);
  end;
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
    oscPrompt:
      begin
        DrawFrame(20, 10, 40, 9);
        DrawTitle(12, 'OPEN SAVED GAME');
        DrawText(14, 'Continue?');
        AddButton(16, 'Enter', 'Open');
        AddButton(16, 'Esc', 'Cancel');
        DrawText(35, 21, '[[ESC]] CLOSE', False);
      end;
  end;
end;

procedure TSceneOpenGameMenu.Update(var AKey: Word);
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
      oscPrompt:
        if (GetButtonsY = MY) then
        begin
          case MX of
            27 .. 38:
              AKey := TK_ENTER;
            42 .. 53:
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
            FCurrentSlot := AKey - TK_A;
            if (FCurrentSlot >= 0) and (FCurrentSlot <= 9) then
              if Game.IsSlotFileExists(FCurrentSlot) then
                Load;
          end;
      end;
    oscPrompt:
      case AKey of
        TK_ESCAPE:
          FSubScene := oscDefault;
        TK_ENTER:
          begin
            Game.IsGame := False;
            Load;
          end;
      end;
  end;
end;

end.
