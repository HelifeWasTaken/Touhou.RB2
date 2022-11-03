class Cirno < Boss

    def initialize()
        super("assets/textures/character/cirno.png", 64, 64)

        add_emitter(FlankEmitter.new().set_position(Omega::Vector2.new(0, 0)))
        add_emitter(HailstomEmitter.new().set_position(Omega::Vector2.new(0, 0)))

        add_emitter(ZoneEmitter.new())
        add_emitter(HomingEmitter.new())

        dist = DistanceBehavior.new().set_distance(100)
        homing = HomingBehavior.new()
        # WhitePellet.new().set_behavior(homing).add_behavior(dist)
        emitter = SplitEmitter.new($bullet_sink).set_speed(5).set_bullet_number(5).set_angle(135).set_split_bullet(WhitePellet.new().set_behavior(homing).add_behavior(dist))
        split = SplitBullet.new("assets/textures/bullet/blue_warp.png").set_sink($bullet_sink).set_depth(0).set_lifespan(50).set_split_number(5).set_emitter(emitter)
        add_emitter(SplitEmitter.new($bullet_sink).set_speed(5).set_bullet_number(5).set_angle(135).set_split_bullet(split))

        add_emitter(WarpEmitter.new())

        @phase = 0

        phase_0_1 = Attack.new()
        phase_0_1.set_setup do |attack, tick, entity, extra|
            entity.move_to(Omega::Vector2.new(100, 100))
            attack.upstate
        end
        phase_0_1.set_update do |attack, tick, entity, extra|
            if entity.sprite.position.is_easing?
                tick = -1
            else
                entity.move(Omega::Vector2.new(10.8, 0))
                entity.emit(2) if tick % 5 == 0
                attack.upstate if tick >= 100
            end
        end
        phase_0_1.set_recovery do |attack, tick, entity, extra|
            use_attack("phase_0_2") if tick >= 100
            attack.upstate if tick >= 100
        end
        #---
        phase_0_2 = Attack.new()
        phase_0_2.set_setup do |attack, tick, entity, extra|
            entity.move_to(Omega::Vector2.new(680, 200))
            attack.upstate
        end
        phase_0_2.set_update do |attack, tick, entity, extra|
            if entity.sprite.position.is_easing?
                tick = -1
            else
                entity.emit(2)
                entity.emit(0, {
                    :range => 10,
                    :spacing => 10,
                    :angle => 135
                })
                attack.upstate if tick >= 50
            end
        end
        phase_0_2.set_recovery do |attack, tick, entity, extra|
            use_attack("phase_0_3") if tick >= 100
            attack.upstate if tick >= 100
        end
        #---
        phase_0_3 = Attack.new()
        phase_0_3.set_setup do |attack, tick, entity, extra|
            entity.move_to(Omega::Vector2.new(700, 100))
            attack.upstate
        end
        phase_0_3.set_update do |attack, tick, entity, extra|
            if entity.sprite.position.is_easing?
                tick = -1
            else
                entity.move(Omega::Vector2.new(-10.8, 0))
                entity.emit(2) if tick % 5 == 0
                attack.upstate if tick >= 100
            end
        end
        phase_0_3.set_recovery do |attack, tick, entity, extra|
            use_attack("phase_0_4") if tick >= 100
            attack.upstate if tick >= 100
        end
        #---
        phase_0_4 = Attack.new()
        phase_0_4.set_setup do |attack, tick, entity, extra|
            entity.move_to(Omega::Vector2.new(180, 200))
            attack.upstate
        end
        phase_0_4.set_update do |attack, tick, entity, extra|
            if entity.sprite.position.is_easing?
                tick = -1
            else
                entity.emit(2)
                entity.emit(0, {
                    :range => 10,
                    :spacing => 10,
                    :angle => 45
                })
                attack.upstate if tick >= 50
            end
        end
        phase_0_4.set_recovery do |attack, tick, entity, extra|
            use_attack("phase_0_1") if tick >= 100
            attack.upstate if tick >= 100
        end
        #---
        #---
        #---
        phase_1_1 = Attack.new()
        phase_1_1.set_setup do |attack, tick, entity, extra|
            entity.move_to(Omega::Vector2.new(200, 200))
            attack.upstate
        end
        phase_1_1.set_update do |attack, tick, entity, extra|
            if entity.sprite.position.is_easing?
                tick = -1
            else
                # entity.move(Omega::Vector2.new(10.8, 0))
                entity.emit(2) if tick % 25 == 0
                entity.emit(3) if tick % 50 == 0
                attack.upstate if tick >= 100
            end
        end
        phase_1_1.set_recovery do |attack, tick, entity, extra|
            use_attack("phase_1_2") if tick >= 100
            attack.upstate if tick >= 100
        end
        #---
        phase_1_2 = Attack.new()
        phase_1_2.set_setup do |attack, tick, entity, extra|
            # entity.move_to(Omega::Vector2.new(200, 200))
            attack.upstate
        end
        phase_1_2.set_update do |attack, tick, entity, extra|
            if entity.sprite.position.is_easing?
                tick = -1
            else
                entity.move(Omega::Vector2.new(5, 0))
                entity.emit(4) if tick % 5 == 0
                # entity.emit(3) if tick % 50 == 0
                attack.upstate if tick >= 100
            end
        end
        phase_1_2.set_recovery do |attack, tick, entity, extra|
            use_attack("phase_1_3") if tick >= 100
            attack.upstate if tick >= 100
        end
        #---
        phase_1_3 = Attack.new()
        phase_1_3.set_setup do |attack, tick, entity, extra|
            entity.move_to(Omega::Vector2.new(700, 100))
            attack.upstate
        end
        phase_1_3.set_update do |attack, tick, entity, extra|
            if entity.sprite.position.is_easing?
                tick = -1
            else
                entity.move(Omega::Vector2.new(-10.8, 0))
                entity.emit(2) if tick % 5 == 0
                entity.emit(3) if tick % 10 == 0
                attack.upstate if tick >= 100
            end
        end
        phase_1_3.set_recovery do |attack, tick, entity, extra|
            use_attack("phase_1_4") if tick >= 100
            attack.upstate if tick >= 100
        end
        #---
        phase_1_4 = Attack.new()
        phase_1_4.set_setup do |attack, tick, entity, extra|
            entity.move_to(Omega::Vector2.new(780 / 2, 540))
            attack.upstate
        end
        phase_1_4.set_update do |attack, tick, entity, extra|
            if entity.sprite.position.is_easing?
                tick = -1
            else
                # entity.move(Omega::Vector2.new(-10.8, 0))
                entity.emit(1) if tick % 150 == 0
                entity.emit(2) if tick % 50 == 0
                attack.upstate if tick >= 500
            end
        end
        phase_1_4.set_recovery do |attack, tick, entity, extra|
            use_attack("phase_1_1") if tick >= 100
            attack.upstate if tick >= 100
        end
        #---
        #---
        #---
        phase_2_1 = Attack.new()
        phase_2_1.set_setup do |attack, tick, entity, extra|
            entity.move_to(Omega::Vector2.new(780 / 2, 200))
            attack.upstate
        end
        phase_2_1.set_update do |attack, tick, entity, extra|
            if entity.sprite.position.is_easing?
                tick = -1
            else
                # entity.move(Omega::Vector2.new(10.8, 0))
                entity.emit(5) if tick % 25 == 0
                # entity.emit(3) if tick % 50 == 0
                attack.upstate if tick >= 100
            end
        end
        phase_2_1.set_recovery do |attack, tick, entity, extra|
            use_attack("phase_2_2") if tick >= 100
            attack.upstate if tick >= 100
        end
        #---
        phase_2_2 = Attack.new()
        phase_2_2.set_setup do |attack, tick, entity, extra|
            # entity.move_to(Omega::Vector2.new(rand() % 300 + 300, rand() % 200 + 100))
            attack.upstate
        end
        phase_2_2.set_update do |attack, tick, entity, extra|
            if entity.sprite.position.is_easing?
                tick = -1
            else
                # entity.move(Omega::Vector2.new(10.8, 0))
                entity.move_to(Omega::Vector2.new(rand(300) + 300, rand(200) + 100)) if tick % 50 == 0
                entity.emit(5) if tick % 50 == 0
                # entity.emit(3) if tick % 50 == 0
                attack.upstate if tick >= 500
            end
        end
        phase_2_2.set_recovery do |attack, tick, entity, extra|
            use_attack("phase_2_3") if tick >= 100
            attack.upstate if tick >= 100
        end
        #---
        phase_2_3 = Attack.new()
        phase_2_3.set_setup do |attack, tick, entity, extra|
            entity.move_to(Omega::Vector2.new(780 / 2, 540))
            attack.upstate
        end
        phase_2_3.set_update do |attack, tick, entity, extra|
            if entity.sprite.position.is_easing?
                tick = -1
            else
                # entity.move(Omega::Vector2.new(10.8, 0))
                entity.move(Omega::Vector2.new(0, -5))
                # entity.emit(2) if tick % 5 == 0
                # attack.upstate if tick >= 100
                # entity.emit(5) if tick % 25 == 0
                entity.emit(2) if tick % 10 == 0
                attack.upstate if tick >= 100
            end
        end
        phase_2_3.set_recovery do |attack, tick, entity, extra|
            entity.emit(0, {
                :range => 15,
                :spacing => 5,
            })
            use_attack("phase_2_4") if tick >= 100
            attack.upstate if tick >= 100
        end
        #---
        phase_2_4 = Attack.new()
        phase_2_4.set_setup do |attack, tick, entity, extra|
            entity.move_to(Omega::Vector2.new(780 / 2, 540))
            attack.upstate
        end
        phase_2_4.set_update do |attack, tick, entity, extra|
            if entity.sprite.position.is_easing?
                tick = -1
            else
                # entity.move(Omega::Vector2.new(-10.8, 0))
                entity.emit(1) if tick % 150 == 0
                entity.emit(2) if tick % 50 == 0
                entity.emit(3) if tick % 50 == 0
                attack.upstate if tick >= 500
            end
        end
        phase_2_4.set_recovery do |attack, tick, entity, extra|
            use_attack("phase_2_1") if tick >= 100
            attack.upstate if tick >= 100
        end

        add_attack("phase_0_1", phase_0_1)
        add_attack("phase_0_2", phase_0_2)
        add_attack("phase_0_3", phase_0_3)
        add_attack("phase_0_4", phase_0_4)

        add_attack("phase_1_1", phase_1_1)
        add_attack("phase_1_2", phase_1_2)
        add_attack("phase_1_3", phase_1_3)
        add_attack("phase_1_4", phase_1_4)

        add_attack("phase_2_1", phase_2_1)
        add_attack("phase_2_2", phase_2_2)
        add_attack("phase_2_3", phase_2_3)
        add_attack("phase_2_4", phase_2_4)
        
        use_attack("phase_0_1")

        set_max_hp(300)
    end

    def update()
        return if is_dead?
        puts "Update, pahse: #{@phase}, #{@_hp}"
        upgrade if (@_hp <= 200 and @phase == 0)
        upgrade if (@_hp <= 100 and @phase == 1)
        super()
    end

    def upgrade()
        puts "UpGRADE pahse: #{@phase}, #{@_hp}"
        @phase += 1
        case @phase
        when 1
            use_attack("phase_1_1")
        when 2
            use_attack("phase_2_1")
        end
    end

    def on_collision(other)
        return if not (HitboxType::isBullet(other.type))
        return if other.type == HitboxType::ENEMY_BULLET
        hurt(1)
    end
