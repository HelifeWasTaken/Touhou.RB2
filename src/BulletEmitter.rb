class BulletEmitter

    def initialize(bullet_list)
        @tick = 0
        @emitting = false
        throw "BulletEmitter: bullet_list must be an array" if not bullet_list.is_a?(Array)
        throw "BulletEmitter: bullet_list cannot be nil" if bullet_list.nil?
        @bullets = bullet_list
    end

    def emit()
        @emitting = true
    end

    def update()
        @tick += 1
    end

    def isEmitting?()
        return @emitting
    end
end

class LinearEmitter < BulletEmitter

    def initialize(bullet_list, start_, end_)
        super(bullet_list)
        @start = start_.clone()
        @end = end_.clone()
        @position = @start.clone()
        
        @_vector = Omega::Vector2.new(@end.x - @start.x, @end.y - @start.y).normalize()
        @_speed = 1
        @_collision_rect = Omega::Rectangle.new(@end.x, @end.y, @end.x + @_speed, @end.y + @_speed)
        @_number = 1
        @_tick_factor = ((@start.distance(@end) / @_speed).ceil() / (@_number + 1)).ceil()
    end

    def emit()
        return if isEmitting?
        @position = @start.clone()
        @tick = 0
        super()
    end

    def update()
        return if not isEmitting?
        angle = Math::atan2(Omega.mouse_position.y - @position.y, Omega.mouse_position.x - @position.x) * 180 / Math::PI
        if @_collision_rect.point_collides?(@position)
            @emitting = false
        end
        bullet = Bullet.new("assets/textures/bullet/red_blade.png").setAngle(angle).setSpeed(7)
        bullet.position = @position.toVector3
        if (@tick % @_tick_factor == 0)
            @bullets << bullet if @tick > 0 && @tick < (@start.distance(@end) / @_speed).ceil() - 1
        end
        @position += @_vector * @_speed
        super()
    end

    def setStart(start_)
        @start = start_
        @_vector = Omega::Vector2.new(@end.x - @start.x, @end.y - @start.y).normalize()
        return self
    end

    def setEnd(end_)
        @end = end_
        @_vector = Omega::Vector2.new(@end.x - @start.x, @end.y - @start.y).normalize()
        return self
    end

    def setSpeed(speed)
        @_speed = speed
        @_collision_rect = Omega::Rectangle.new(@end.x, @end.y, @end.x + @_speed, @end.y + @_speed)
        @_tick_factor = ((@start.distance(@end) / @_speed).ceil() / (@_number + 1)).ceil()
        return self
    end

    def setBulletNumber(number)
        @_number = number
        @_tick_factor = ((@start.distance(@end) / @_speed).ceil() / (@_number + 1)).ceil()
        return self
    end
end