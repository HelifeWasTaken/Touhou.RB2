module GUI

    class Section < GUI::Widget

        def initialize()
            super()
            @widgets = []
        end

        def add(*widget)
            @widgets += widget
            return self
        end

        def set_position(position_)
            super(position_)
            @widgets.each { |widget| widget.set_position(widget.get_position + @position) }
            __reload
            return self
        end

        def update()
            super()
            return if not enabled?
            for widget in @widgets
                widget.update()
            end
        end

        def draw()
            if @active == false
                return
            end
            @widgets.each { |widget| widget.draw() }
        end
    end
end