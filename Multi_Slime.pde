import controlP5.*;

int numAgents = 5000; // The number of agents
float moveSpeed = 1.0; // The speed of the agents
Agent[] agents; // Array to hold the agents
PGraphics trailMap; // Off-screen buffer to draw the trails
int scaleFactor = 2; // Each pixel of the trailMap will be drawn as an 8x8 block on the screen

float sensorAngleOffset = PI / 4;
float sensorOffsetDist = 15;
int sensorSize = 4;
float turnSpeed = 6;

float diffuseSpeed = 8.0; // Adjust as needed for diffusion speed
float evaporationSpeed = 0.5; // Adjust as needed for evaporation speed
float deltaTime = 1.0 / frameRate;

int numSpecies = 2;

ControlP5 cp5;

// Define the Agent class
class Agent {
  PVector position;
  float angle;
  int[] speciesMask = new int[numSpecies];

  Agent(float x, float y, float a, int[] mask) {
    position = new PVector(x, y);
    angle = a;
    speciesMask = mask;
  }

  void update() {
    // Calculate the new position based on direction and speed
    // Sensory data - you will need to define the sense function based on your needs
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
    // Check for horizontal boundaries
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
    
    // Wrap around the edges
    //if (position.x < 0) position.x = width -1;
    //if (position.x >= width) position.x = 1;
    //if (position.y < 0) position.y = height -1;
    //if (position.y >= height) position.y = 1;

    // Draw the trail by setting the pixel color
    int index = (int)position.y * trailMap.width + (int)position.x;
    if (index >= 0 && index < trailMap.pixels.length) { // Ensure the index is within the array bounds
      trailMap.pixels[index] = color(255, 255, 255);
    }
  }
  
  void speciesTrail(int weight) {
    int index = (int) position.y * trailMap.width + (int) position.x;
    if (index >= 0 && index < trailMap.pixels.length) {
      float redValue = 0;
      float greenValue = 0;
      float blueValue = 0;
  
      // Assuming numSpecies is 4, we will map each species to a color channel
      if (numSpecies >= 1) redValue = speciesMask[0] * (weight / 255.0);
      if (numSpecies >= 2) greenValue = speciesMask[1] * (weight / 255.0);
      if (numSpecies >= 3) blueValue = speciesMask[2] * (weight / 255.0);
      
      // If you have a fourth species, you can decide how to represent it. 
      // For simplicity, let's add its influence to the red channel as well.
      if (numSpecies >= 4) redValue += speciesMask[3] * (weight / 255.0);
  
      // Ensure we don't exceed the maximum color value of 255
      redValue = min(redValue, 1) * 255;
      greenValue = min(greenValue, 1) * 255;
      blueValue = min(blueValue, 1) * 255;
  
      // Set the color of the pixel based on the species traits
      trailMap.pixels[index] = color(
        redValue * deltaTime * 255,   // Red channel
        greenValue * deltaTime * 255, // Green channel
        blueValue * deltaTime * 255,  // Blue channel
        255                     // Alpha channel, fully opaque
      );
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
        color trailColor = trailMap.get(posx, posy);
        // Calculate how the sensed color compares to the agent's species mask
        for (int i = 0; i < agent.speciesMask.length; i++) {
          int maskValue = agent.speciesMask[i];
          float trailValue = (i == 0) ? red(trailColor) : (i == 1) ? green(trailColor) : (i == 2) ? blue(trailColor) : alpha(trailColor);
          // If maskValue is 1 for the species, it's attracted to the same color. If it's 0, it's repelled.
          sum += maskValue == 1 ? trailValue : -trailValue;
        }
      }
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
  
  cp5.addSlider("turnSpeed")
     .setPosition(10, 10)
     .setWidth(300)
     .setRange(0, 20) // the range of the slider
     .setValue(turnSpeed) // default value to display
     .setLabel("Turn Speed");
     
   cp5.addSlider("evaporationSpeed")
      .setPosition(10,20)
      .setWidth(300)
      .setRange(0, 20)
      .setValue(evaporationSpeed)
      .setLabel("Evaporation Speed");
      
   cp5.addSlider("diffuseSpeed")
      .setPosition(10,30)
      .setWidth(300)
      .setRange(0, 20)
      .setValue(diffuseSpeed)
      .setLabel("Diffuse Speed");

  // Initialize the agents with random positions and angles
  agents = new Agent[numAgents];
  
  //float radius = min(width, height) * 0.3; // Radius of the circle on which agents will spawn
  //PVector center = new PVector(width / 2, height / 2); // Center of the canvas
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
    // Random angle for the position within the circle
    float theta = random(TWO_PI);
    // Random radius for uniform distribution within the circle
    float radius = sqrt(random(1)) * maxRadius; 
    
    // Position within the circle
    float x = center.x + radius * cos(theta);
    float y = center.y + radius * sin(theta);
    
    // Angle pointing towards the center of the circle
    float angle = atan2(center.y - y, center.x - x);
    
    // Randomly assign a species mask to each agent
    int[] mask = new int[numSpecies];
    mask[int(random(numSpecies))] = 1; // Only one species trait active per agent
    agents[i] = new Agent(x, y, angle, mask);
  }
}

void draw() {
  deltaTime = 1.0 / frameRate;
  background(0);

  trailMap.beginDraw();
  processTrailMap();
  trailMap.loadPixels();
  for (Agent agent : agents) {
    agent.update(); // Update the agent's position
    agent.speciesTrail(255); // Draw the agent's trail
  }
  trailMap.updatePixels();
  trailMap.endDraw();

  // Draw the trailMap buffer to the main window, scaling it up to the window size
  image(trailMap, 0, 0, width, height);

  // Display frame rate
  fill(255);
  textSize(16);
  text("FPS: " + nf(frameRate, 0, 2), 10, height - 10);
}


// This function is called when the slider value changes
public void controlEvent(ControlEvent event) {
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
