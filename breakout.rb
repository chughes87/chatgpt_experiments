require 'gosu'

# Constant values for the window size and paddle size
WINDOW_WIDTH = 640
WINDOW_HEIGHT = 480
PADDLE_WIDTH = 100
PADDLE_HEIGHT = 20

# Constant values for the ball size and movement speed
BALL_RADIUS = 10
BALL_SPEED = 10

PADDLE_SPEED = 10

# The main game window class
class BreakoutWindow < Gosu::Window
  attr_reader :bricks
  # Initialize the window, paddle, and ball objects
  def initialize
    super(WINDOW_WIDTH, WINDOW_HEIGHT)
    self.caption = "Breakout"
    # Initialize the ball at the center of the window
    @ball = Ball.new(WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2, BALL_SPEED / 2, BALL_SPEED / 2, BALL_RADIUS*2, BALL_RADIUS*2)
    # Initialize the paddle at the bottom center of the window
    @paddle = Paddle.new(WINDOW_WIDTH / 2, WINDOW_HEIGHT - 20, 80, 10)
    # Initialize the bricks
    @bricks = []
    10.times do |i|
      10.times do |j|
        @bricks << Brick.new(i * 60 + 30, j * 20 + 20, 50, 10)
      end
    end
    # Initialize the font
    @font = Gosu::Font.new(20)
  end

  # Update the window
  def update
    # Update the paddle
    if Gosu.button_down?(Gosu::KB_LEFT) && @paddle.x > @paddle.width / 2
      @paddle.x -= PADDLE_SPEED
    end
    if Gosu.button_down?(Gosu::KB_RIGHT) && @paddle.x < WINDOW_WIDTH - @paddle.width / 2
      @paddle.x += PADDLE_SPEED
    end

    # Update the ball
    @ball.update(@paddle, @bricks)

    # Check if the game is over
    if @ball.y > WINDOW_HEIGHT
      @game_over = true
    end
  end
  
  # Show the game over screen
  def game_over_screen
    Gosu.draw_rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, 0xff000000)
    @font.draw_text("Game Over", WINDOW_WIDTH / 2 - @font.text_width("Game Over") / 2, WINDOW_HEIGHT / 2 - @font.height / 2, 0xffffffff)
    close if Gosu.button_down?(Gosu::KB_ESCAPE)
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
    # Draw the ball
    @ball.draw
    # Draw the paddle
    @paddle.draw
    # Draw the bricks
    @bricks.each do |brick|
      brick.draw
    end
    # Draw the score
    @font.draw("Score: #{@bricks.filter(&:broken).size}", 10, 10, 0)

    game_over_screen if @game_over
  end

    # Handle keyboard input
    def button_down(id)
      case id
      when Gosu::KbLeft
        @paddle.move_left
      when Gosu::KbRight
        @paddle.move_right
      when Gosu::KbEscape
        close
      end
    end
end


# Define the Paddle class
class Paddle
  attr_accessor :x, :y, :width, :height

  # Initialize the paddle
  def initialize(x, y, width, height)
    @x = x
    @y = y
    @width = width
    @height = height
  end

  # Update the paddle
  def update
    # Move the paddle left if the left arrow key is being held down
    @x -= PADDLE_SPEED if Gosu.button_down?(Gosu::KbLeft)
    # Move the paddle right if the right arrow key is being held down
    @x += PADDLE_SPEED if Gosu.button_down?(Gosu::KbRight)
    # Keep the paddle within the window bounds
    @x = [[@x, @width / 2].max, WINDOW_WIDTH - @width / 2].min
  end

  # Draw the paddle
  def draw
    Gosu.draw_rect(@x - @width / 2, @y - @height / 2, @width, @height, Gosu::Color::WHITE)
  end

  # Move the paddle left
  def move_left
    @x -= PADDLE_SPEED
  end

  # Move the paddle right
  def move_right
    @x += PADDLE_SPEED
  end
end

# Define the Ball class
class Ball
  attr_accessor :x, :y, :vx, :vy, :width, :height

  # Initialize the ball
  def initialize(x, y, vx, vy, width, height)
    @x = x
    @y = y
    @vx = vx
    @vy = vy
    @width = width
    @height = height
  end

  # Update the ball
  def update(paddle, bricks)
    # Move the ball
    @x += @vx
    @y += @vy

    # Check for collisions with the walls
    if @x - @width / 2 <= 0 || @x + @width / 2 >= WINDOW_WIDTH
      @vx *= -1
    end
    if @y - @height / 2 <= 0
      @vy *= -1
    end

    # Check for collisions with the paddle
    if @y + @height / 2 > paddle.y - paddle.height / 2 && @x > paddle.x - paddle.width / 2 && @x < paddle.x + paddle.width / 2
      @vy *= -1
    end

    # Check for collisions with the bricks
    bricks.reject(&:broken).each do |brick|
      if @x + @width / 2 > brick.x - brick.width / 2 && @x - @width / 2 < brick.x + brick.width / 2 && @y - @height / 2 < brick.y + brick.height / 2 && @y + @height / 2 > brick.y - brick.height / 2
        @vy *= -1
        brick.broken = true
      end
    end
  end

  # Draw the ball
  def draw
    Gosu.draw_rect(@x - @width / 2, @y - @height / 2, @width, @height, Gosu::Color::WHITE)
  end
end

# Define the Brick class
class Brick
  attr_accessor :x, :y, :width, :height, :broken

  # Initialize the brick
  def initialize(x, y, width, height)
    @x = x
    @y = y
    @width = width
    @height = height
    @broken = false
  end

  # Draw the brick
  def draw
    Gosu.draw_rect(@x - @width / 2, @y - @height / 2, @width, @height, Gosu::Color::RED) unless @broken
  end
end

BreakoutWindow.new.show
