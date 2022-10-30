class CastCircle < Omega::Sprite

    attr_accessor :tick, :lifetime, :behaviour, :caster

    def initialize(filename, behaviour=nil, caster=nil,
                   use_interpolation_with_caster=true)
        super(filename)
        @lifetime = 0
        @tick = 0
        @behaviour = behaviour
        @setuped = false
        @use_interpolaion_with_caster = use_interpolation_with_caster

        self.position = Omega::Vector3.new(100, 100)
        self.set_origin(0.5)
    end

    def finished?
        return @tick >= @lifetime
    end

    def set_caster(caster)
        @caster = caster
        self
    end

    def set_behaviour(behaviour)
        @behaviour = behaviour
        self
    end

    def update
        if @behaviour.nil?
            throw "CastCircle.update: behaviour is nil"
        end

        if not @setuped
            @behaviour.setup(self)
            @setuped = true
        end

        @behaviour.update(self)
        @tick += 1

        if not caster.nil?
          if @use_interpolation_with_caster
            self.position = Omega.v3_lerp(self.position, caster.position,
                  Omega.percentage(@tick, @lifetime), true)
          else
            self.position = caster.position
          end
        end
    end

    def draw
        if finished?
            return
        end
        super
    end

end

class CastBehaviour
    attr :lifetime

    def initialize(lifetime)
        @lifetime = lifetime
    end

    def setup(cast)
        cast.lifetime = @lifetime + cast.lifetime
    end

    def update(cast)
        throw "CastBehaviour.update not implemented"
    end

    def set_lifetime(lifetime)
        @lifetime = lifetime
        self
    end

end

class BasicCastBehaviour < CastBehaviour

    def initialize(angle_speed=0.1, min_scale=0.1, max_scale=1,
                   scale_speed=0.01, lifetime=400, color=Omega::Color::WHITE)
        super(lifetime)
        @scale_up = true
        @angle_speed = angle_speed
        @min_scale = min_scale
        @max_scale = max_scale
        @scale_speed = scale_speed
        @color = Omega::Color.copy(color)
    end

    def set_angle_speed(angle_speed)
        @angle_speed = angle_speed
        self
    end

    def set_min_scale(min_scale)
        @min_scale = min_scale
        self
    end

    def set_max_scale(max_scale)
        @max_scale = max_scale
        self
    end

    def set_scale_speed(scale_speed)
        @scale_speed = scale_speed
        self
    end

    def set_color(color)
        @color = Omega::Color.copy(color)
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
        #cast.alpha = 255 - (cast.tick - cast.lifetime / 2) * 255 / (cast.lifetime / 2)
        cast.color = @color
        scales_toward(cast, @min_scale, @max_scale, @scale_speed)
        cast.angle += @angle_speed
    end

end

class InstantCastBehaviour < CastBehaviour

    def initialize(angle_speed=3,
                    scale_target=5,
                    scale_speed=0.02,
                    min_scale=0.5,
                    lifetime=200,
                    color=Omega::Color::WHITE)
        super(lifetime)
        @angle_speed = angle_speed
        @scale_speed = scale_speed
        @scale_target = scale_target
        @min_scale = min_scale
        @lifetime = lifetime
        @color = Omega::Color.copy(color)
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

class FixedCastBehaviour < CastBehaviour

    def initialize(angle_speed=0.3, lifetime=400, color=Omega::Color::WHITE)
        super(lifetime)
        @angle_speed = angle_speed
        @color = Omega::Color.copy(color)
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

class ParametricBehaviour < CastBehaviour

    # https://www.geogebra.org/m/f8MDV6YS
    def initialize(a=5, b=1.8, n=5, t=1,
                    go_up=true,
                    min_t=-50, max_t=50,
                    step=0.1,
                    lifetime=400,
                    origin=nil,
                    color=Omega::Color::WHITE)
        super(lifetime)
        @a = a
        @b = b
        @t = n
        @n = t
        @go_up = true
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

    def set_constants(a=nil, b=nil, n=nil)
      if not a.nil?
        @a = a
      end
      if not b.nil?
        @b = b
      end
      if not n.nil?
        @n = n
      end
      self
    end

    def set_t(t)
      @t = t
      self
    end

    def set_go_up(go_up)
        @go_up = go_up
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

class CastSetCasterBehaviour < CastBehaviour

  def initialize(caster)
    super(0)
    @caster = caster
  end

  def update(cast)
    cast.caster = cast
  end

end

class CastSetTransformBehaviour < CastBehaviour

  def initialize(x=nil, y=nil, scale=nil, angle=nil)
    super(0)
    @x = x
    @y = y
    @scale = scale
    @angle = angle
  end

  def update(caster)
    if not @x.nil?
      caster.position.x = @x
    end
    if not @y.nil?
      caster.position.y = @y
    end
    if not @scale.nil?
      caster.scale = @scale
    end
    if not @angle.nil?
      caster.angle = @angle
    end
  end

end

class MixedCastBehaviour

    def initialize
        @behaviours = []
        @index = 0
    end

    def add_behaviour(behaviour)
        @behaviours << behaviour
        self
    end

    def setup(cast)
        counter = 0
        @behaviours.each do |behaviour|
            counter += behaviour.lifetime
            behaviour.setup(cast)
            behaviour.set_lifetime(counter)
        end
    end

    def update(cast)
        @behaviours[@index].update(cast)
        if @behaviours[@index].lifetime < cast.tick
            @index = Omega.clamp(@index + 1, 0, @behaviours.size - 1)
        end
    end

end
