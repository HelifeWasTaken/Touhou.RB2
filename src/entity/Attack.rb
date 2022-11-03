class Attack

    NONE = -1
    SETUP = 0
    UPDATE = 1
    RECOVERY = 2

    attr_accessor :_state

    def initialize()
        @_entity = nil

        @_setup = nil
        @_update = nil
        @_recovery = nil

        @_tick = 0

        @_state = NONE

        @_extra = nil
    end

    def bind_entity(entity)
        @_entity = entity
        return self
    end

    def set_setup(&action)
        @_setup = action
        return self
    end

    def set_update(&action)
        @_update = action
        return self
    end

    def set_recovery(&action)
        @_recovery = action
        return self
    end

    def use(extra_data = {})
        if @_state == NONE
            @_state = SETUP
            @_tick = 0
            @_extra = extra_data
        end
    end

    def update()
        @_tick += 1
        case @_state
        when SETUP
            on_setup()
        when UPDATE
            on_update()
        when RECOVERY
            on_recovery()
        end
    end

    def upstate(reset_tick = true)
        @_state += 1
        @_state = NONE if @_state == 3
        @_tick = -1 if reset_tick
    end

    def downstate(reset_tick = true)
        @_state -= 1
        @_state = NONE if @_state < NONE
        @_tick = -1 if reset_tick
    end

    protected

    def on_setup()
        @_setup.call(self, @_tick, @_entity, @_extra) if @_setup != nil
    end

    def on_update()
        @_update.call(self, @_tick, @_entity, @_extra) if @_update != nil
    end

    def on_recovery()
        @_recovery.call(self, @_tick, @_entity, @_extra) if @_recovery != nil
    end
end

class ChargingAttack < Attack

    CHARGING = 0

    def initialize()
        super()

        @_charging = nil
        @_charged = false
        @_releasing = false
    end

    def set_setup(&action)
        @_charging = action
        @_setup = action
        return self
    end

    def set_charging(&action)
        @_charging = action
        @_setup = action
        return self
    end

    def set_charged()
        @_charged = true
        return self
    end

    def update()
        @_tick += 1
        if @_state == CHARGING
            on_charging()
            if @_charged
                upstate()
            else
                downstate(false)
            end
        else
            case @_state
            when UPDATE
                @_releasing = true
                on_update()
            when RECOVERY
                on_recovery()
            end
            if @_state == NONE
                @_charged = false
                @_releasing = false
            end
        end
    end

    def use() # only for compatibility
        charge()
    end

    def charge() # call before update()
        @_state = CHARGING if not @_releasing
    end

    protected

    def on_charging()
        @_charging.call(self, @_tick, @_entity) if @_charging != nil
    end
end