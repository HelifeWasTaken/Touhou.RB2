class BossSoniaVA < Omega::SpriteSheet

    def initialize(player)
        super("assets/textures/character/cirno.png", 48, 48)
        set_scale(2)

        @player = player
    end

    def update
        self.position
    end

    def draw
        super()
    end

end