unit TransportTycoon.Scene.GenMenu;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneGenMenu = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var Key: word); override;
  end;

implementation

uses
  SysUtils,
  BearLibTerminal,
  TransportTycoon.Game,
  TransportTycoon.Map;

procedure TSceneGenMenu.Render;
begin
  Game.Map.Draw(Self.ScreenWidth, Self.ScreenHeight);

  DrawFrame(10, 9, 60, 11);
  DrawTitle(11, 'WORLD GENERATION');

  DrawButton(12, 13, 'F', 'Map size: ' + MapSizeStr[Game.Map.Size]);
  DrawButton(12, 14, 'H', 'Rivers: ' + MapRiversStr[Game.Map.Rivers]);
  DrawButton(12, 15, 'J', 'No. of indust.: ' + MapNoOfIndStr[Game.Map.NoOfInd]);

  DrawButton(42, 13, 'A', 'No. of towns: ' + MapNoOfTownsStr
    [Game.Map.NoOfTowns]);
  DrawButton(42, 14, 'B', Format('Sea level: %s',
    [MapSeaLevelStr[Game.Map.SeaLevel]]));
  DrawButton(42, 15, 'C', Format('Date: %s', [Game.Calendar.GetDate]));

  AddButton(17, 'Enter', 'Generate');
  AddButton(17, 'Esc', 'Back');
end;

procedure TSceneGenMenu.Update(var Key: word);
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
    begin
      case MX of
        26 .. 41:
          Key := TK_ENTER;
        45 .. 54:
          Key := TK_ESCAPE;
      end;
    end;
    case MX of
      12 .. 36:
        case MY of
          13:
            Key := TK_F;
          14:
            Key := TK_H;
          15:
            Key := TK_J;
        end;
      42 .. 66:
        case MY of
          13:
            Key := TK_A;
          14:
            Key := TK_B;
          15:
            Key := TK_C;
        end;
    end;
  end;
  if (Key = TK_MOUSE_RIGHT) then
  begin
    case MX of
      42 .. 66:
        case MY of
          15:
            begin
              Game.Calendar.PrevYear;
              Scenes.Render;
            end;
        end;
    end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scMainMenu);
    TK_A:
      begin
        Game.Map.NextNoOfTowns;
        Scenes.Render;
      end;
    TK_B:
      begin
        Game.Map.NextSeaLevel;
        Scenes.Render;
      end;
    TK_C:
      begin
        Game.Calendar.NextYear;
        Scenes.Render;
      end;
    TK_F:
      begin
        Game.Map.NextSize;
        Scenes.Render;
      end;
    TK_H:
      begin
        Game.Map.NextRivers;
        Scenes.Render;
      end;
    TK_J:
      begin
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
