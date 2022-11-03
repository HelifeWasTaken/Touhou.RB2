require_relative "./Entity.rb"

class Boss < Entity

    def initialize(source, width = 48, height = 48)
        super(source, width, height)

        @_hitbox = Hitbox.new(0, 0, 24, 24, HitboxType::ENEMY, self)

        @emitters = []
    end

    protected

    def add_emitter(emitter)
        @emitters << emitter
    end

    public

    def update()
        $tree.insert(@_hitbox)
        @tick += 1
        for emitter in @emitters
            emitter.update if (not emitter.nil? and emitter.is_emitting?)
        end
        @_actual_attack.update if not @_actual_attack.nil?
        @sprite.position.update_easing
        @_hitbox.set_position(@sprite.position.x - @_hitbox.w / 2.0, @sprite.position.y - @_hitbox.h / 2.0)
        for emitter in @emitters
            emitter.set_position(@sprite.position.to_vector2) if not emitter.nil?
        end
    end

    def emit(index, data = {})
        @emitters[index].emit(data) if (not @emitters[index].nil? and not @emitters[index].is_emitting?)
    end

    def set_position(pos)
        @sprite.position = pos.to_vector3 if not @sprite.nil?
        @_hitbox.set_position(pos.x - @_hitbox.w / 2.0, pos.y - @_hitbox.h / 2.0)
        for emitter in @emitters
            emitter.set_position(pos) if not emitter.nil?
        end
        return self
    end

    def on_collision(other)
        return if not (HitboxType::isBullet(other.type))
        return if other.type == HitboxType::ENEMY_BULLET
        puts "Boss hit by bullet"
    end
end