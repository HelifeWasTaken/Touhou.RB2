class Entity

    def initialize(source, width = 48, height = 48)
        @sprite = if not source.nil? then Omega::SpriteSheet.new(source, width, height) else nil end
        @sprite.set_origin(0.5) if not @sprite.nil?

        @_max_hp = 100
        @_hp = @_max_hp

        @_hitbox = Hitbox.new(0, 0, 0, 0)

        @_imune_frames = 0
        
        @tick = 0

        @emitter = nil

        @invicible = false

        @_actual_attack = nil
        @_attacks = {}
    end

    protected

    def set_emitter(emitter)
        @emitter = emitter
    end

    public

    def update()
        $tree.insert(@_hitbox)
        @tick += 1
        @emitter.update if (not @emitter.nil? and @emitter.is_emitting?)
        @_actual_attack.update if not @_actual_attack.nil?
    end

    def emit(data = {})
        @emitter.emit(data) if (not @emitter.nil? and not @emitter.is_emitting?)
    end

    def draw()
        @sprite.draw() if not @sprite.nil?
        if $debug_flags[:hitboxes]
            @_hitbox.draw()
            vec = if not @sprite.nil? then Omega::Vector2.new(Math::cos(Omega::to_rad(@sprite.angle)), Math::sin(Omega::to_rad(@sprite.angle))) else Omega::Vector2.new(1, 0) end
            start_p = if not @sprite.nil? then @sprite.position else Omega::Vector3.new(0, 0, 0) end
            end_p = start_p + (vec * 50).to_vector3
            Gosu::draw_line(start_p.x, start_p.y, Omega::Color.new(0xff0000ff), end_p.x, end_p.y, Omega::Color.new(0xff0000ff), 250000)
        end
    end

    def set_max_hp(max_hp)
        @_max_hp = max_hp
        @_hp = @_max_hp
        return self
    end

    def set_hitbox_size(size)
        @_hitbox.set_size(size.x, size.y)
        return self
    end

    def set_position(pos)
        @sprite.position = pos.to_vector3 if not @sprite.nil?
        @_hitbox.set_position(pos.x - @_hitbox.w / 2.0, pos.y - @_hitbox.h / 2.0)
        @emitter.set_position(@sprite.position.to_vector2) if not @emitter.nil?
        return self
    end

    def move(vec)
        return set_position(@sprite.position.to_vector2 + vec) if not @sprite.nil?
    end

    def set_invicible(value = true)
        @invicible = value
        return self
    end

    def add_attack(key, attack)
        attack.bind_entity(self)
        @_attacks[key] = attack
    end

    def use_attack(key, extra_data = {})
        @_actual_attack = @_attacks[key]
        @_actual_attack.use(extra_data)
    end

    def enable_trail()
        @sprite.set_trail(true)
        return self
    end

    def heal(amount)
        @_hp = (@_hp + amount).clamp(0, @_max_hp)
    end

    def hurt(amount)
        return if is_immune?
        @_hp = (@_hp - amount).clamp(0, @_max_hp)
        @tick = 0
    end

    def is_dead?()
        return @_hp > 0
    end

    def is_immune?()
        return ((@tick < @_imune_frames) or @invicible)
    end

    def on_collision(other)
        throw "404 not found"
    end
end