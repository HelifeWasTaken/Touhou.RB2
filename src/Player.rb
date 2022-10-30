PLAYER_COLLISION_TYPE = 1

class Player < CollidableEntity

    def initialize(sprite, controller)
        super(self, sprite.position.x, sprite.position.y,
                sprite.width, sprite.height, PLAYER_COLLISION_TYPE)

        @sprite = sprite
        @controller = controller

        @hp = 100
        @max_hp = 100

        @bullet_emitter = []
        @hurt_timer = 0
    end

    def add_bullet_emitter(emitter)
        @bullet_emitter.push(emitter)
    end

    def update
        @sprite.update

        update_collider(@sprite.position.x, @sprite.position.y,
                        @sprite.width, @sprite.height)

        if controller.just_pressed(Button.A)
            @bullet_emitter.each do |emitter|
                emitter.update(self)
            end
        end

        if controller.get_axis(Button::XY)
            self.position += controller.get_axis(Button::XY) * 5
        end

        @hurt_timer = Omega.clamp(@hurt_timer - 1, 0, 100)
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
            @hurt_timer = 100
        end
    end

    def is_alive?
        return @hp > 0
    end

    def on_collision(other)
        #if other.type == ENEMY_COLLISION_TYPE
        #    hurt(10)
        #end
    end

end

class PlayerManager

    def initialize
        @players = []
    end

    def add_player(player)
        @players.push(player)
    end

    def get_player(index)
        @players[index]
    end

    def can_be_hurt?(index)
        get_player(index).can_be_hurt?
    end

    def hurt(index, damage)
        get_player(index).hurt(damage)
    end

    def is_alive?(index)
        get_player(index).is_alive?
    end

    def update
        @players.each do |player|
            player.update
        end
    end

    def draw
        @players.each do |player|
            player.draw
        end
    end

end