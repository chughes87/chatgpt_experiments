require 'ruby2d'

# Set the window size
set width: 1000, height: 800

# Set the background color to white
set background: 'white'

# Initialize an array to store the particles
particles = []

mouse_down_x = 0
mouse_down_y = 0
mouse_up_x = 0
mouse_up_y = 0
mouse_down_timestamp = 0
mouse_up_timestamp = 0
PAN_X = 0
PAN_Y = 0
ZOOM = 1
command = false


# Define a callback function that stores the mouse down position and resets the elapsed time
on :mouse_down do |event|
  if event.button == :left
    mouse_down_x = event.x
    mouse_down_y = event.y
    mouse_down_timestamp = Time.now.to_f
  end
end

# Define a callback function that stores the mouse up position and creates a new particle
on :mouse_up do |event|
  if event.button == :left
    mouse_up_timestamp = Time.now.to_f
    mouse_up_x = event.x
    mouse_up_y  = event.y
    # Use the elapsed time and distance to calculate the initial size of the particle
    size = (mouse_up_timestamp - mouse_down_timestamp) * 500
    # Create a new particle at the mouse up position with the initial size and a random mass
    # particles << Particle.new(mouse_up_x, mouse_up_y, size, rand(1..5), size)
    vx = (mouse_up_x - mouse_down_x) / 10.0
    vy = (mouse_up_y - mouse_down_y) / 10.0
    # Create a new particle at the mouse up position with the initial velocity and a random mass
    particles << Particle.new(mouse_up_x + PAN_X * ZOOM, mouse_up_y + PAN_Y * ZOOM, size, vx, vy)
  end
end

on :key_down do |event|
  particles.clear if event.key == 'escape'
  command = true if event.key == 'left command'
end

on :key_up do |event|
  command = false if event.key == 'left command'
end

# Define a callback function that pans the view when the mouse scroll wheel is used
on :mouse_scroll do |event|
  # If the command key is pressed, ZOOM in or out based on the scroll delta
  if command
    ZOOM += event.delta_y
    ZOOM = [ZOOM, 1].max
  # Otherwise, pan the view
  else
    PAN_X += event.delta_x * ZOOM * 10
    PAN_Y += event.delta_y * ZOOM * 10
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
    Circle.new(x: @x - PAN_X / ZOOM, y: @y - PAN_Y / ZOOM, radius: @radius / ZOOM, color: 'black')
  end

  def apply_force(fx, fy)
    # Apply a force to the particle by updating its velocity
    @vx += fx / @mass
    @vy += fy / @mass
  end
end

#rubocop:disable Metrics/BlockLength

update do
  # Clear the screen on each update
  clear

  particles.combination(2).each do |p1, p2|
    # Apply a gravitational force between each pair of particles

    # Calculate the distance between the particles
    dx = p1.x - p2.x
    dy = p1.y - p2.y
    distance = Math.sqrt(dx**2 + dy**2)
    # Calculate the gravitational force using Newton's law of universal gravitation
    f = (p1.mass * p2.mass) / distance**2
    # Calculate the x and y components of the force
    fx = f * dx / distance
    fy = f * dy / distance
    # Apply the force to each particle
    p1.apply_force(-fx, -fy)
    p2.apply_force(fx, fy)

    # Check for collisions between particles

    distance = Math.sqrt(dx**2 + dy**2)
    # If the distance is less than the sum of the radii, the particles are colliding
    if distance >= p1.radius + p2.radius
      next
    end

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

  # Update and draw each particle
  particles.each do |particle|
    particle.update
    particle.draw
  end
end

show