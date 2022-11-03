class BulletEmitter

    def initialize(sink)
        @tick = 0
        @emitting = false
        throw "BulletEmitter: sink must be an array" if not sink.is_a?(Array)
        throw "BulletEmitter: sink cannot be nil" if sink.nil?
        @_sink = sink
        @is_enemy = true
    end

    def emit(data = {})
        @emitting = true
    end

    def update()
        @tick += 1
    end

    def set_side(enemy = true)
        @is_enemy = enemy
        return self
    end

    def is_emitting?()
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
        @_bullet = nil
        @_emitter = nil
    end

    def emit(data = {})
        return if is_emitting?
        #---
        if not data[:fallthrough].nil?
            data[:fallthrough] -= 1
            if data[:fallthrough] >= 0
                super(data)
                return
            end
        end
        #---
        @position = @start.clone()
        @tick = 0
        super()
    end

    def update()
        return if not is_emitting?
        angle = Math::atan2(Omega.mouse_position.y - @position.y, Omega.mouse_position.x - @position.x) * 180 / Math::PI
        if @_collision_rect.point_collides?(@position)
            @emitting = false
        end
        #---
        if not @_bullet.nil?
            bullet = @_bullet.clone().set_angle(angle).set_speed(7)
            if (@tick % @_tick_factor == 0)
                bullet.set_position(@position.toVector3)
                @_sink << bullet if @tick > 0 && @tick < (@start.distance(@end) / @_speed).ceil() - 1
            end
        end
        #---
        if not @_emitter.nil?
            emitter = @_emitter.clone()
            emitter.emit({:center => @position.toVector3}) if (@tick % @_tick_factor == 0)
        end
        #---
        @position += @_vector * @_speed
        super()
    end

    def set_start(start_)
        @start = start_
        @_vector = Omega::Vector2.new(@end.x - @start.x, @end.y - @start.y).normalize()
        return self
    end

    def set_end(end_)
        @end = end_
        @_vector = Omega::Vector2.new(@end.x - @start.x, @end.y - @start.y).normalize()
        return self
    end

    def set_speed(speed)
        @_speed = speed
        @_collision_rect = Omega::Rectangle.new(@end.x, @end.y, @end.x + @_speed, @end.y + @_speed)
        @_tick_factor = ((@start.distance(@end) / @_speed).ceil() / (@_number + 1)).ceil()
        return self
    end

    def set_bullet_number(number)
        @_number = number
        @_tick_factor = ((@start.distance(@end) / @_speed).ceil() / (@_number + 1)).ceil()
        return self
    end

    def set_bullet(bullet)
        @_bullet = bullet
        return self
    end

    def set_emitter(emitter)
        @_emitter = emitter
        return self
    end
end

class SplitEmitter < BulletEmitter

    def initialize(sink)
        super(sink)
        @center = Omega::Vector2.new(0, 0)
        @angle = 0
        @speed = 1
        @number = 0
        @radius = 0
        @bullet = nil
    end

    def emit(data)
        return if is_emitting?
        #---
        if not data[:fallthrough].nil?
            data[:fallthrough] -= 1
            if data[:fallthrough] >= 0
                super(data)
                return
            end
        end
        #---
        angle = @angle
        inc = 360.0 / @number.to_f if @number > 0
        if (data[:center] != nil)
            for i in 0...@number
                @_sink << @bullet.clone().set_position(data[:center] + Omega::Vector2.new(@radius * Math::cos(Omega::to_rad(angle)), @radius * Math::sin(Omega::to_rad(angle))).to_vector3).set_angle(angle).set_speed(@speed)
                angle += inc
            end
        else
            for i in 0...@number
                @_sink << @bullet.clone().set_position(@center + Omega::Vector2.new(@radius * Math::cos(Omega::to_rad(angle)), @radius * Math::sin(Omega::to_rad(angle))).to_vector3).set_angle(angle).set_speed(@speed)
                angle += inc
            end
        end
        super(data)
    end

    def update()
        @emitting = false if is_emitting?        
        super()
    end

    def set_center(center_)
        @center = center_
        return self
    end

    def set_angle(angle_)
        @angle = angle_
        return self
    end

    def set_speed(speed_)
        @speed = speed_
        return self
    end

    def set_bullet_number(number_)
        @number = number_
        return self
    end

    def set_radius(radius_)
        @radius = radius_
        return self
    end

    def set_split_bullet(bullet_)
        @bullet = bullet_
        return self
    end

    def set_position(pos)
        set_center(pos)
    end
end

class SpiralEmitter < SplitEmitter

    def initialize(bullet_list)
        super(bullet_list)
        @radius = 0
        @radius_speed = 1
    end

    def emit(data)
        return if is_emitting?
        #---
        if not data[:fallthrough].nil?
            data[:fallthrough] -= 1
            if data[:fallthrough] >= 0
                super(data)
                return
            end
        end
        #---
        angle = @angle
        inc = 360.0 / @number.to_f if @number > 0
        if (data[:center] != nil)
            for i in 0...@number
                behavior = SpiralBehavior.new(nil, angle).set_center(data[:center]).set_radius(@radius).set_angle(@angle).set_radius_speed(@radius_speed).set_circular_speed(@speed)
                @_sink << @bullet.clone().set_position(data[:center] + Omega::Vector2.new(@radius * Math::cos(Omega::to_rad(angle)), @radius * Math::sin(Omega::to_rad(angle))).toVector3).set_behavior(behavior)
                angle += inc
            end
        else
            for i in 0...@number
                behavior = SpiralBehavior.new(nil, angle).set_center(@center).set_radius(@radius).set_angle(@angle).set_radius_speed(@radius_speed).set_circular_speed(@speed)
                @_sink << @bullet.clone().set_position(@center + Omega::Vector2.new(@radius * Math::cos(Omega::to_rad(angle)), @radius * Math::sin(Omega::to_rad(angle))).toVector3).set_behavior(behavior)
                angle += inc
            end
        end
        data[:fallthrough] = 1 if data[:fallthrough].nil?
        super(data)
    end

    def update()
        @emitting = false if is_emitting?        
        super()
    end

    def set_radius_speed(radius_speed_)
        @radius_speed = radius_speed_
        return self
    end
end