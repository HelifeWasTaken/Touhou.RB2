module BehaviorType

    PERMANENT = 0
    TEMPORARY = 1

end

class BulletBehavior

    def initialize(owner = nil) 
        @owner = owner;
        @tick = 0
        @need_data = {
            :feed => false
        }
    end

    def update()
        # puts "Killing bullet at #{@owner.position.to_s}" if not Omega.position_in_window?(@owner.position, Omega::Vector2.new(250, 250))
        @owner.kill if not Omega.position_in_window?(@owner.position, Omega::Vector2.new(250, 250))
        @tick += 1;
    end

    def getTick()
        return @tick;
    end

    def set_owner(owner)
        throw "BulletBehavior: owner has been already set" if not @owner.nil?
        @owner = owner;
        return self
    end

    def feed_in(); end

    def copy(other)
        tmp = self.clone()
        tmp.reset_owner(other) # kek
        return tmp
    end

    protected

    def reset_owner(new_owner)
        @owner = new_owner
    end
end

class LinearBehavior < BulletBehavior

    def update()
        @owner.move(Omega::Vector2.new(@owner.speed * Math::cos(Omega::to_rad(@owner.rotation)), @owner.speed * Math::sin(Omega::to_rad(@owner.rotation))))
        super();
    end
end

class CircularBehavior < BulletBehavior

    def initialize(owner = nil, start_angle = 0)
        super(owner)
        @start_angle = start_angle
        @center = Omega::Vector2.new(0, 0)
        @radius = 0
        @angle = 0
        @speed = 1
        @circular_speed = 1
    end

    def update()
        @center.x += @speed * Math::cos(Omega::to_rad(@angle))
        @center.y += @speed * Math::sin(Omega::to_rad(@angle))
        @owner.set_position(Omega::Vector2.new(@center.x + @radius * Math::cos(Omega::to_rad(@tick * @circular_speed + @start_angle)), @center.y + @radius * Math::sin(Omega::to_rad(@tick * @circular_speed + @start_angle))))
        @owner.set_angle(@tick * @circular_speed + 90 + @start_angle)
        @owner.speed = @circular_speed
        super()
    end

    def set_center(center)
        @center = center
        return self
    end

    def use_owner_position_as_center()
        if @owner.nil?
            @need_data[:feed] = true
            @need_data[:center] = true
        else
            @center = @owner.position.toVector2
        end
        return self
    end

    def set_radius(radius)
        @radius = radius
        return self
    end

    def set_angle(angle)
        @angle = angle
        return self
    end

    def set_speed(speed)
        @speed = speed
        return self
    end

    def set_circular_speed(circular_speed)
        @circular_speed = circular_speed
        return self
    end

    def feed_in()
        if @need_data[:center]
            @center = @owner.position.toVector2
        end
    end

    def need_feed_in?()
        return @need_data[:feed]
    end
end

class SpiralBehavior < CircularBehavior

    def initialize(owner = nil, start_angle = 0)
        super(owner, start_angle)
        set_speed(0)
        @radius_speed = 0.5
    end

    def update()
        @radius += @radius_speed
        super()
    end

    def set_radius_speed(radius_speed)
        @radius_speed = radius_speed
        return self
    end
end

# ----------------------------------------

