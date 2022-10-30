class CastCircle < Omega::Sprite

    attr :tick, :lifetime, :behaviour, :caster

    def initialize(filename, lifetime, behaviour, caster=nil)
        super(filename)
        @lifetime = lifetime
        @tick = 0
        @behaviour = behaviour

        self.position = Omega::Vector3.new(100, 100)
        self.set_origin(0.5)
    end

    def finished?
        return @tick >= @lifetime
    end

    def update
        @behaviour.update(self)
        @tick += 1

        if not caster.nil?
            self.position = caster.position
        end
    end

    def draw
        if finished?
            return
        end
        super
    end

end

class BasicCastBehaviour

    def initialize(angle_speed1=0.1, min_scale1=0.1, max_scale1=1, scale_speed1=0.01, color1=Omega::Color.copy(Omega::Color::WHITE),
                  angle_speed2=0.1, min_scale2=0.1, max_scale2=1, scale_speed2=0.01, color2=Omega::Color.copy(Omega::Color::WHITE))
        @scale_up = true
        @angle_speed1 = angle_speed1
        @min_scale1 = min_scale1
        @max_scale1 = max_scale1
        @scale_speed1 = scale_speed1
        @color1 = color1

        @angle_speed2 = angle_speed2
        @min_scale2 = min_scale2
        @max_scale2 = max_scale2
        @scale_speed2 = scale_speed2
        @color2 = color2

    end

    def set_part1(angle_speed, min_scale, max_scale, scale_speed, color=Omega::Color.copy(Omega::Color::WHITE))
        @angle_speed1 = angle_speed
        @min_scale1 = min_scale
        @max_scale1 = max_scale
        @scale_speed1 = scale_speed
        @color1 = color

        self
    end

    def set_part2(angle_speed, min_scale, max_scale, scale_speed, color=Omega::Color.copy(Omega::Color::WHITE))
        @angle_speed2 = angle_speed
        @min_scale2 = min_scale
        @max_scale2 = max_scale
        @scale_speed2 = scale_speed
        @color2 = color

        self
    end

    def scales_toward(cast, min_scale, max_scale, speed)
        if @scale_up
            if cast.scale.x < max_scale
                cast.set_scale(cast.scale.x + speed, cast.scale.y + speed)
            else
                @scale_up = false
            end
        else
            if cast.scale.x > min_scale
                cast.set_scale(cast.scale.x - speed, cast.scale.y - speed)
            else
                @scale_up = true
            end
        end
    end

    def update(cast)
        if cast.tick >= cast.lifetime / 2
            cast.color = @color2
            cast.alpha = 255 - (cast.tick - cast.lifetime / 2) * 255 / (cast.lifetime / 2)
            scales_toward(cast, @min_scale2, @max_scale2, @scale_speed2)
            cast.angle += @angle_speed2
        else
            cast.color = @color1
            scales_toward(cast, @min_scale1, @max_scale1, @scale_speed1)
            cast.angle += @angle_speed1
        end
    end

end

class InstantCastBehaviour

    def initialize(angle_speed=3,
                    scale_target=5,
                    scale_speed=0.02,
                    min_scale=0.5,
                    color=Omega::Color.copy(Omega::Color::WHITE))
        @angle_speed = angle_speed
        @scale_speed = scale_speed
        @scale_target = scale_target
        @color = color
        @min_scale = min_scale
    end

    def set_angle_speed(angle_speed)
        @angle_speed = angle_speed
        self
    end

    def set_scale_speed(scale_speed)
        @scale_speed = scale_speed
        self
    end

    def set_scale_target(scale_target)
        @scale_target = scale_target
        self
    end

    def set_scale_speed(scale_speed)
        @scale_speed = scale_speed
        self
    end

    def set_color(color)
        @color = color
        self
    end

    def set_min_scale(min_scale)
        @min_scale = min_scale
        self
    end

    def update(cast)
        scale = Omega.clamp(cast.scale.x, @min_scale, @scale_target)
        scale += 0.01
        cast.color.alpha = 255 - cast.tick * 255 / cast.lifetime

        cast.set_scale(scale, scale)
        cast.color = @color
        cast.angle += @angle_speed
    end