end

class FlankEmitter < BulletEmitter

    def initialize()
        super($bullet_sink)

        @position = nil
        
        @_angle = 90
        @_range = 13
        @_spacing = 5
        
        @__start
    end

    def emit(data = {})
        return if is_emitting?
        #--- Fallthrough
        if not data[:fallthrough].nil?
            data[:fallthrough] -= 1
            if data[:fallthrough] >= 0
                super(data)
                return
            end
        end
        #---
        @tick = 0
        @_angle = if data[:angle] != nil then data[:angle] else 90 end
        @_range = if data[:range] != nil then data[:range] else 13 end
        @_spacing = if data[:spacing] != nil then data[:spacing] else 5 end
        #---
        if @_range % 2 == 0
            @__start = (@_angle + @_range / 2.0) - (@_range / 2.0 * @_spacing)
        else
            @__start = @_angle - ((@_range / 2.0).floor * @_spacing)
        end
        super(data)
    end

    def update()
        if @tick % 20 == 0
            for i in 0...@_range
                IcePellet.new().set_position(@position).set_speed(5).set_angle(@__start + i * @_spacing).spawn()
            end
        end
        if @tick % 20 == 10
            for i in 0...@_range - 1
                IcePellet.new().set_position(@position).set_speed(5).set_angle(@__start + @_spacing / 2.0 + i * @_spacing).spawn()
            end
        end
        @emitting = false if @tick >= 100
        super()
    end

    def set_position(pos)
        @position = pos
        return self
    end
