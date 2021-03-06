module RobotSimulation
  class Robot
    ORIENTATIONS = [:NORTH, :EAST, :SOUTH, :WEST]
    DIRECTIONS = [:LEFT, :RIGHT]
    ORIENT_LEFT = {:NORTH => :WEST, :EAST => :NORTH, :SOUTH => :EAST, :WEST => :SOUTH}
    ORIENT_RIGHT = {:NORTH => :EAST, :EAST => :SOUTH, :SOUTH => :WEST, :WEST => :NORTH}
    
    attr_reader :x, :y, :orientation, :table

    def initialize(table)
      @table = table
    end


    # Places the robot at a specific position on the table.
    #
    # Params:
    # +x+:: An Integer X coordinate the robot is to be placed.
    # +y+:: An Integer Y cooridnate the robot is to be placed.
    # +f+:: A Symbol of the direction the robot is to be facing (:NORTH, :EAST, :SOUTH, :WEST).
    #
    # Example:
    #   place!(1,3,:NORTH)
    #
    # Returns nil
    def place!(x, y, f)
      if valid_coordinates?(x, y)
        if valid_orientation?(f)
          @x, @y, @orientation = x, y, f
          nil
        else
          raise RobotSimulation::InvalidOrientationError, "Orientation should be one of #{ORIENTATIONS.join(', ')}."
        end
      else
        raise RobotSimulation::InvalidCoordinatesError, "Coordinates must be within range 0..#{table_max_coordinate}"
      end
    end


    # Moves the robot one unit forward in the direction it is currently facing.
    #
    # Returns nil
    def move!
      if placed?
        case orientation.to_sym
        when :NORTH then @y += 1 if valid_coordinates?(x, y + 1)
        when :EAST then @x += 1 if valid_coordinates?(x + 1, y)
        when :SOUTH then @y -= 1 if valid_coordinates?(x, y - 1)
        when :WEST then @x -= 1 if valid_coordinates?(x - 1, y)
        end
        nil
      else
        raise RobotSimulation::NotPlacedError, "Robot has not been placed yet."
      end
    end


    # Rotates the robot 90 degress in the specified direction maintaining current position.
    #
    # Params:
    # +direction+:: A Symbol representing the direction to rotate the robot. (:LEFT, :RIGHT)
    #
    # Example:
    #   rotate!(:RIGHT)
    #
    # Returns nil
    def rotate!(direction)
      if placed?
        if valid_direction? direction
          send("orient_#{direction.downcase}")
          nil
        else
          raise RobotSimulation::InvalidDirectionError, "Direction should be #{DIRECTIONS.join(' or ')}."
        end
      else
        raise RobotSimulation::NotPlacedError, "Robot has not been placed yet."
      end
    end


    # Gets the current position (X, Y) and facing (F) of the robot.
    #
    # Returns String of the current position of the robot. (1,3,EAST)
    def report
      if placed?
        position.flatten.map(&:to_s).join(',')
      else
        raise RobotSimulation::NotPlacedError, "Robot has not been placed yet."
      end
    end


    # Returns the current placed status of the robot
    # 
    # Returns Boolean of robots current placed status.
    def placed?
      x != nil && y != nil && orientation != nil
    end

    private

    def position
      [x, y, orientation]
    end

    def orient_left
      @orientation = ORIENT_LEFT[orientation]
    end

     def orient_right
      @orientation = ORIENT_RIGHT[orientation]
    end

    def valid_orientation?(orientation)
      ORIENTATIONS.include? orientation.to_sym
    end

    def valid_direction?(direction)
      DIRECTIONS.include? direction.to_sym
    end

    def valid_coordinates?(x, y)
      return false unless x.is_a?(Integer) && y.is_a?(Integer)
      x.between?(table_min_coordinate, table_max_coordinate) && y.between?(table_min_coordinate, table_max_coordinate)
    end

    def table_min_coordinate
      table.min_coordinate
    end

    def table_max_coordinate
      table.max_coordinate
    end

  end
end