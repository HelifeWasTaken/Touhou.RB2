module GUI

    class Section < GUI::Widget

        def initialize()
            super()
            @widgets = []
        end

        def initialize_copy(other)
            self.widgets = other.widgets.map { |widget| widget.clone() }
            super(other)
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
            @widgets.each { |widget| widget.draw() }
        end
    end
end