end

class FixedCastBehaviour

    def initialize(angle_speed=0.3, color=Omega::Color.copy(Omega::Color::WHITE))
        @angle_speed = angle_speed
        @color = color
    end

    def set_angle_speed(angle_speed)
        @angle_speed = angle_speed
        self
    end

    def set_color(color)
        @color = color
        self
    end

    def update(cast)
        cast.color = @color
        cast.angle += @angle_speed
    end

end

class FixedToInstantCastBehaviour

    def initialize(fixed_angle_speed=0.3,
                    instant_angle_speed=3,
                    scale_target=5,
                    min_scale=0.5,
                    tick_to_instant=nil,
                    fixed_color=Omega::Color.copy(Omega::Color::WHITE),
                    instant_color=nil)
        if instant_color.nil?
            instant_color = Omega::Color.copy(fixed_color)
        end

        @fixed_behaviour = FixedCastBehaviour.new(@fixed_angle_speed, @fixed_color)
        @instant_behaviour = InstantCastBehaviour.new(@instant_angle_speed,
                    @scale_target, @min_scale, @instant_color)
    end

    def set_fixed_angle_speed(fixed_angle_speed)
        @fixed_behaviour.set_angle_speed(fixed_angle_speed)
        self
    end

    def set_instant_angle_speed(instant_angle_speed)
        @instant_behaviour.set_angle_speed(instant_angle_speed)
        self
    end

    def set_scale_target(scale_target)
        @instant_behaviour.set_scale_target(scale_target)
        self
    end

    def set_scale_speed(scale_speed)
        @instant_behaviour.set_scale_speed(scale_speed)
        self
    end

    def set_fixed_color(fixed_color)
        @fixed_behaviour.set_color(Omega::Color.copy(fixed_color))
        self
    end

    def set_instant_color(instant_color)
        @instant_behaviour.set_color(Omega::Color.copy(instant_color))
        self
    end

    def set_color(fixed_color, instant_color=nil)
        if instant_color.nil?
            instant_color = Omega::Color.copy(fixed_color)
        end
        set_fixed_color(fixed_color).set_instant_color(instant_color)
    end

    def set_min_scale(min_scale)
        @instant_behaviour.set_min_scale(min_scale)
        self
    end

    def set_tick_to_instant(tick)
        @tick_to_instant = tick
        self
    end

    def update(cast)
        if @tick_to_instant.nil?
            set_tick_to_instant(cast.lifetime / 2)
        end
        if cast.tick < @tick_to_instant
            @fixed_behaviour.update(cast)
        else
            @instant_behaviour.update(cast)
        end
    end

end

class ParametricBehaviour

    # https://www.geogebra.org/m/f8MDV6YS
    def initialize(a=5, b=1.8, n=5, t=1,
                    go_up=false,
                    min_t=-50, max_t=50,
                    step=0.1,
                    origin=nil,
                    color=Omega::Color::WHITE)
        @a = a
        @b = b
        @t = n
        @n = t
        @go_up = false
        @min_t = min_t
        @max_t = max_t
        @step = step
        @origin = origin
        @color = Omega::Color.copy(color)
    end

    def set_limits(min_t, max_t)
        @min_t = min_t
        @max_t = max_t
        self
    end

    def set_step(step)
        @step = step
        self
    end

    def set_color(color)
        @color = Omega::Color.copy(color)
        self
    end

    def set_origin(x, y)
        @origin = Omega::Vector3.new(x, y, 0)
        self
    end

    def set_constants(a, b, n, t)
        @a = a
        @b = b
        @n = n

        self
    end

    def curve
        Omega::Vector3.new(
            @b * @t * Math.cos(@t + @a) * @n,
            @b * @t * Math.sin(@t + @a) * @n,
            0
        )
    end

    def update(cast)
        if @go_up
            @t += @step
        else
            @t -= @step
        end

        cast.color = @color

        @t = Omega.clamp(@t, @min_t, @max_t)
        if @t == @min_t or @t == @max_t
            @go_up = !@go_up
        end

        @origin = cast.position if @origin.nil?

        cast.position = curve + @origin
        cast.angle = @t * 180 / Math::PI
    end

end