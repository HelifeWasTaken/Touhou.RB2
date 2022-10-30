# Omega Engine - by D3nX
# Under MIT Licence
# "The Omega Engine is a Gosu based game framework that claim
# "to be fully open source and help everyone to developp faster
# and more efficiently game in ruby"
# Build 0.1

# Importing gosu & json gem
require 'gosu'
require 'json'

module Omega
    extend Gosu

    # Informations constants
    VERSION = "0.1"
    LICENCE = "MIT"

    # Structs
    Size = Struct.new(:width, :height)

    Font = Gosu::Font.new(150)

    module Ease
        # Sine
        def Ease.ease_in_sine(x)
            return 1 - Math.cos((x * Math::PI) / 2)
        end

        def Ease.ease_out_sine(x)
            return Math.sin((x * Math::PI) / 2)
        end

        def Ease.ease_in_out_sine(x)
            return -(Math::cos(Math::PI * x) - 1) / 2
        end

        # Back
        def Ease.ease_in_back(x)
            c1 = 1.70158;
            c3 = c1 + 1.0;
            
            return c3 * x * x * x - c1 * x * x
        end
        
        def Ease.ease_out_back(x)
            c1 = 1.70158
            c3 = c1 + 1.0
            
            return 1 + c3 * (x - 1) ** 3 + c1 * (x - 1) ** 2
        end

        def Ease.ease_in_out_back(x)
            c1 = 1.70158;
            c2 = c1 * 1.525;
            
            return x < 0.5 ? ((2 * x) ** 2 * ((c2 + 1) * 2 * x - c2)) / 2 : ((2 * x - 2) ** 2 * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2
        end
    end

    class Vector2

        attr_accessor :x, :y

        DEFAULT_EASE_FACTOR = 0.01

        def initialize(x = 0, y = 0)
            @x = x;
            @y = y;
            @ease_progress = 0
            @ease = nil
            @ease_position = nil
            @initial_ease_dist = 0
            @ease_factor = DEFAULT_EASE_FACTOR
        end

        def to_vector3()
            return Vector3.new(@x, @y, 0)
        end

        def normalize()
            length = Math.sqrt(@x * @x + @y * @y)
            @x /= length
            @y /= length
            return self
        end

        def distance(vec)
            return Gosu.distance(@x, @y, vec.x, vec.y)
        end

        def +(vector)
            return Vector2.new(@x + vector.x, @y + vector.y)
        end

        def *(scalar)
            return Vector2.new(@x * scalar, @y * scalar)
        end

        def -(other)
            return Vector2.new(@x - other.x, @y - other.y)
        end

        def to_s()
            return "Vector2(x: " + @x.to_s + ", y: " + @y.to_s + ")"
        end

        def update_easing
            return if not @ease or not @ease_position
            @x += (@ease_position.x - @x) * Ease::send(@ease, @ease_progress)
            @y += (@ease_position.y - @y) * Ease::send(@ease, @ease_progress)
            @ease_progress += @ease_factor if @ease_progress < 1
            if (@ease_position.x - @x).abs <= 1 and (@ease_position.y - @y).abs <= 1
                @x = @ease_position.x
                @y = @ease_position.y
                @ease = nil
                @ease_position = nil
                @ease_progress = 0
                @initial_ease_dist = 0
            end
        end

        def move_to(position, ease = :ease_in_out_sine, ease_factor = DEFAULT_EASE_FACTOR)
            @ease = ease
            @ease_position = position
            @ease_progress = 0
            @ease_factor = ease_factor
            @initial_ease_dist = distance2d(position)
        end

        def is_easing?
            @ease != nil && @ease_position != nil
        end
    end

    class Vector3 < Vector2

        attr_accessor :x, :y, :z

        def initialize(x = 0, y = 0, z = 0)
            @x = x;
            @y = y;
            @z = z;
        end

        def to_vector2()
            return Vector2.new(@x, @y)
        end

        def normalize()
            length = Math.sqrt(@x * @x + @y * @y + @z * @z)
            @x /= length
            @y /= length
            @z /= length
            return self
        end

        def distance2d(vec)
            return Gosu.distance(@x, @y, vec.x, vec.y)
        end

        def distance(vec)
            return Math::sqrt((@x - vec.x) ** 2 + (@y - vec.y) ** 2 + (@z - vec.z) ** 2)
        end

        def +(vector)
            return Vector3.new(@x + vector.x, @y + vector.y, @z + vector.z)
        end

        def *(scalar)
            return Vector3.new(@x * scalar, @y * scalar, @z * scalar)
        end

        def -(other)
            return Vector3.new(@x - other.x, @y - other.y, @z - other.z)
        end

        def to_s()
            return "Vector3(x: " + @x.to_s + ", y: " + @y.to_s + ", z: " + @z.to_s + ")"
        end
    end

    # Basic global functions
    def Omega.log_inf(msg)
        puts "OmegaEngine - Build[#{VERSION}][Log]: #{msg}"
    end

    def Omega.log_err(msg)
        raise "OmegaEngine - Build[#{VERSION}][Error]: #{msg}"
    end

    def Omega.distance(vec1, vec2)
        return Gosu.distance(vec1.x, vec1.y, vec2.x, vec2.y)
    end

    def Omega.in_range(vec1, vec2, range)
        return Gosu.distance(vec1.x, vec1.y, vec2.x, vec2.y) <= range
    end

    # Classes
    require_relative "./window"
    require_relative "./color"
    require_relative "./drawable"
    require_relative "./state"
    require_relative "./sprite"
    require_relative "./input"
    require_relative "./renderer"
    require_relative "./utils"
    require_relative "./assets"
    require_relative "./map"
    require_relative "./camera"
    require_relative "./rectangle"
    require_relative "./parallax"
    require_relative "./music_sample"
    require_relative "./transition"
    require_relative "./text"
    require_relative "./3d/omega3d"
end