class Bullet < Omega::Sprite

    attr_accessor :rotation, :speed, :hitbox, :_behavior

    def initialize(source, width = nil, height = width)
        super(source)

        @@id ||= 0
        @id = @@id
        @@id += 1

        if (width != nil)
            if (height != nil)
                @size = Omega::Vector2.new(width, height)
                @hitbox = BulletCollider.new(self, 0, 0, width / 2.0, height / 2.0)
            else
                @size = Omega::Vector2.new(width, width)
                @hitbox = BulletCollider.new(self, 0, 0, width / 2.0, width / 2.0)
            end
        else
            @size = Omega::Vector2.new(@image.width, @image.height)
            @hitbox = BulletCollider.new(self, 0, 0, @image.width / 2.0, @image.height / 2.0)
        end
        @hitbox.set_side()
        @rotation = 0
        @speed = 1
        @_behavior = [
            {
                :behavior => LinearBehavior.new(self),
                :type => BehaviorType::PERMANENT,
                :extra => {}
            }
        ]
        @_dead = false
        @_sink = nil
        self.set_origin(0.5)
    end

    def initialize_copy(this)
        self.hitbox = this.hitbox.copy(self);
        self._behavior = this._behavior.map { |behavior| {:behavior => behavior[:behavior].copy(self), :type => behavior[:type], :extra => behavior[:extra]} }
        super(this)
    end

    def spawn()
        throw "Bullet: sink cannot be nil" if @_sink.nil?
        @_sink << self
        return self
    end

    def update(data = {})
        if @_dead
            @_sink.delete(self) if (not @_sink.nil? and (data[:post_mortal].nil? or not data[:post_mortal]))
            return
        end
        $tree.insert(@hitbox.collision)
        if (@_behavior != nil)
            if @_behavior.size == 0
                @_behavior << {
                    :behavior => LinearBehavior.new(self),
                    :type => BehaviorType::PERMANENT,
                    :extra => {}
                }
            end
            if @_behavior[-1][:type] == BehaviorType::TEMPORARY
                @_behavior.pop() if @_behavior[-1][:behavior].getTick() > @_behavior[-1][:extra][:duration]
            end
            @_behavior[-1][:behavior].update()
        end
    end

    def draw()
        if $debug_flags[:hitboxes]
            @hitbox.draw()
            vec = Omega::Vector2.new(Math::cos(Omega::to_rad(@rotation)), Math::sin(Omega::to_rad(@rotation)))
            start_p = self.position
            end_p = start_p + (vec * 50).to_vector3
            Gosu::draw_line(start_p.x, start_p.y, Omega::Color.new(0xff0000ff), end_p.x, end_p.y, Omega::Color.new(0xff0000ff), 250000)
        end
        @position.z = 10_000
        super()
    end

    def kill()
        @_dead = true             
    end

    def set_speed(speed)
        @speed = speed
        return self
    end

    def set_angle(angle)
        @angle = angle
        @rotation = angle
        return self
    end

    def set_sink(sink)
        throw "SplitBullet: sink cannot be nil" if sink.nil?
        throw "SplitBullet: sink must be an array" if not sink.is_a?(Array)
        @_sink = sink
        return self
    end

    def set_position(pos)
        if pos.is_a? Omega::Vector2
            self.position = pos.to_vector3 
        else
            self.position = pos.clone
        end
        @hitbox.update_collider_position(self.position.x - @hitbox.collision.w / 2.0, self.position.y - @hitbox.collision.h / 2.0)
        return self
    end

    def move(vec)
        return set_position(position + vec.to_vector3)
    end

    def set_bullet_side(enemy = true)
        @hitbox.set_side(enemy)
        return self
    end

    def replace_behavior(behavior, type = BehaviorType::PERMANENT, extra = {})
        throw "Bullet: behavior must be a BulletBehavior" if not behavior.is_a?(BulletBehavior)
        throw "Bullet: behavior cannot be nil" if behavior.nil?
        behavior.set_owner(self)
        behavior.feed_in() if behavior.need_feed_in?
        @_behavior[-1] = {
                :behavior => behavior,
                :type => type,
                :extra => extra
            }
        return self
    end

    def add_behavior(behavior, type = BehaviorType::PERMANENT, extra = {})
        throw "Bullet: behavior must be a BulletBehavior" if not behavior.is_a?(BulletBehavior)
        throw "Bullet: behavior cannot be nil" if behavior.nil?
        behavior.set_owner(self)
        behavior.feed_in() if behavior.need_feed_in?
        @_behavior << {
            :behavior => behavior,
            :type => type,
            :extra => extra
        }
        return self
    end

    def set_behavior(behavior, type = BehaviorType::PERMANENT, extra = {})
        throw "Bullet: behavior must be a BulletBehavior" if not behavior.is_a?(BulletBehavior)
        throw "Bullet: behavior cannot be nil" if behavior.nil?
        behavior.set_owner(self)
        behavior.feed_in() if behavior.need_feed_in?
        @_behavior = [
            {
                :behavior => behavior,
                :type => type,
                :extra => extra
            }
        ]
        return self
    end

    def get_top_behavior()
        return @_behavior[-1]
    end

    def get_id
        return @id
    end

end

class SplitBullet < Bullet

    def initialize(source, width = nil, height = width)
        super(source, width, height)
        @tick = 0
        
        @_emitter = nil
        @_split_number = 0
        @_depth = 0
        @_lifespan = 500
        @_sink = nil
        @_split_factor = 0.75

        @_min_angle = 0
        @_max_angle = 360
    end

    def spawn()
        @tick = 0
        super()
    end

    def update(data = {})
        @_emitter.update()
        if @_dead
            return if @_emitter.is_emitting?
            @_sink.delete(self) if (not @_sink.nil? and (data[:post_mortal].nil? or not data[:post_mortal]))
            return
        end
        @tick += 1
        kill if @tick >= @_lifespan
        super({:post_mortal => true})
    end

    def draw()
        return if @_dead
        super()
    end

    def kill()
        throw "SplitBullet: sink cannot be nil" if @_sink.nil?
        throw "SplitBullet: sink must be an array" if not @_sink.is_a?(Array)
        throw "SplitBullet: emitter cannot be nil" if @_emitter.nil?
        throw "SplitBullet: split number must be greater than 0" if @_split_number <= 0
        throw "SplitBullet: self is not in the sink" if not @_sink.include?(self)
        if (@_depth > 0)
            offset = ((@_max_angle - @_min_angle) / 2.0) - ((@_max_angle - @_min_angle) / (@_split_number - 1) / 2.0)
            for i in 0...@_split_number
                bullet = self.clone()
                bullet.set_speed(@speed.to_f * @_split_factor)
                bullet.set_angle(@angle + @_max_angle / @_split_number * i + @_min_angle - offset)
                bullet.set_depth(@_depth - 1) if (bullet.is_a?(SplitBullet))
                bullet.set_position(self.position.clone())
                bullet.set_lifespan(@_lifespan * @_split_factor)
                bullet.spawn()
            end
        elsif (@_depth == 0)
            @_emitter.emit({:center => self.position})
        end
        super()
    end

    def set_emitter(emitter)
        @_emitter = emitter
        return self
    end

    def set_split_number(number)
        @_split_number = number
        return self
    end

    def set_depth(depth)
        @_depth = depth
        return self
    end

    def set_lifespan(limespan)
        @_lifespan = limespan
        return self
    end

    def set_split_factor(factor)
        @_split_factor = factor
        return self
    end

    def set_min_angle(angle_)
        throw "SplitBullet: min angle must be less than max angle" if angle_ >= @_max_angle
        @_min_angle = angle_
        return self
    end

    def set_max_angle(angle_)
        throw "SplitBullet: max angle must be greater than min angle" if angle_ < @_min_angle
        @_max_angle = angle_
        return self
    end
    
end