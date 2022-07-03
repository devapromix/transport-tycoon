﻿unit TransportTycoon.Scene.Company;

interface

uses
  TransportTycoon.Scenes;

type
  TSceneCompany = class(TScene)
  private

  public
    procedure Render; override;
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  BearLibTerminal,
  SysUtils,
  TransportTycoon.Game,
  TransportTycoon.Industries;

procedure TSceneCompany.Render;
begin
  DrawMap(Self.Width, Self.Height - 1);

  DrawFrame(20, 8, 40, 13);
  DrawTitle(10, Game.Company.Name);
  DrawText(22, 12, 'Inavgurated: ' + IntToStr(Game.Company.Inavgurated));

  if TTownIndustry(Game.Map.Industry[Game.Company.TownID]).HQ.HasBuilding then
    DrawText(22, 16, 'Company headquarters in ' + Game.Map.Industry
      [Game.Company.TownID].Name);

  AddButton(18, 'Esc', 'Close');

  DrawBar;
end;

procedure TSceneCompany.Update(var Key: Word);
begin
  if (Key = TK_MOUSE_LEFT) then
  begin
    if (GetButtonsY = MY) then
    begin
      if (MX >= 35) and (MX <= 45) then
        Key := TK_ESCAPE;
    end;
  end;
  case Key of
    TK_ESCAPE:
      Scenes.Back;
  end;
end;

end.
