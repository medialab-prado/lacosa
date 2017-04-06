/**
 * 
 * @authors Yago Tooroja, Enrique Esteban, Jorge Cano, Eduardo Moriana
 *
 *  Example using panels
 *  
 */


import org.mlp.cosa.Cell;
import org.mlp.cosa.Cosa;
import org.mlp.cosa.Panel;
import org.mlp.cosa.Panels;
import java.util.*;

Cosa cosa;

CosaRender render;

private int indicePanel;
private int[] indiceCeldas;

Cell lastCell;

boolean clear = false;

public void setup() {
  size(1024, 768);

  frameRate(60);

  cosa = new Cosa();
  File pathP = sketchFile("paneles.txt");
  File pathC = sketchFile("CoordCeldas.txt");
  cosa.init(pathP, pathC);

  render = new CosaRender();

  indicePanel = 0;
  indiceCeldas = new int[cosa.getPanels().size()];
}

public void draw() {

  //background(100);
  fill(0, 5);
  rect(0, 0, width, height);
  cosa.setState(0);

  Panels panels = cosa.getPanels();
  if (frameCount % 2 == 0) {
    cosa.setColor(0);
    panels.get(indicePanel).light = false;
    indicePanel++;
    if (indicePanel >= panels.size()) {
      indicePanel = 0;
    }
    panels.get(indicePanel).light = true;
    panels.get(indicePanel).setColor(color(255, 0, 0));
  }
  render.renderPanels(cosa, g);
}

public void keyPressed() {
  if (key == ' ') {
    clear = !clear;
    if (clear) {
      cosa.setIsDraw(false);
    }
  }
}