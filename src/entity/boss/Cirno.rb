class Cirno < Boss

    def initialize()
        super("assets/textures/character/cirno.png", 64, 64)

        add_emitter(FlankEmitter.new().set_position(Omega::Vector2.new(0, 0)))
        add_emitter(HailstomEmitter.new().set_position(Omega::Vector2.new(0, 0)))

        add_emitter(ZoneEmitter.new())

        @phase = 0

        central_flank = Attack.new()
        central_flank.set_setup do |attack, tick, entity, extra|
            # entity.use_emitter(0)
            entity.emit(0, {
                :range => 5
            })
            attack.upstate
        end
        central_flank.set_update do |attack, tick, entity, extra|
            attack.upstate
        end
        central_flank.set_recovery do |attack, tick, entity, extra|
            attack.upstate if tick >= 250
        end

        hailstorm = Attack.new()
        hailstorm.set_setup do |attack, tick, entity, extra|
            # entity.use_emitter(2)
            entity.set_position(entity.sprite.position)
            entity.emit(1)
            # entity.use_emitter(1)
            entity.set_position(entity.sprite.position)
            entity.emit(2)
            attack.upstate
        end
        hailstorm.set_update do |attack, tick, entity, extra|
            attack.upstate
        end
        hailstorm.set_recovery do |attack, tick, entity, extra|
            attack.upstate if tick >= 350
        end

        add_attack("central_flank", central_flank)
        add_attack("hailstorm", hailstorm)
    end

    def update()
        use_attack("hailstorm")
        super()
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
                IcePellet.new().set_sink($bullet_sink).set_position(@position).set_speed(5).set_angle(@__start + i * @_spacing).spawn()
            end
        end
        if @tick % 20 == 10
            for i in 0...@_range - 1
                IcePellet.new().set_sink($bullet_sink).set_position(@position).set_speed(5).set_angle(@__start + @_spacing / 2.0 + i * @_spacing).spawn()
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
                IcePellet.new().set_sink($bullet_sink).set_position(@position).set_behavior(hail).add_behavior(dist).set_speed(5).set_angle(@tick * 15 + 90 + i * 45).spawn()
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
            IceWarp.new().set_sink($bullet_sink).set_position(@position).set_speed(5).set_angle(i * 10).spawn()
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

class IcePellet < Bullet

    def initialize()
        super("assets/textures/bullet/cyan_pellet.png")
    end
end

class IceWarp < Bullet

    def initialize()
        super("assets/textures/bullet/blue_warp.png")
    end
end