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
  Math,
  SysUtils,
  TransportTycoon.Game,
  TransportTycoon.Map;

procedure TSceneGen.Render;
begin
  Game.Map.Draw(Self.Width, Self.Height);

  DrawFrame(10, 7, 60, 15);
  DrawTitle('WORLD GENERATION');

  DrawText(12, 11, 'Map size: ' + MapSizeStr[Game.Map.Size]);
  DrawButton(42, 11, 'A', 'No. of towns: ' + MapNoOfTownsStr
    [Game.Map.NoOfTowns]);

  // DrawText(12, 10, "[[C]] Rivers: " + gen_rivers_str());
  // DrawText(42, 10, "[[D]] No. of ind.: " + gen_indust_str());

  // DrawText(12, 11, "[[E]] Sea level: " + gen_sea_level_str());
  DrawText(42, 13, Format('Date: %s %d, %d', [MonStr[Game.Month], Game.Day,
    Game.Year]));

  AddButton(19, 'Enter', 'Generate');
  AddButton(19, 'Esc', 'Back');
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
    if (MX >= 42) and (MX <= 66) then
      case MY of
        11:
          Key := TK_A;
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
    TK_ENTER:
      begin
        Game.Clear;
        Game.Map.Gen;
        Game.IsPause := False;
        Scenes.SetScene(scWorld);
      end;
  end;
end;

end.
