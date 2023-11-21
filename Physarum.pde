import controlP5.*;

int numAgents = 100000; // The number of agents
float moveSpeed = 1.0; // The speed of the agents
Agent[] agents; // Array to hold the agents
Oat[] oats;
PGraphics trailMap; // Off-screen buffer to draw the trails
int scaleFactor = 1; // Each pixel of the trailMap will be drawn as an 8x8 block on the screen

float sensorAngleOffset = PI / 4;
float sensorOffsetDist = 25;
int sensorSize = 1;
float turnSpeed = 4;

float diffuseSpeed = 0.8; // Adjust as needed for diffusion speed
float evaporationSpeed = 0.5; // Adjust as needed for evaporation speed
float deltaTime = 1.0 / frameRate;

int numOats = 10;
float minOatRadius = 40 / scaleFactor;
float maxOatRadius = 100 / scaleFactor;

ControlP5 cp5;


class Oat {
  PVector position;
  float radius;
  
  Oat(float x, float y, float r) {
    position = new PVector(x,y);
    radius = r;
  }
  
  void display() {
    ellipse(position.x, position.y, radius*2, radius*2);
  }
}

// Define the Agent class
class Agent {
  PVector position;
  float angle;
  boolean isOnOat = false;

  Agent(float x, float y, float a) {
    position = new PVector(x, y);
    angle = a;
  }

  void update() {
    // Calculate the new position based on direction and speed
    // Sensory data
    float weightForward = sense(this, 0);
    float weightLeft = sense(this, sensorAngleOffset);
    float weightRight = sense(this, -sensorAngleOffset);

    // Random steering strength
    float randomSteerStrength = random(0, 1); // 5% chance to apply randomness

    // Continue in same direction if forward weight is greatest
    if (weightForward >= weightLeft && weightForward >= weightRight) {
      // Keep angle the same
    }
    // Turn randomly if forward weight is not the greatest
    else if (weightForward < weightLeft && weightForward < weightRight) {
      angle += (randomSteerStrength - 0.5) * 2 * turnSpeed * deltaTime;
    }
    // Turn right
    else if (weightRight > weightLeft) {
      angle -= randomSteerStrength * turnSpeed * deltaTime;
    }
    // Turn left
    else if (weightLeft > weightRight) {
      angle += randomSteerStrength * turnSpeed * deltaTime;
    }

    // Move agent forward in the new direction
    PVector direction = new PVector(cos(angle), sin(angle));
    position.add(PVector.mult(direction, moveSpeed));
    // Check for horizontal boundaries, comment the below code to wrap around edges
    if (position.x < 0) {
      position.x = 0; // Place the agent back within the boundary
      angle = PI - angle + random(-PI/4, PI/4); // Reflect the angle and add some randomness
    }
    if (position.x >= trailMap.width) {
      position.x = trailMap.width - 1; // Subtract 1 to keep within bounds
      angle = PI - angle + random(-PI/4, PI/4); // Reflect the angle and add some randomness
    }
    // Check for vertical boundaries
    if (position.y < 0) {
      position.y = 0; // Place the agent back within the boundary
      angle = -angle + random(-PI/4, PI/4); // Reflect the angle and add some randomness
    }
    if (position.y >= trailMap.height) {
      position.y = trailMap.height - 1; // Subtract 1 to keep within bounds
      angle = -angle + random(-PI/4, PI/4); // Reflect the angle and add some randomness
    }
    

    if (!isOnOat) {
      // Draw the trail by setting the pixel color
      int index = (int)position.y * trailMap.width + (int)position.x;
      if (index >= 0 && index < trailMap.pixels.length) { // Ensure the index is within the array bounds
        trailMap.pixels[index] = color(80, 255, 60);
    }
    } else {
      // Draw the trail by setting the pixel color
      int index = (int)position.y * trailMap.width + (int)position.x;
      if (index >= 0 && index < trailMap.pixels.length) { // Ensure the index is within the array bounds
        trailMap.pixels[index] = color(120, 255, 180);
    }
    }
    
  }
}