end

class HailstomEmitter < BulletEmitter

    def initialize()
        super($bullet_sink)

        @position = nil
    end

    def emit(data = {})
        return if is_emitting?
        #--- Fallthrough
        if not data[:fallthrough].nil?
            data[:fallthrough] -= 1
            if data[:fallthrough] >= 0
                super(data)
                return
            end
        end
        #---
        @tick = 0
        super()
    end

    def update()
        for s in 1...10
            for i in 0...8
                dist = DistanceBehavior.new().set_distance(s * 35)
                hail = HailBehavior.new().push_extra({
                    :index => s % 2
                })
                IcePellet.new().set_position(@position).set_behavior(hail).add_behavior(dist).set_speed(5).set_angle(@tick * 15 + 90 + i * 45).spawn()
            end
        end
        @emitting = false if @tick >= 2
        super()
    end

    def set_position(pos)
        @position = pos
        return self
    end
end

class ZoneEmitter < BulletEmitter

    def initialize()
        super($bullet_sink)

        @position = nil
    end
    
    def emit(data = {})
        return if is_emitting?
        #--- Fallthrough
        if not data[:fallthrough].nil?
            data[:fallthrough] -= 1
            if data[:fallthrough] >= 0
                super(data)
                return
            end
        end
        #---
        @tick = 0
        for i in 0...36
            IceWarp.new().set_position(@position).set_speed(5).set_angle(i * 10).spawn()
        end
        super()
    end

    def update()
        @emitting = false
        super()
    end

    def set_position(pos)
        @position = pos
        return self
    end
