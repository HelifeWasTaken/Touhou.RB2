class BulletBehavior

    def initialize()
        @tick = 0
    end

    def update(owner)
        @tick += 1;
    end

    def getTick()
        return @tick;
    end
end

class LinearBehavior < BulletBehavior

    def update(owner)
        owner.x += owner.speed * Math::cos(Omega::to_rad(owner.rotation))
        owner.y += owner.speed * Math::sin(Omega::to_rad(owner.rotation))
        super(owner);
    end
end

class CircularBehavior < BulletBehavior

    def initialize(start_angle = 0)
        super()
        @start_angle = start_angle
        @center = Omega::Vector2.new(0, 0)
        @radius = 0
        @angle = 0
        @speed = 1
        @circular_speed = 1
    end

    def update(owner)
        @center.x += @speed * Math::cos(Omega::to_rad(@angle))
        @center.y += @speed * Math::sin(Omega::to_rad(@angle))
        owner.x = @center.x + @radius * Math::cos(Omega::to_rad(@tick * @circular_speed + @start_angle))
        owner.y = @center.y + @radius * Math::sin(Omega::to_rad(@tick * @circular_speed + @start_angle))
        owner.angle = @tick * @circular_speed + 90 + @start_angle
        super(owner)
    end

    def setCenter(center)
        @center = center
        return self
    end

    def setRadius(radius)
        @radius = radius
        return self
    end

    def setAngle(angle)
        @angle = angle
        return self
    end

    def setSpeed(speed)
        @speed = speed
        return self
    end

    def setCircularSpeed(circular_speed)
        @circular_speed = circular_speed
        return self
    end
end

# ----------------------------------------

class Bullet < Omega::Sprite

    attr_accessor :rotation, :speed

    def initialize(source, width = nil, height = width)
        super(source)
        if (width != nil)
            if (height != nil)
                @size = Omega::Vector2.new(width, height)
            else
                @size = Omega::Vector2.new(width, width)
            end
        else
            @size = Omega::Vector2.new(@image.width, @image.height)
        end
        @rotation = 0
        @speed = 1
        @_behavior = LinearBehavior.new()
        # @hitbox
        self.set_origin(0.5)
    end

    def spawn(sink)
        throw "Bullet: sink must be an array" if not sink.is_a?(Array)
        throw "Bullet: sink cannot be nil" if sink.nil?
        sink << self
    end

    def update()
        if (@_behavior != nil)
            @_behavior.update(self)
        end
    end

    def draw()
        super()
    end

    def kill(); end

    def setSpeed(speed)
        @speed = speed
        return self
    end

    def setAngle(angle)
        @angle = angle
        @rotation = angle
        return self
    end

    def setBehavior(behavior)
        if (behavior != nil)
            @_behavior = behavior
        else
            @_behavior = LinearBehavior.new()
        end
        return self
    end

    def makeBehavior(behaviorClass, *params)
        if (behavior != nil)
            @_behavior = behavior.new(*params)
        else
            @_behavior = LinearBehavior.new()
        end
        return self
    end

    def getBehavior()
        return @_behavior
    end
end

class SplitBullet < Bullet

    def initialize(source, width = nil, height = width)
        super(source, width, height)
        @tick = 0
        
        @_split_bullet = nil
        @_split_number = 0
        @_depth = 0
        @_lifespan = 500
        @_sink = nil
        @_split_factor = 0.75
    end

    def spawn(sink)
        @tick = 0
        @_sink = sink
        super(sink)
    end

    def update()
        @tick += 1
        kill if @tick >= @_lifespan
        super()
    end

    def kill()
        throw "SplitBullet: sink cannot be nil" if @_sink.nil?
        throw "SplitBullet: sink must be an array" if not @_sink.is_a?(Array)
        throw "SplitBullet: split bullet cannot be nil" if @_split_bullet.nil?
        throw "SplitBullet: split number must be greater than 0" if @_split_number <= 0
        throw "SplitBullet: self is not in the sink" if not @_sink.include?(self)
        if (@_depth > 0)
            for i in 0...@_split_number
                bullet = self.clone()
                bullet.setSpeed(@speed.to_f * @_split_factor)
                bullet.setAngle(@angle + 360 / @_split_number * i)
                bullet.setDepth(@_depth - 1) if (bullet.is_a?(SplitBullet))
                bullet.position = self.position.clone()
                bullet.setLifespan(@_lifespan * @_split_factor)
                bullet.spawn(@_sink)
            end
        elsif (@_depth == 0)
            for i in 0...@_split_number
                bullet = @_split_bullet.clone()
                bullet.setSpeed(@speed.to_f * @_split_factor)
                bullet.setAngle(@angle + 360 / @_split_number * i)
                bullet.position = self.position.clone()
                bullet.spawn(@_sink)
            end
        end
        @_sink.delete(self)
        super()
    end

    def setSplit(bullet)
        @_split_bullet = bullet
        return self
    end

    def setSplitNumber(number)
        @_split_number = number
        return self
    end

    def setDepth(depth)
        @_depth = depth
        return self
    end

    def setLifespan(limespan)
        @_lifespan = limespan
        return self
    end

    def setSink(sink)
        throw "SplitBullet: sink cannot be nil" if sink.nil?
        throw "SplitBullet: sink must be an array" if not sink.is_a?(Array)
        @_sink = sink
        return self
    end

    def setSplitFactor(factor)
        @_split_factor = factor
        return self
    end
end