float sense(Agent agent, float sensorAngleOffset) {
  float sensorAngle = agent.angle + sensorAngleOffset;
  PVector sensorDir = new PVector(cos(sensorAngle), sin(sensorAngle));
  PVector sensorCentre = PVector.add(agent.position, sensorDir.mult(sensorOffsetDist));
  float sum = 0;

  // Loop over a square grid around the sensor center
  for (int offsetX = -sensorSize; offsetX <= sensorSize; offsetX++) {
    for (int offsetY = -sensorSize; offsetY <= sensorSize; offsetY++) {
      int posx = (int) sensorCentre.x + offsetX;
      int posy = (int) sensorCentre.y + offsetY;
      
      // Check if the position is within the bounds of the trailMap
      if (posx >= 0 && posx < trailMap.width && posy >= 0 && posy < trailMap.height) {
        sum += brightness(trailMap.get(posx, posy));
      }
    }
  }

  agent.isOnOat = false;
  for (Oat oat : oats) {
    // Calculate the distance from the sensor center to the Oat
    float distance = PVector.dist(sensorCentre, oat.position);

    // If the Oat is within the sensor range, add a positive value to sum
    // You can adjust the 'oatAttractionStrength' and 'oatAttractionRange' to tweak the behavior
    float oatAttractionStrength = 2000; // Determines how strongly agents are attracted to Oats
    float oatAttractionRange = sensorOffsetDist + oat.radius; // The effective range in which an Oat influences the sensor

    if (distance < oatAttractionRange) {
      // You could also scale the added value by the distance to the Oat, if desired
      sum += oatAttractionStrength * (oatAttractionRange - distance) / oatAttractionRange;
    }
    if (distance < oat.radius) { // If within the oat
      agent.isOnOat = true;
    }
  }
  return sum;
}


void processTrailMap() {
  trailMap.loadPixels();
  color[] newPixels = new color[trailMap.pixels.length];

  // Iterate through each pixel
  for (int y = 1; y < trailMap.height - 1; y++) {
    for (int x = 1; x < trailMap.width - 1; x++) {
      int sumR = 0, sumG = 0, sumB = 0;

      // Iterate through each neighbor of the current pixel
      for (int offsetY = -1; offsetY <= 1; offsetY++) {
        for (int offsetX = -1; offsetX <= 1; offsetX++) {
          int neighborIndex = (y + offsetY) * trailMap.width + (x + offsetX);
          color neighborColor = trailMap.pixels[neighborIndex];
          sumR += red(neighborColor);
          sumG += green(neighborColor);
          sumB += blue(neighborColor);
        }
      }

      // Calculate the average color of the current pixel and its neighbors
      int count = 9; // Total number of pixels considered (3x3 grid)
      float avgR = sumR / count;
      float avgG = sumG / count;
      float avgB = sumB / count;

      // Blend the original pixel color with the average color based on diffuseSpeed
      int index = y * trailMap.width + x;
      color originalColor = trailMap.pixels[index];
      float lerpFactor = diffuseSpeed * deltaTime;
      float newR = lerp(red(originalColor), avgR, lerpFactor);
      float newG = lerp(green(originalColor), avgG, lerpFactor);
      float newB = lerp(blue(originalColor), avgB, lerpFactor);

      // Apply evaporation by reducing the brightness
      float newBrightness = brightness(color(newR, newG, newB)) * (1 - evaporationSpeed * deltaTime);
      newPixels[index] = color(newR, newG, newB, newBrightness);
    }
  }

  // Copy the new averaged colors back into the original pixels array
  arrayCopy(newPixels, trailMap.pixels);
  trailMap.updatePixels();
}


