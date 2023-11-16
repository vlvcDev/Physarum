<h1> Physarum </h1>
<h2> Slime Mold </h2> 
<p>
<strong>Overview</strong>: The simulation creates a dynamic system that simulates the behavior of slime mold using agent-based modeling.
</p>
<p>
<strong>Agent Properties and Behavior</strong>:

<li><em>Number of Agents</em>: 100,000 agents, each represented by an Agent class instance. </li>
<li><em>Movement</em>: Agents move with a customizable speed (moveSpeed) and can turn based on sensory data and random steering.</li>
<li><em>Sensory Mechanism</em>: Agents sense their environment using offset sensors and react to trails and "oats" (food sources).</li>
</p>
<p>
<strong>Environment</strong>:
<li><em>Trail Map</em>: An off-screen buffer (trailMap) is used to draw trails left by agents.</li>
<li><em>Oats</em>: Food sources (Oats class) randomly placed in the environment, affecting agent behavior.</li>
<li><em>Diffusion and Evaporation</em>: Trail substances diffuse and evaporate over time, with adjustable speeds for both processes.</li>
</p>
<p>
<strong>Simulation Dynamics</strong>:

<li>Agents evaluate their surroundings and make decisions on movement and direction.</li>
<li> Trails left by agents influence the movement of other agents.</li>
<li>Agents can find and consume oats, represented by circles.</li>
</p>
<p>
<strong>User Interaction</strong>:

<li><em>Control Panel</em>: Implemented using the ControlP5 library, allows real-time adjustment of parameters like movement speed, turn speed, evaporation speed, and diffusion speed. </li>
<li><em>Visual Feedback</em>: The simulation provides visual feedback, including a display of the frame rate. </li>
</p>
<p>
<strong>Setup and Execution</strong>:
  
<li> Initialization of agents with random positions and directions.</li>
<li> Continual updating of agent positions and trail map in the draw() loop.</li>
<li> Processing of the trail map to implement diffusion and evaporation effects.</li>
</p>
<p>
<strong>Graphics and Display</strong>:

<li> The trail map is scaled up and displayed on the main canvas.</li>
<li> Agents leave colored trails on the trail map, visually representing their movement and interactions.</li>
</p>

<p>
Below are some pictures of patterns that the slimes have made so far!
</p>
<br>
<img height="300" src="https://github.com/vlvcDev/Physarum/assets/112003152/bd17ee83-18b6-4ac0-a06b-1ceced85878a" />
<img height="300" src="https://github.com/vlvcDev/Physarum/assets/112003152/2fc8a984-81e0-47ef-8b1f-c6e94b3f5066)" />
<img height="300" src="https://github.com/vlvcDev/Physarum/assets/112003152/f51d5360-7fa2-4083-9942-f4d5247c6033" />
<img height="300" src="https://github.com/vlvcDev/Physarum/assets/112003152/e690c2fc-cf53-4b9c-849b-cd4cdb3b2ec5" />
<img height="300" src="https://github.com/vlvcDev/Physarum/assets/112003152/4c2d60b8-65d8-427a-97b5-dbdbddcd82b1" />