end

class HomingEmitter < BulletEmitter

    def initialize()
        super($bullet_sink)

        @position = nil
    end
    
    def emit(data = {})
        return if is_emitting?
        #--- Fallthrough
        if not data[:fallthrough].nil?
            data[:fallthrough] -= 1
            if data[:fallthrough] >= 0
                super(data)
                return
            end
        end
        #---
        @tick = 0
        for i in 0...36
            dist = DistanceBehavior.new().set_distance(250)
            homing = HomingBehavior.new()
            WhitePellet.new().set_position(@position).set_behavior(homing).add_behavior(dist).set_speed(5).set_angle(i * 10).spawn()
        end
        super()
    end

    def update()
        @emitting = false
        super()
    end

    def set_position(pos)
        @position = pos
        return self
    end
end

class WarpEmitter < BulletEmitter

    def initialize()
        super($bullet_sink)

        @position = nil
        @angle = 110
    end
    
    def emit(data = {})
        return if is_emitting?
        #--- Fallthrough
        if not data[:fallthrough].nil?
            data[:fallthrough] -= 1
            if data[:fallthrough] >= 0
                super(data)
                return
            end
        end
        #---
        @tick = 0
        @angle = 135
        super()
    end

    def update()
        if @tick > 20
            @emitting = false
            return
        end
        if @tick % 2 == 0
            for i in 0...5
                IceWarp.new().set_position(@position).set_speed(5).set_angle(@angle - @tick * 4 - i * 10).spawn()
            end
        end
        super()
    end

    def set_position(pos)
        @position = pos
        return self
    end