void setup() {
  noSmooth(); // Turn off smoothing to keep the pixelated look
  size(960, 960, P2D); // Define the size of the canvas
  trailMap = createGraphics(width / scaleFactor, height / scaleFactor, P2D); // Create a smaller PGraphics object

  cp5 = new ControlP5(this);
  int SliderYPos = 10;
  cp5.addSlider("moveSpeed")
     .setPosition(10, SliderYPos)
     .setWidth(300)
     .setRange(0, 20) // the range of the slider
     .setValue(moveSpeed) // default value to display
     .setLabel("Move Speed");  
  SliderYPos += 10;
  cp5.addSlider("turnSpeed")
     .setPosition(10, SliderYPos)
     .setWidth(300)
     .setRange(0, 20) // the range of the slider
     .setValue(turnSpeed) // default value to display
     .setLabel("Turn Speed");
   SliderYPos += 10;  
   cp5.addSlider("evaporationSpeed")
      .setPosition(10,SliderYPos)
      .setWidth(300)
      .setRange(0, 50)
      .setValue(evaporationSpeed)
      .setLabel("Evaporation Speed");
   SliderYPos += 10;   
   cp5.addSlider("diffuseSpeed")
      .setPosition(10,SliderYPos)
      .setWidth(300)
      .setRange(0, 20)
      .setValue(diffuseSpeed)
      .setLabel("Diffuse Speed");

  // Initialize the agents with random positions and angles
  agents = new Agent[numAgents];
  //float radius = min(trailMap.width, trailMap.height) * 0.3; // Radius of the circle on which agents will spawn
  //PVector center = new PVector(trailMap.width / 2, trailMap.height / 2); // Center of the canvas
  //for (int i = 0; i < numAgents; i++) {
  //  // Angle around the circle
  //  float theta = map(i, 0, numAgents, 0, TWO_PI);
    
  //  // Position on the circumference
  //  float x = center.x + radius * cos(theta);
  //  float y = center.y + radius * sin(theta);
    
  //  // Angle pointing towards the center of the circle
  //  float angle = atan2(center.y - y, center.x - x);

  //  agents[i] = new Agent(x, y, angle);
  //}
  
  float maxRadius = min(trailMap.width, trailMap.height) * 0.4; // Maximum radius of the circle
  PVector center = new PVector(trailMap.width / 2, trailMap.height / 2); // Center of the canvas

  for (int i = 0; i < numAgents; i++) {
    // Random angle and radius for the position within the circle
    float theta = random(TWO_PI);
    float radius = sqrt(random(1)) * maxRadius; // Square root for uniform distribution
    
    // Position within the circle
    float x = center.x + radius * cos(theta);
    float y = center.y + radius * sin(theta);
    
    // Angle pointing towards the center of the circle
    float angle = atan2(center.y - y, center.x - x);

    agents[i] = new Agent(x, y, angle);
  }
  
  oats = new Oat[numOats];
  for (int i = 0; i < oats.length; i++) {
    // Generate a random position on the screen
    float x = random(width);
    float y = random(height);
    // Generate a random size for the Oat
    float radius = random(minOatRadius, maxOatRadius);
    // Create a new Oat and store it in the array
    oats[i] = new Oat(x, y, radius);
  }
  
}

void draw() {
  deltaTime = 1.0 / frameRate;
  background(0);

  trailMap.beginDraw();
  processTrailMap();
  
  trailMap.loadPixels();
  for (int i = 0; i < agents.length; i++) {
    agents[i].update();
  }
  for (int i = 0; i < oats.length; i++) {
    oats[i].display();
  }
  trailMap.updatePixels();
  

  trailMap.endDraw();

  // Draw the smaller pixel map to the screen, scaled up
  image(trailMap, 0, 0, width, height); // Scale up the image to the size of the window

  // Display the frame rate on top of the canvas
  fill(255); // Set fill color for the text to white
  textSize(16); // Set text size
  text("FPS: " + nf(frameRate, 0, 2), 10, height - 10); // Display the frame rate rounded to 2 decimal places
}

// This function is called when the slider value changes
public void controlEvent(ControlEvent event) {
  if (event.isFrom(cp5.getController("moveSpeed"))) {
    moveSpeed = event.getController().getValue();
  } 
  if (event.isFrom(cp5.getController("turnSpeed"))) {
    turnSpeed = event.getController().getValue();
  }
  if (event.isFrom(cp5.getController("evaporationSpeed"))) {
    evaporationSpeed = event.getController().getValue();
  }
  if (event.isFrom(cp5.getController("diffuseSpeed"))) {
    diffuseSpeed = event.getController().getValue();
  }
}
