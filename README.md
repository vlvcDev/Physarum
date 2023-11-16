<h1> Physarum </h1>
<strong><h3> Slime Mold </h3></strong> 
<p>
<strong>Overview</strong>: The simulation creates a dynamic system that simulates the behavior of slime mold using agent-based modeling.
</p>
<p>
<strong>Agent Properties and Behavior</strong>:

<li> Number of Agents: 100,000 agents, each represented by an Agent class instance. </li>
<li> Movement: Agents move with a customizable speed (moveSpeed) and can turn based on sensory data and random steering.</li>
<li> Sensory Mechanism: Agents sense their environment using offset sensors and react to trails and "oats" (food sources).</li>
</p>
<p>
<strong>Environment</strong>:
<li> Trail Map: An off-screen buffer (trailMap) is used to draw trails left by agents.</li>
<li> Oats: Food sources (Oats class) randomly placed in the environment, affecting agent behavior.</li>
<li> Diffusion and Evaporation: Trail substances diffuse and evaporate over time, with adjustable speeds for both processes.</li>
</p>
<p>
<strong>Simulation Dynamics</strong>:

<li> Agents evaluate their surroundings and make decisions on movement and direction.</li>
<li> Trails left by agents influence the movement of other agents.</li>
<li>Agents can find and consume oats, represented by circles.</li>
</p>
<p>
<strong>User Interaction</strong>:

<li> Control Panel: Implemented using the ControlP5 library, allows real-time adjustment of parameters like movement speed, turn speed, evaporation speed, and diffusion speed. </li>
<li> Visual Feedback: The simulation provides visual feedback, including a display of the frame rate. </li>
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