end

class ChainEmitter < BulletEmitter

    def initialize()
        super($bullet_sink)

        @position = nil
        @start = nil
        @end = nil
    end
    
    def emit(data = {})
        return if is_emitting?
        #--- Fallthrough
        if not data[:fallthrough].nil?
            data[:fallthrough] -= 1
            if data[:fallthrough] >= 0
                super(data)
                return
            end
        end
        #---
        @tick = 0
        @start = @position.clone
        @start.x -= 50
        @end = @position.clone
        @end.x += 50
        @aim_pos = Omega::Vector2.new($player.x, $player.y)
        super()
    end

    def update()
        angle = Math::atan2(@aim_pos.y - @start.y, @aim_pos.x - @start.x) * 180 / Math::PI
        if @start.x >= @end.x
            @emitting = false
        end
        if @start.x % 10 == 0
            for i in 0...36
                dist = DistanceBehavior.new().set_distance((i + 1) * 16)
                null = NullBehavior.new().set_lifespan(150 - i)
                ChainPellet.new().set_position(@start).set_behavior(null).add_behavior(dist).set_speed(16).set_angle(angle).spawn()
            end
        end
        @start += Omega::Vector2.new(5, 0)
        super()
    end

    def set_position(pos)
        @position = pos
        return self
    end
end

class HomingBehavior < LinearBehavior

    def setup()
        @owner.speed = 5
        angle = Math::atan2($player.y - @owner.position.y, $player.x - @owner.position.x) * 180 / Math::PI
        @owner.set_angle(angle)
    end
end

class HailBehavior < LinearBehavior

    def initialize(owner = nil)
        super(owner)

        @_swap = false
    end

    def setup()
        @owner.speed = 1.5
        if @extra[:index] == 0
            @owner.set_angle(@owner.angle + 60)
        else
            @owner.set_angle(@owner.angle - 60)
        end
    end

    def update()
        @_swap = !@_swap if @tick % 150 == 0
        if @extra[:index] == 0
            if @_swap
                @owner.set_angle(@owner.angle - 1) if @tick % 150 < 120
            else
                @owner.set_angle(@owner.angle + 1) if @tick % 150 < 120
            end
        else
            if @_swap
                @owner.set_angle(@owner.angle + 1) if @tick % 150 < 120
            else
                @owner.set_angle(@owner.angle - 1) if @tick % 150 < 120
            end
        end
        super()
    end
end

class NullBehavior < BulletBehavior

    def initialize(owner = nil)
        super(owner)

        @_lifespan = 100
    end

    def set_lifespan(lifespan)
        @_lifespan = lifespan
        return self
    end

    def update()
        @owner.kill if @tick >= @_lifespan
        super()
    end
end

class IcePellet < Bullet

    def initialize()
        super("assets/textures/bullet/cyan_pellet.png")
        set_sink($bullet_sink)
    end
end

class WhitePellet < Bullet

    def initialize()
        super("assets/textures/bullet/white_pellet.png")
        set_sink($bullet_sink)
    end
end

class ChainPellet < WhitePellet

    def kill()
        angle = angle = Math::atan2($player.y - @position.y, $player.x - @position.x) * 180 / Math::PI
        WhitePellet.new().set_position(@position).set_speed(5).set_angle(angle).spawn()
        super()
    end
end

class WhiteIdk < Bullet

    def initialize()
        super("assets/textures/bullet/white_idk.png")
        set_sink($bullet_sink)
    end
end

class IceWarp < Bullet

    def initialize()
        super("assets/textures/bullet/blue_warp.png")
        set_sink($bullet_sink)
    end
end