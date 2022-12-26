require 'ruby2d'

# Set the window size
set width: 640, height: 480

# Set the background color to white
set background: 'white'

# Initialize an array to store the particles
particles = []

# Initialize a variable to store the state of the left mouse button
mouse_down = false

mouse_down_x, mouse_down_y = 0, 0
mouse_up_x, mouse_up_y = 0, 0

# Define a callback function that stores the mouse down position
on :mouse_down do |event|
  if event.button == :left
    mouse_down_x, mouse_down_y = event.x, event.y
  end
end

# Define a callback function that stores the mouse up position and creates a new particle
on :mouse_up do |event|
  if event.button == :left
    mouse_up_x, mouse_up_y = event.x, event.y
    # Calculate the initial velocity based on the difference between the mouse down and mouse up positions
    vx = (mouse_up_x - mouse_down_x) / 10.0
    vy = (mouse_up_y - mouse_down_y) / 10.0
    # Create a new particle at the mouse up position with the initial velocity and a random mass
    particles << Particle.new(mouse_up_x, mouse_up_y, rand(1..5), vx, vy)
  end
end

# Define a class for the particles
class Particle
  attr_accessor :x, :y, :mass, :vx, :vy, :radius

  def initialize(x, y, mass, vx, vy)
    # Set the initial position, mass, and radius of the particle
    @x, @y, @mass, @radius = x, y, mass, mass**(1/3.0)
    # Set the initial velocity to zero
    @vx, @vy = vx, vy
  end

  def update
    # Update the position of the particle based on its velocity
    @x += @vx
    @y += @vy
  end

  def draw
    # Draw the particle as a circle
    Circle.new(x: @x, y: @y, radius: @radius, color: 'black')
  end

  def apply_force(fx, fy)
    # Apply a force to the particle by updating its velocity
    @vx += fx / @mass
    @vy += fy / @mass
  end
end

update do
  # Clear the screen on each update
  clear

  # Apply a gravitational force between each pair of particles
  particles.combination(2).each do |p1, p2|
    # Calculate the distance between the particles
    dx, dy = p1.x - p2.x, p1.y - p2.y
    distance = Math.sqrt(dx**2 + dy**2)
    # Calculate the gravitational force using Newton's law of universal gravitation
    f = (p1.mass * p2.mass) / distance**2
    # Calculate the x and y components of the force
    fx, fy = f * dx / distance, f * dy / distance
    # Apply the force to each particle
    p1.apply_force(-fx, -fy)
    p2.apply_force(fx, fy)
  end

  # Check for collisions between particles
  particles.combination(2).each do |p1, p2|
    # Calculate the distance between the particles
    dx, dy = p1.x - p2.x, p1.y - p2.y
    distance = Math.sqrt(dx**2 + dy**2)
    # If the distance is less than the sum of the radii, the particles are colliding
    if distance < p1.radius + p2.radius
      # Combine the masses of the particles and update the position and velocity of the new particle
      mass = p1.mass + p2.mass
      x = (p1.x * p1.mass + p2.x * p2.mass) / mass
      y = (p1.y * p1.mass + p2.y * p2.mass) / mass
      vx = (p1.vx * p1.mass + p2.vx * p2.mass) / mass
      vy = (p1.vy * p1.mass + p2.vy * p2.mass) / mass
      # Replace the two colliding particles with the new combined particle
      particles.delete(p1)
      particles.delete(p2)
      particles << Particle.new(x, y, mass, vx, vy)
    end
  end

  # Update and draw each particle
  particles.each do |particle|
    particle.update
    particle.draw
  end
end

show