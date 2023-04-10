unit TransportTycoon.Scene.Menu.Gen;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneGenMenu = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var AKey: Word); override;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Game,
  TransportTycoon.Map,
  TransportTycoon.Races;

procedure TSceneGenMenu.Render;
begin
  Game.Map.Draw(Self.ScreenWidth, Self.ScreenHeight);

  DrawFrame(10, 9, 60, 12);
  DrawTitle(11, 'WORLD GENERATION');

  DrawButton(12, 13, 'F', 'Map size: ' + MapSizeStr[Game.Map.MapSize]);
  DrawButton(12, 14, 'H', 'Rivers: ' + MapRiversStr[Game.Map.Rivers]);
  DrawButton(12, 15, 'J', 'No. of indust.: ' + MapNoOfIndStr[Game.Map.NoOfInd]);
  DrawButton(12, 16, 'R', 'Race: ' + GameRaceStr[Game.Race]);

  DrawButton(42, 13, 'A', 'No. of towns: ' + MapNoOfTownsStr
    [Game.Map.NoOfTowns]);
  DrawButton(42, 14, 'B', Format('Sea level: %s',
    [MapSeaLevelStr[Game.Map.SeaLevel]]));
  DrawButton(42, 15, 'C', Format('Date: %s', [Game.Calendar.GetDate]));

  AddButton(18, 'Enter', 'Generate');
  AddButton(18, 'Esc', 'Back');
end;

procedure TSceneGenMenu.Update(var AKey: Word);
var
  LIsPrev: Boolean;

  procedure UpdateKey(var AKey: Word);
  begin
    case MX of
      12 .. 36:
        case MY of
          13:
            AKey := TK_F;
          14:
            AKey := TK_H;
          15:
            AKey := TK_J;
          16:
            AKey := TK_R;
        end;
      42 .. 66:
        case MY of
          13:
            AKey := TK_A;
          14:
            AKey := TK_B;
          15:
            AKey := TK_C;
        end;
    end;
  end;

begin
  LIsPrev := (AKey = TK_MOUSE_RIGHT) or terminal_check(TK_SHIFT);
  if (AKey = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
    begin
      case MX of
        26 .. 41:
          AKey := TK_ENTER;
        45 .. 54:
          AKey := TK_ESCAPE;
      end;
    end;
    UpdateKey(AKey);
  end
  else if (AKey = TK_MOUSE_RIGHT) then
    UpdateKey(AKey);

  case AKey of
    TK_ESCAPE:
      Scenes.SetScene(scMainMenu);
    TK_A:
      begin
        if LIsPrev then
          Game.Map.PrevNoOfTowns
        else
          Game.Map.NextNoOfTowns;
        Scenes.Render;
      end;
    TK_B:
      begin
        if LIsPrev then
          Game.Map.PrevSeaLevel
        else
          Game.Map.NextSeaLevel;
        Scenes.Render;
      end;
    TK_C:
      begin
        if LIsPrev then
          Game.Calendar.PrevYear
        else
          Game.Calendar.NextYear;
        Scenes.Render;
      end;
    TK_F:
      begin
        if LIsPrev then
          Game.Map.PrevSize
        else
          Game.Map.NextSize;
        Scenes.Render;
      end;
    TK_H:
      begin
        if LIsPrev then
          Game.Map.PrevRivers
        else
          Game.Map.NextRivers;
        Scenes.Render;
      end;
    TK_R:
      begin
        if LIsPrev then
          Game.PrevRace
        else
          Game.NextRace;
        Scenes.Render;
      end;
    TK_J:
      begin
        if LIsPrev then
          Game.Map.PrevNoOfInd
        else
          Game.Map.NextNoOfInd;
        Scenes.Render;
      end;
    TK_ENTER:
      begin
        Game.Clear;
        Game.Map.Gen;
        Game.IsPause := False;
        Game.SaveSettings;
        Scenes.SetScene(scWorld);
      end;
  end;
end;

end.
