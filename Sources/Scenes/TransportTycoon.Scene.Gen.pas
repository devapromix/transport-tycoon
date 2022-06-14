unit TransportTycoon.Scene.Gen;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneGen = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var Key: word); override;
  end;

implementation

uses
  BearLibTerminal,
  SysUtils,
  TransportTycoon.Game,
  TransportTycoon.Map;

procedure TSceneGen.Render;
begin
  Game.Map.Draw(Self.Width, Self.Height);

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

procedure TSceneGen.Update(var Key: word);
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
    begin
      if (MX >= 26) and (MX <= 41) then
        Key := TK_ENTER;
      if (MX >= 45) and (MX <= 54) then
        Key := TK_ESCAPE;
    end;
    if (MX >= 12) and (MX <= 36) then
      case MY of
        13:
          Key := TK_F;
        14:
          Key := TK_H;
        15:
          Key := TK_J;
      end;
    if (MX >= 42) and (MX <= 66) then
      case MY of
        13:
          Key := TK_A;
        14:
          Key := TK_B;
        15:
          Key := TK_C;
      end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.SetScene(scMainMenu);
    TK_A:
      begin
        Inc(Game.Map.NoOfTowns);
        if (Game.Map.NoOfTowns > 4) then
          Game.Map.NoOfTowns := 1;
      end;
    TK_B:
      begin
        Inc(Game.Map.SeaLevel);
        if (Game.Map.SeaLevel > msHigh) then
          Game.Map.SeaLevel := msVeryLow;
        Scenes.Render;
      end;
    TK_C:
      begin
        Game.Calendar.NextYear;
        Scenes.Render;
      end;
    TK_F:
      begin
        Inc(Game.Map.Size);
        if (Game.Map.Size > msLarge) then
          Game.Map.Size := msTiny;
        Scenes.Render;
      end;
    TK_H:
      begin
        Inc(Game.Map.Rivers);
        if (Game.Map.Rivers > mrMany) then
          Game.Map.Rivers := mrNone;
        Scenes.Render;
      end;
    TK_J:
      begin
        Inc(Game.Map.NoOfInd);
        if (Game.Map.NoOfInd > niHigh) then
          Game.Map.NoOfInd := niVeryLow;
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
