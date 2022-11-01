PLAYER_COLLISION_TYPE = 1

class Entity < CollidableEntity

    attr :sprite, :collision_type, :hp, :hurt_timer, :bullet_emitter

    def initialize(sprite, collision_type,
                    max_hp=100, hurt_frames=100,
                    bullet_emitter=[])
        super(self, sprite.position.x, sprite.position.y,
                sprite.width, sprite.height, collision_type)

        @sprite = sprite

        @max_hp = max_hp
        @hp = @max_hp

        @hurt_frames = hurt_frames
        @hurt_timer = 0

        @bullet_emitter = bullet_emitter
    end

    def add_bullet_emitter(emitter)
        @bullet_emitter.push(emitter)
    end

    def shoot
        @bullet_emitter.each do |emitter|
            emitter.shoot
        end
    end

    def update
        @sprite.update

        update_collider(@sprite.position.x, @sprite.position.y,
                        @sprite.width, @sprite.height)

        @hurt_timer = Omega.clamp(@hurt_timer - 1, 0, @hurt_frames)
    end

    def draw
        @sprite.draw
    end

    def can_be_hurt?
        return @hurt_timer == 0
    end

    def hurt(damage)
        if can_be_hurt?
            @hp -= damage
            @hurt_timer = @hurt_frames
        end
    end

    def is_alive?
        return @hp > 0
    end

    def on_collision(other)
        throw "Entity.on_collision not implemented"
    end

end

class Player

    def initialize(controller)
        @sprite = Omega::SpriteSheet.new("assets/textures/character/kek.png", 48, 48);
        @sprite.set_trail(true)
        @controller = controller

        @_emitter = PlayerEmitter.new()

        @sprite.add_animation("idle", [0, 1, 2, 3])
        @sprite.add_animation("move", [8, 9, 10, 11, 12, 13, 14, 15])

        @sprite.play_animation("idle")
        @sprite.set_origin(0.5)

        @sprite.position.z = 50000

        @hitbox = PlayerCollider.new(self, 0, 0, 12, 12)
    end

    def x()
        return @sprite.position.x
    end

    def y()
        return @sprite.position.y
    end

    def update()
        $tree.insert(@hitbox.collision)
        axis = Omega::Vector2.new(
            (Omega.pressed(Gosu::KB_D) ? 1 : 0) - (Omega.pressed(Gosu::KB_A) ? 1 : 0),
            (Omega.pressed(Gosu::KB_S) ? 1 : 0) - (Omega.pressed(Gosu::KB_W) ? 1 : 0)
        )

        if axis.x == 0
            @sprite.play_animation("idle")
        else
            if (axis.x != 0)
                @sprite.play_animation("move", false) if @sprite.get_current_animation != "move"
            end
            if axis.x > 0
                @sprite.flip.x = true
            elsif axis.x < 0
                @sprite.flip.x = false
            end
        end

        move((axis * 5).to_vector3)

        if (@sprite.position.x < 0)
            @sprite.position.x = 0
        end
        if (@sprite.position.x > 800)
            @sprite.position.x = 800
        end
        if (@sprite.position.y < 0)
            @sprite.position.y = 0
        end
        if (@sprite.position.y > 1080)
            @sprite.position.y = 1080
        end

        @_emitter.emit if Omega.pressed(Gosu::KB_SPACE) and not @_emitter.nil? and not @_emitter.is_emitting?
        @_emitter.update
    end

    def set_position(pos)
        @sprite.position = pos.to_vector3
        @_emitter.set_position(pos)
        @hitbox.update_collider_position(pos.x - @hitbox.collision.w / 2.0, pos.y - @hitbox.collision.h / 2.0)
    end

    def move(vec)
        @sprite.position += vec
        @_emitter.set_position(@sprite.position.to_vector2 + vec)
        @hitbox.update_collider_position(@sprite.position.x - @hitbox.collision.w / 2.0, @sprite.position.y - @hitbox.collision.h / 2.0)
    end

    def draw()
        @sprite.draw
        if $debug_flags[:hitboxes]
            @hitbox.draw()
            vec = Omega::Vector2.new(Math::cos(Omega::to_rad(@sprite.angle)), Math::sin(Omega::to_rad(@sprite.angle)))
            start_p = @sprite.position
            end_p = start_p + (vec * 50).to_vector3
            Gosu::draw_line(start_p.x, start_p.y, Omega::Color.new(0xff0000ff), end_p.x, end_p.y, Omega::Color.new(0xff0000ff), 250000)
        end
    end
end

class PlayerEmitter < BulletEmitter

    def initialize()
        super($bullet_sink)

        @pos = nil
        self.set_side(false)
    end

    def emit(data = {})
        super(data)
        
        @tick = 0
        Bullet.new("assets/textures/bullet/kek_bullet.png").set_bullet_side(false).set_sink($bullet_sink).set_speed(25).set_angle(-90).set_position(@pos - Omega::Vector2.new(0, 6)).spawn()
    end

    def update()
        super()
        if @tick >= 5
            @emitting = false
        end
    end

    def is_emitting?()
        return @emitting
    end

    def set_position(pos)
        @pos = pos
    end
end

# class Player < CollidableEntity

#     def initialize(sprite, controller)
#         @sprite = sprite
#         @controller = controller

#         super(@sprite, CollisionType.PLAYER)

#     end

#     def update
#         super

#         if controller.just_pressed(Button.A)
#             shoot
#         end

#         if controller.get_axis(Button::XY)
#             self.position += controller.get_axis(Button::XY) * 5
#         end
#     end

# end