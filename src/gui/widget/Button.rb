module GUI

    class Button < GUI::Widget

        protected

        attr_accessor :widgets, :_shift

        public
    
        def initialize()
            super()
            @widgets = []

            @_shift = 0

            on_idle do
                @_shift = 0
            end

            on_hover do
                @_shift = 4
            end

            on_pressed do
                @_shift = 32
            end
        end

        def initialize_copy(other)
            self.widgets = other.widgets.map { |widget| widget.clone() }
            super(other)
        end

        def add(*widget)
            self.widgets += widget
            return self
        end

        def set_position(position_)
            super(position_)
            self.widgets.each { |widget| widget.set_position(widget.get_position + self.position) }
            __reload
            return self
        end

        def update()
            super()
            return if not enabled?
            self.widgets.each { |widget| widget.update() }
        end

        def disable()
            super()
            self._shift = 36
            self.widgets.each { |widget| widget.disable() }
        end

        def draw()
            if self._tiles.size > 0
                x_tile_n = (self.size.x.to_f / self.tile_size.x).ceil
                y_tile_n = (self.size.y.to_f / self.tile_size.y).ceil
                if (x_tile_n <= 1) and (y_tile_n <= 1)
                    self._tiles[27 + self._shift].draw(self.position.x, self.position.y, 50000000, self.scale.x, self.scale.y)
                elsif (x_tile_n <= 1) and (y_tile_n > 1)
                    for y in 0...y_tile_n
                        if y == 0
                            self._tiles[3 + self._shift].draw(self.position.x, self.position.y + y * self.tile_size.y * self.scale.y, 50000000, self.scale.x, self.scale.y)
                        elsif y == y_tile_n - 1
                            self._tiles[19 + self._shift].draw(self.position.x, self.position.y + self.size.y * self.scale.y - self.tile_size.y * self.scale.y, 50000000, self.scale.x, self.scale.y)
                        else
                            self._tiles[11 + self._shift].draw(self.position.x, self.position.y + y * self.tile_size.y * self.scale.y, 50000000, self.scale.x, self.scale.y)
                        end
                    end
                elsif (y_tile_n <= 1) and (x_tile_n > 1)
                    for x in 0...x_tile_n
                        if x == 0
                            self._tiles[24 + self._shift].draw(self.position.x + x * self.tile_size.x * self.scale.x, self.position.y, 50000000, self.scale.x, self.scale.y)
                        elsif x == x_tile_n - 1
                            self._tiles[26 + self._shift].draw(self.position.x + x * self.tile_size.x * self.scale.x, self.position.y, 50000000, self.scale.x, self.scale.y)
                        else
                            self._tiles[25 + self._shift].draw(self.position.x + x * self.tile_size.x * self.scale.x, self.position.y, 50000000, self.scale.x, self.scale.y)
                        end
                    end
                else
                    for x in 0...x_tile_n
                        for y in 0...y_tile_n
                            if x == 0
                                if y == 0
                                    self._tiles[0 + self._shift].draw(self.position.x + x * self.tile_size.x * self.scale.x, self.position.y + y * self.tile_size.y * self.scale.y, 50000000, self.scale.x, self.scale.y)
                                elsif y == y_tile_n - 1
                                    self._tiles[16 + self._shift].draw(self.position.x + x * self.tile_size.x * self.scale.x, self.position.y + self.size.y * self.scale.y - self.tile_size.y * self.scale.y, 50000000, self.scale.x, self.scale.y)
                                else
                                    self._tiles[8 + self._shift].draw(self.position.x + x * self.tile_size.x * self.scale.x, self.position.y + y * self.tile_size.y * self.scale.y, 50000000, self.scale.x, self.scale.y)
                                end
                            elsif x == x_tile_n - 1
                                if y == 0
                                    self._tiles[2 + self._shift].draw(self.position.x + self.size.x * self.scale.x - self.tile_size.x * self.scale.x, self.position.y + y * self.tile_size.y * self.scale.y, 50000000, self.scale.x, self.scale.y)
                                elsif y == y_tile_n - 1
                                    self._tiles[18 + self._shift].draw(self.position.x + self.size.x * self.scale.x - self.tile_size.x * self.scale.x, self.position.y + self.size.y * self.scale.y - self.tile_size.y * self.scale.y, 50000000, self.scale.x, self.scale.y)
                                else
                                    self._tiles[10 + self._shift].draw(self.position.x + self.size.x * self.scale.x - self.tile_size.x * self.scale.x, self.position.y + y * self.tile_size.y * self.scale.y, 50000000, self.scale.x, self.scale.y)
                                end
                            else
                                if y == 0
                                    self._tiles[1 + self._shift].draw(self.position.x + x * self.tile_size.x * self.scale.x, self.position.y + y * self.tile_size.y * self.scale.y, 50000000, self.scale.x, self.scale.y)
                                elsif y == y_tile_n - 1
                                    self._tiles[17 + self._shift].draw(self.position.x + x * self.tile_size.x * self.scale.x, self.position.y + self.size.y * self.scale.y - self.tile_size.y * self.scale.y, 50000000, self.scale.x, self.scale.y)
                                else
                                    self._tiles[9 + self._shift].draw(self.position.x + x * self.tile_size.x * self.scale.x, self.position.y + y * self.tile_size.y * self.scale.y, 50000000, self.scale.x, self.scale.y)
                                end
                            end
                        end
                    end
                end
            end
            self.widgets.each { |widget| widget.draw() }
        end
    end
end