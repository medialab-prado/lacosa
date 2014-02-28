import processing.core.PVector;
import java.util.List;
/**
 * Loading XML Data
 * by Daniel Shiffman.  
 * 
 * This example demonstrates how to use loadJSON()
 * to retrieve data from a JSON file and make objects 
 * from that data.
 *
 * Here is what the JSON looks like (partial):
 *
 {
 "bubbles": [
 {
 "position": {
 "x": 160,
 "y": 103
 },
 "diameter": 43.19838,
 "label": "Happy"
 },
 {
 "position": {
 "x": 372,
 "y": 137
 },
 "diameter": 52.42526,
 "label": "Sad"
 }
 ]
 }
 */

  // An Array of Bubble objects
  Polygon[] polygons;
  // A JSON object
  JSONObject json;

  public void setup() {
    size(1024, 768);
    loadData();
  }

  public void draw() {
    background(255);
    // Display all bubbles
    for (Polygon p : polygons) {
      p.draw(g);
    }
    //
    textAlign(LEFT);
  }

  public void loadData() {
    // Load JSON file
    // Temporary full path until path problem resolved.
    json = loadJSONObject("data.json");

    JSONArray bubbleData = json.getJSONArray("polygons");

    // The size of the array of Bubble objects is determined by the total
    // XML elements named "bubble"
    polygons = new Polygon[bubbleData.size()];

    for (int i = 0; i < bubbleData.size(); i++) {
      // Get each object in the array
      JSONObject polygonData = bubbleData.getJSONObject(i);
      // Get a position object
      JSONArray points = polygonData.getJSONArray("points");
      String name = polygonData.getString("name");
      Polygon polygon = new Polygon(name);
      for (int j = 0; j < points.size(); j++) {
        JSONObject pointData = points.getJSONObject(j);
        polygon.addPoint(new PVector(pointData.getFloat("x"), pointData
            .getFloat("y")));
      }

      // Put object in array
      polygons[i] = polygon;
    }
  }

  public void mousePressed() {
    if (true) {
      return;
    }
    // Create a new JSON bubble object
    JSONObject newBubble = new JSONObject();

    // Create a new JSON position object
    JSONObject position = new JSONObject();
    position.setInt("x", mouseX);
    position.setInt("y", mouseY);

    // Add position to bubble
    newBubble.setJSONObject("position", position);

    // Add diamater and label to bubble
    newBubble.setFloat("diameter", random(40, 80));
    newBubble.setString("label", "New label");

    // Append the new JSON bubble object to the array
    JSONArray bubbleData = json.getJSONArray("bubbles");
    bubbleData.append(newBubble);

    if (bubbleData.size() > 10) {
      bubbleData.remove(0);
    }

    // Save new data
    saveJSONObject(json, "data/data.json");
    loadData();
  }
