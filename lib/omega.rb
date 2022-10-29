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

    class Vector2

        attr_accessor :x, :y

        def initialize(x = 0, y = 0)
            @x = x;
            @y = y;
        end

        def toVector3()
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
    end

    class Vector3

        attr_accessor :x, :y, :z

        def initialize(x = 0, y = 0, z = 0)
            @x = x;
            @y = y;
            @z = z;
        end

        def toVector2()
            return Vector2.new(@x, @y)
        end

        def normalize()
            length = Math.sqrt(@x * @x + @y * @y + @z * @z)
            @x /= length
            @y /= length
            @z /= length
            return self
        end

        def distance(vec)
            return Gosu.distance(@x, @y, vec.x, vec.y)
        end

        def +(vector)
            return Vector3.new(@x + vector.x, @y + vector.y, @z + vector.z)
        end

        def *(scalar)
            return Vector3.new(@x * scalar, @y * scalar, @z * scalar)
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