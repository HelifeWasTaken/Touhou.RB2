module GUI

    class ProgressBar < GUI::Widget

        protected

        attr_accessor :_value, :_max, :_color

        public

        def initialize()
            super()
            @_value = 0
            @_max = 100

            @_color = Omega::Color::WHITE
        end

        def set_max(max_)
            @_max = max_
            return self
        end

        def set_value(value_)
            @_value = value_
            return self
        end

        def set_color(color_)
            @_color = color_
            return self
        end

        def get_value()
            return @_value
        end

        def get_max()
            return @_max
        end

        def get_color()
            return @_color
        end

        def add(value_)
            @_value = (@_value + value_).clamp(0, @_max)
            return self
        end

        def substract(value_)
            @_value = (@_value - value_).clamp(0, @_max)
            return self
        end

        def draw()
            if self._tiles.size > 0
                x_tile_n = (self.size.x.to_f / self.tile_size.x).ceil
                y_tile_n = (self.size.y.to_f / self.tile_size.y).ceil
                x_bar_tile_n = ((self.size.x.to_f / self.tile_size.x) * (@_value.to_f / @_max)).ceil
                bar_size = self.size.x * (@_value.to_f / @_max)
                for x in 0...x_bar_tile_n
                    if x == x_bar_tile_n - 1
                        self._tiles[3].draw(self.position.x + bar_size * self.scale.x - self.tile_size.x * self.scale.x, self.position.y, 50000000, self.scale.x, self.scale.y, self._color)
                    else
                        self._tiles[3].draw(self.position.x + x * self.tile_size.x * self.scale.x, self.position.y, 50000000, self.scale.x, self.scale.y, self._color)
                    end
                end
                for x in 0...x_tile_n
                    if x == 0
                        self._tiles[0].draw(self.position.x + x * self.tile_size.x * self.scale.x, self.position.y, 50000000, self.scale.x, self.scale.y)
                    elsif x == x_tile_n - 1
                        self._tiles[2].draw(self.position.x + self.size.x * self.scale.x - self.tile_size.x * self.scale.x, self.position.y, 50000000, self.scale.x, self.scale.y)
                    else
                        self._tiles[1].draw(self.position.x + x * self.tile_size.x * self.scale.x, self.position.y, 50000000, self.scale.x, self.scale.y)
                    end
                end
            end
        end
    end
end