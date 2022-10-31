module GUI

    class Panel < GUI::Section

        def draw()
            if self._tiles.size > 0
                x_tile_n = (self.size.x.to_f / self.tile_size.x).ceil
                y_tile_n = (self.size.y.to_f / self.tile_size.y).ceil
                if (x_tile_n <= 1) and (y_tile_n <= 1)
                    self._tiles[15].draw(self.position.x, self.position.y, 50000000, self.scale.x, self.scale.y)
                elsif (x_tile_n <= 1) and (y_tile_n > 1)
                    for y in 0...y_tile_n
                        if y == 0
                            self._tiles[3].draw(self.position.x, self.position.y + y * self.tile_size.y * self.scale.y, 50000000, self.scale.x, self.scale.y)
                        elsif y == y_tile_n - 1
                            self._tiles[11].draw(self.position.x, self.position.y + self.size.y * self.scale.y - self.tile_size.y * self.scale.y, 50000000, self.scale.x, self.scale.y)
                        else
                            self._tiles[7].draw(self.position.x, self.position.y + y * self.tile_size.y * self.scale.y, 50000000, self.scale.x, self.scale.y)
                        end
                    end
                elsif (y_tile_n <= 1) and (x_tile_n > 1)
                    for x in 0...x_tile_n
                        if x == 0
                            self._tiles[12].draw(self.position.x + x * self.tile_size.x * self.scale.x, self.position.y, 50000000, self.scale.x, self.scale.y)
                        elsif x == x_tile_n - 1
                            self._tiles[14].draw(self.position.x + x * self.tile_size.x * self.scale.x, self.position.y, 50000000, self.scale.x, self.scale.y)
                        else
                            self._tiles[13].draw(self.position.x + x * self.tile_size.x * self.scale.x, self.position.y, 50000000, self.scale.x, self.scale.y)
                        end
                    end
                else
                    for x in 0...x_tile_n
                        for y in 0...y_tile_n
                            if x == 0
                                if y == 0
                                    self._tiles[0].draw(self.position.x + x * self.tile_size.x * self.scale.x, self.position.y + y * self.tile_size.y * self.scale.y, 50000000, self.scale.x, self.scale.y)
                                elsif y == y_tile_n - 1
                                    self._tiles[8].draw(self.position.x + x * self.tile_size.x * self.scale.x, self.position.y + self.size.y * self.scale.y - self.tile_size.y * self.scale.y, 50000000, self.scale.x, self.scale.y)
                                else
                                    self._tiles[4].draw(self.position.x + x * self.tile_size.x * self.scale.x, self.position.y + y * self.tile_size.y * self.scale.y, 50000000, self.scale.x, self.scale.y)
                                end
                            elsif x == x_tile_n - 1
                                if y == 0
                                    self._tiles[2].draw(self.position.x + self.size.x * self.scale.x - self.tile_size.x * self.scale.x, self.position.y + y * self.tile_size.y * self.scale.y, 50000000, self.scale.x, self.scale.y)
                                elsif y == y_tile_n - 1
                                    self._tiles[10].draw(self.position.x + self.size.x * self.scale.x - self.tile_size.x * self.scale.x, self.position.y + self.size.y * self.scale.y - self.tile_size.y * self.scale.y, 50000000, self.scale.x, self.scale.y)
                                else
                                    self._tiles[6].draw(self.position.x + self.size.x * self.scale.x - self.tile_size.x * self.scale.x, self.position.y + y * self.tile_size.y * self.scale.y, 50000000, self.scale.x, self.scale.y)
                                end
                            else
                                if y == 0
                                    self._tiles[1].draw(self.position.x + x * self.tile_size.x * self.scale.x, self.position.y + y * self.tile_size.y * self.scale.y, 50000000, self.scale.x, self.scale.y)
                                elsif y == y_tile_n - 1
                                    self._tiles[9].draw(self.position.x + x * self.tile_size.x * self.scale.x, self.position.y + self.size.y * self.scale.y - self.tile_size.y * self.scale.y, 50000000, self.scale.x, self.scale.y)
                                else
                                    self._tiles[5].draw(self.position.x + x * self.tile_size.x * self.scale.x, self.position.y + y * self.tile_size.y * self.scale.y, 50000000, self.scale.x, self.scale.y)
                                end
                            end
                        end
                    end
                end
            end
            @widgets.each { |widget| widget.draw() }
        end
    end
end