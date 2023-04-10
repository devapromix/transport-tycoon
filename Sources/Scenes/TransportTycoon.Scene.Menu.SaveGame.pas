unit TransportTycoon.Scene.Menu.SaveGame;

interface

uses
  TransportTycoon.Scenes,
  TransportTycoon.Game;

type
  TSaveMenuSubScene = (sscDefault, sscPrompt, sscSaved);

type

  { TSceneSaveGameMenu }

  TSceneSaveGameMenu = class(TScene)
  private
    FSubScene: TSaveMenuSubScene;
    FCurrentSlot: TSlot;
    procedure Save;
  public
    constructor Create;
    procedure Render; override;
    procedure Update(var AKey: Word); override;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal;

{ TSceneSaveGameMenu }

constructor TSceneSaveGameMenu.Create;
begin
  FSubScene := sscDefault;
end;

procedure TSceneSaveGameMenu.Render;
var
  LSlot: TSlot;
begin
  DrawMap(Self.ScreenWidth, Self.ScreenHeight - 1);

  DrawFrame(10, 6, 60, 18);

  DrawTitle(8, 'SAVE CURRENT GAME');
  for LSlot := Low(TSlot) to High(TSlot) do
    DrawButton(12, LSlot + 10, True, Chr(Ord('A') + LSlot),
      Game.GetSlotStr(LSlot));

  case FSubScene of
    sscDefault:
      begin
        AddButton(21, 'Esc', 'Close');
      end;
    sscPrompt:
      begin
        DrawFrame(20, 10, 40, 9);
        DrawTitle(12, 'SAVE CURRENT GAME');
        DrawText(14, 'Replace saved game?');
        AddButton(16, 'Enter', 'Replace');
        AddButton(16, 'Esc', 'Cancel');
        DrawText(35, 21, '[[ESC]] CLOSE', False);
      end;
    sscSaved:
      begin
        DrawFrame(25, 10, 30, 9);
        DrawTitle(12, 'SAVE CURRENT GAME');
        DrawText(14, 'Game saved!');
        AddButton(16, 'Enter', 'Close');
        DrawText(35, 21, '[[ESC]] CLOSE', False);
      end;
  end;
  DrawGameBar;
end;

procedure TSceneSaveGameMenu.Save;
begin
  FSubScene := sscSaved;
  Game.Save(FCurrentSlot);
end;

procedure TSceneSaveGameMenu.Update(var AKey: Word);
begin
  if (AKey = TK_MOUSE_LEFT) then
  begin
    case FSubScene of
      sscDefault:
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
      sscPrompt:
        if (GetButtonsY = MY) then
        begin
          case MX of
            25 .. 39:
              AKey := TK_ENTER;
            43 .. 54:
              AKey := TK_ESCAPE;
          end;
        end;
      sscSaved:
        if (GetButtonsY = MY) then
        begin
          case MX of
            34 .. 46:
              AKey := TK_ENTER;
          end;
        end;
    end;
  end;
  case FSubScene of
    sscDefault:
      case AKey of
        TK_ESCAPE:
          begin
            Game.IsPause := False;
            Scenes.SetScene(scWorld);
          end;
        TK_A .. TK_J:
          begin
            FCurrentSlot := AKey - TK_A;
            if (FCurrentSlot >= 0) and (FCurrentSlot <= 9) then
              if Game.IsSlotFileExists(FCurrentSlot) then
                FSubScene := sscPrompt
              else
                Save;
          end;
      end;
    sscPrompt:
      case AKey of
        TK_ESCAPE:
          FSubScene := sscDefault;
        TK_ENTER:
          Save;
      end;
    sscSaved:
      case AKey of
        TK_ENTER:
          begin
            Game.IsPause := False;
            FSubScene := sscDefault;
            Scenes.SetScene(scWorld);
          end;
      end;
  end;
end;

end.
