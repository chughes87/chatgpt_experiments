require 'gosu'

# Constant values for the window size and paddle size
WINDOW_WIDTH = 640
WINDOW_HEIGHT = 480
PADDLE_WIDTH = 100
PADDLE_HEIGHT = 20

# Constant values for the ball size and movement speed
BALL_RADIUS = 10
BALL_SPEED = 4

# The main game window class
class BreakoutWindow < Gosu::Window
  attr_reader :bricks
  # Initialize the window, paddle, and ball objects
  def initialize
    super WINDOW_WIDTH, WINDOW_HEIGHT
    self.caption = "Breakout"

    @paddle = Paddle.new(self)
    @ball = Ball.new(self, @paddle)

    @bricks = []
    init_bricks

    @font = Gosu::Font.new(self, "Arial", 48)
  end

  def init_bricks
    x = 0
    y = 0
    colors = [:red, :orange, :yellow, :green, :blue, :indigo, :violet]
    10.times do
      color = color_to_hex(colors[y / 20])
      brick = Brick.new(x, y, 60, 20, color)
      @bricks << brick
      x += brick.width
      if x + brick.width > WINDOW_WIDTH
        x = 0
        y += brick.height
      end
    end
  end

  # Update the game state
  def update
    @paddle.update
    @ball.update

    @bricks.each do |brick|
      if Gosu.distance(@ball.x, @ball.y, brick.x, brick.y) < BALL_RADIUS + brick.height / 2
        if !brick.broken
          brick.broken = true
          if @ball.x < brick.x || @ball.x > brick.x + brick.width
            # Collision on the left or right side of the brick
            @ball.vx *= -1
          else
            # Collision on the top or bottom side of the brick
            @ball.vy *= -1
          end
        end
      end
    end
  end

  def color_to_hex(color)
    case color
    when :red
      0xffff0000
    when :orange
      0xffff8800
    when :yellow
      0xffffff00
    when :green
      0xff00ff00
    when :blue
      0xff0000ff
    when :indigo
      0xff4b0082
    when :violet
      0xff8b00ff
    end
  end

  # Draw the game objects to the screen
  def draw
    if @ball.y <= WINDOW_HEIGHT
      # Draw the paddle, ball, and bricks
      @paddle.draw
      @ball.draw
      @bricks.each do |brick|
        unless brick.broken
          Gosu.draw_rect(brick.x, brick.y, brick.width, brick.height, brick.color)
        end
      end
    else
      # Ball has gone off the bottom of the screen, show the game over screen
      Gosu.draw_rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, 0xff000000)
      @font.draw_text("Game Over", WINDOW_WIDTH / 2 - @font.text_width("Game Over") / 2, WINDOW_HEIGHT / 2 - @font.height / 2, 0xffffffff)
      close if Gosu.button_down?(Gosu::KB_ESCAPE)
    end
  end

end


# The paddle class
class Paddle
  attr_accessor :x, :y, :width, :height
  # Initialize the paddle object at the bottom center of the screen
  def initialize(window)
    @window = window
    @x = WINDOW_WIDTH / 2 - PADDLE_WIDTH / 2
    @y = WINDOW_HEIGHT - PADDLE_HEIGHT - 10
    @width = PADDLE_WIDTH
    @height = PADDLE_HEIGHT
  end

  # Update the paddle position based on keyboard input
  def update
    if @window.button_down?(Gosu::KbLeft) && @x.positive?
      @x -= 5
    elsif @window.button_down?(Gosu::KbRight) && @x < WINDOW_WIDTH - PADDLE_WIDTH
      @x += 5
    end
  end

  # Draw the paddle to the screen
  def draw
    Gosu.draw_rect(@x, @y, PADDLE_WIDTH, PADDLE_HEIGHT, Gosu::Color::WHITE)
  end

  def move_left
    @x -= PADDLE_SPEED
    @x = 0 if @x < 0
  end

  def move_right
    @x += PADDLE_SPEED
    @x = WINDOW_WIDTH - PADDLE_WIDTH if @x > WINDOW_WIDTH - PADDLE_WIDTH
  end
end

# The ball class
class Ball
  ZOrder = 1
  attr_accessor :x, :y, :vy, :vx, :width, :height
  # Initialize the ball object at the top center of the screen
  def initialize(window, paddle)
    @window = window
    @paddle = paddle
    @x = WINDOW_WIDTH / 2
    @y = PADDLE_HEIGHT + 10
    @vx = BALL_SPEED
    @vy = -BALL_SPEED
    @width = BALL_RADIUS
    @height = BALL_RADIUS
  end

  def collides?(object)
    # Check if the ball is within the horizontal bounds of the object
    if object.x < @x && @x < object.x + object.width
      # Check if the ball is within the vertical bounds of the object
      if object.y < @y && @y < object.y + object.height
        return true
      end
    end
    false
  end

  # Update the ball position and check for collisions
  def update
    # Update the ball's position
    @x += @vx
    @y += @vy

    # Check for collisions with the window bounds
    if @x < 0 || @x > WINDOW_WIDTH
      @vx *= -1
    end
    if @y < 0
      @vy *= -1
    end

    # Check for collisions with the paddle
    if collides?(@paddle)
      # Reverse the vertical velocity and increase the speed slightly
      @vy *= -1
      @vx *= 1.1
      @vy *= 1.1
    end

    # Check for collisions with the bricks
    @window.bricks.each do |brick|
      if collides?(brick) && !brick.broken
        # Reverse the vertical velocity and mark the brick as broken
        @vy *= -1
        brick.broken = true
      end
    end
  end

  # Draw the ball to the screen
  def draw
    # Use Gosu.draw_line to draw the ball
    num_segments = 32
    angle_step = 2 * Math::PI / num_segments
    angle = 0
    (0...num_segments).each do |i|
      Gosu.draw_line(@x + Math.cos(angle) * BALL_RADIUS, @y + Math.sin(angle) * BALL_RADIUS,
                     Gosu::Color::WHITE,
                     @x + Math.cos(angle + angle_step) * BALL_RADIUS, @y + Math.sin(angle + angle_step) * BALL_RADIUS,
                     Gosu::Color::WHITE,
                     ZOrder)
      angle += angle_step
    end
  end
end

class Brick
  attr_accessor :x, :y, :width, :height, :color, :broken

  def initialize(x, y, width, height, color)
    @x = x
    @y = y
    @width = width
    @height = height
    @color = color
    @broken = false
  end
end

BreakoutWindow.new.show
