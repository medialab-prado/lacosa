/**
 * 
 * @authors Yago Tooroja, Enrique Esteban, Jorge Cano, Eduardo Moriana
 *
 *  Example using cells
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

  // background(100);
  if (frameCount % 4 == 0) {
    fill(0, 14);
    rect(0, 0, width, height);
  }
  cosa.setState(255);

  Panels panels = cosa.getPanels();
  if (frameCount % 1 == 0) {
    // ponemos a negro todo el panel, esto actualiza el color de la
    // celda a negro porque se transmite en cascada
    // if (clear)
    // panels.setColor(0);
    // apagamos el panel

    if (indicePanel == 0 && indiceCeldas[indicePanel] == 0) {
      // cosa.setIsDraw(false);
    }

    List<Cell> cells = panels.get(indicePanel).getCells();
    // println("indice panels " + indicePanel);
    // actaulizamos el color de la celda que le toca ahora
    if (lastCell != null && clear) {
      lastCell.isDraw = false;
    }

    // pasamos a la siguiente celda
    indiceCeldas[indicePanel] += 1;

    // cambiamos de panel cuando llegamos al final
    if (indiceCeldas[indicePanel] >= cells.size()) {
      // ponemos a cero el índice para la siguiente pasada
      indiceCeldas[indicePanel] = 0;
      // pasamos al siguinte
      indicePanel++;
      if (indicePanel >= panels.size() - 1) {
        indicePanel = 0;
      }
    }

    if (!cells.isEmpty()) {
      lastCell = cells.get(indiceCeldas[indicePanel]);

      int valueRandom = indiceCeldas[indicePanel] % 4;
      if (valueRandom == 0)
        lastCell.setColor(color(255, random(100, 255), 0));
      else if (valueRandom == 1)
        lastCell.setColor(color(0, random(100, 255), 255));
      else if (valueRandom == 2)
        lastCell.setColor(color(255, random(100, 255), 255));
      else if (valueRandom == 3)
        lastCell.setColor(color(random(100, 255), 255, 0));
      else
        lastCell.setColor(color(0, random(100, 255), 255));

      lastCell.isDraw = true;
    }
  }
  render.renderAllCells(cosa, g);

  for (Panel p : cosa.getPanels()) {
    if (p.getCells() != null)
      for (Cell cell : p.getCells()) {
        int c = cell.getColor();
        float r = red(c);
        float g = green(c);
        float b = blue(c);

        r++;
        r = r % 255;
        g++;
        g = g % 255;
        b++;
        b = b % 255;
        int cc = color(r, g, b);
        cell.setColor(cc);
      }
  }
}

public void keyPressed() {
  if (key == ' ') {
    clear = !clear;
    if (clear) {
      cosa.setIsDraw(false);
    }
  }
}