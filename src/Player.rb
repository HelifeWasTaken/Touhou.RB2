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
        @sprite = Omega::SpriteSheet.new("AAAAAA");
        @controller = controller

        @_emitter
    end

    def update()

    end

    def draw()

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