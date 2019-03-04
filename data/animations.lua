lg.setDefaultFilter("nearest", "nearest")


local sprites = {
  red_recon       = lg.newImage("assets/red_recon.png"),
  red_tank        = lg.newImage("assets/red_tank.png"),
  red_medium_tank = lg.newImage("assets/red_medium_tank.png"),
  red_artillery   = lg.newImage("assets/red_artillery.png"),
  map_red_medium_tank = lg.newImage("assets/map_red_medium_tank.png"),

  blue_recon       = lg.newImage("assets/blue_recon.png"),
  blue_tank        = lg.newImage("assets/blue_tank.png"),
  blue_medium_tank = lg.newImage("assets/blue_medium_tank.png"),

  plain_large = lg.newImage("assets/plain_large.png"),

  characters = lg.newImage("assets/characters.png")
}

local animations = {
  sprites = sprites,

  player_1 = {
    cover = lg.newQuad(0, 72, 128, 160, sprites.characters:getDimensions()),

    portrait = {
      lg.newQuad(  0, 0, 35, 35, sprites.characters:getDimensions()),
      lg.newQuad( 36, 0, 35, 35, sprites.characters:getDimensions()),
      lg.newQuad( 72, 0, 35, 35, sprites.characters:getDimensions()),
      lg.newQuad(108, 0, 35, 35, sprites.characters:getDimensions()),
    },

    recon = {
      sprite = sprites.red_recon,
      map_sprite = sprites.map_red_recon,
      attacking_positions = {
        { x = -10, y = 160, moving_countdown = 0.8 },
        { x =  70, y = 200, moving_countdown = 1.1 },
        { x = -30, y = 225, moving_countdown = 0.3 },
        { x =  50, y = 260, moving_countdown = 1.1 },
        { x = -20, y = 300, moving_countdown = 1.3 }
      },
      target_positions = {
        { x = 750, y = 160, moving_countdown = 0.8 },
        { x = 700, y = 200, moving_countdown = 1.1 },
        { x = 650, y = 225, moving_countdown = 0.3 },
        { x = 790, y = 260, moving_countdown = 1.1 },
        { x = 690, y = 300, moving_countdown = 1.3 }
      },
      moving = {
        lg.newQuad(  0, 0, 64, 64, sprites.red_recon:getDimensions()),
        lg.newQuad( 64, 0, 64, 64, sprites.red_recon:getDimensions()),
        lg.newQuad(128, 0, 64, 64, sprites.red_recon:getDimensions()),
        lg.newQuad(192, 0, 64, 64, sprites.red_recon:getDimensions()),
        lg.newQuad(256, 0, 64, 64, sprites.red_recon:getDimensions()),
        lg.newQuad(320, 0, 64, 64, sprites.red_recon:getDimensions())
      },
      braking = {
        lg.newQuad(384, 0, 64, 64, sprites.red_recon:getDimensions()),
        lg.newQuad(448, 0, 64, 64, sprites.red_recon:getDimensions()),
        lg.newQuad(512, 0, 64, 64, sprites.red_recon:getDimensions()),
        lg.newQuad(576, 0, 64, 64, sprites.red_recon:getDimensions()),
        lg.newQuad(640, 0, 64, 64, sprites.red_recon:getDimensions())
      },
      idling = {
        lg.newQuad(640, 0, 64, 64, sprites.red_recon:getDimensions())
      },
      firing = {
        lg.newQuad( 704, 0, 64, 64, sprites.red_recon:getDimensions()),
        lg.newQuad( 768, 0, 64, 64, sprites.red_recon:getDimensions()),
        lg.newQuad( 832, 0, 64, 64, sprites.red_recon:getDimensions()),
        lg.newQuad( 896, 0, 64, 64, sprites.red_recon:getDimensions()),
        lg.newQuad( 960, 0, 64, 64, sprites.red_recon:getDimensions()),
        lg.newQuad(1024, 0, 64, 64, sprites.red_recon:getDimensions())
      }
    },

    tank = {
      sprite = sprites.red_tank,
      attacking_positions = {
        { x = -10, y = 160, moving_countdown = 0.8 },
        { x =  70, y = 200, moving_countdown = 1.1 },
        { x = -30, y = 225, moving_countdown = 0.3 },
        { x =  50, y = 260, moving_countdown = 1.1 },
        { x = -20, y = 300, moving_countdown = 1.3 }
      },
      target_positions = {
        { x = 750, y = 160, moving_countdown = 0.8 },
        { x = 700, y = 200, moving_countdown = 1.1 },
        { x = 650, y = 225, moving_countdown = 0.3 },
        { x = 790, y = 260, moving_countdown = 1.1 },
        { x = 690, y = 300, moving_countdown = 1.3 }
      },
      moving = {
        lg.newQuad(  0, 0, 64, 64, sprites.red_tank:getDimensions()),
        lg.newQuad(128, 0, 64, 64, sprites.red_tank:getDimensions()),
        lg.newQuad(256, 0, 64, 64, sprites.red_tank:getDimensions()),
        lg.newQuad(384, 0, 64, 64, sprites.red_tank:getDimensions()),
        lg.newQuad(512, 0, 64, 64, sprites.red_tank:getDimensions()),
        lg.newQuad(640, 0, 64, 64, sprites.red_tank:getDimensions())
      },
      braking = {
        lg.newQuad(768,  0, 64, 64, sprites.red_tank:getDimensions()),
        lg.newQuad(896,  0, 64, 64, sprites.red_tank:getDimensions()),
        lg.newQuad(1024, 0, 64, 64, sprites.red_tank:getDimensions()),
        lg.newQuad(1152, 0, 64, 64, sprites.red_tank:getDimensions())
      },
      idling = {
        lg.newQuad(1280, 0, 64, 64, sprites.red_tank:getDimensions())
      },
      firing = {
        lg.newQuad(1280, 0, 64, 64, sprites.red_tank:getDimensions()),
        lg.newQuad(1408, 0, 64, 64, sprites.red_tank:getDimensions()),
        lg.newQuad(1536, 0, 64, 64, sprites.red_tank:getDimensions()),
        lg.newQuad(1664, 0, 64, 64, sprites.red_tank:getDimensions()),
        lg.newQuad(1792, 0, 64, 64, sprites.red_tank:getDimensions())
      },
      cannoning = {
        lg.newQuad(1920, 0, 64, 64, sprites.red_tank:getDimensions()),
        lg.newQuad(2048, 0, 64, 64, sprites.red_tank:getDimensions()),
        lg.newQuad(2176, 0, 64, 64, sprites.red_tank:getDimensions()),
        lg.newQuad(2304, 0, 64, 64, sprites.red_tank:getDimensions())
      }
    },

    medium_tank = {
      sprite = sprites.red_medium_tank,
      map_sprite = sprites.map_red_medium_tank,
      attacking_positions = {
        { x = -10, y = 160, moving_countdown = 0.8 },
        { x =  70, y = 200, moving_countdown = 1.1 },
        { x = -30, y = 225, moving_countdown = 0.3 },
        { x =  50, y = 260, moving_countdown = 1.1 },
        { x = -20, y = 300, moving_countdown = 1.3 }
      },
      target_positions = {
        { x = 750, y = 160, moving_countdown = 0.8 },
        { x = 700, y = 200, moving_countdown = 1.1 },
        { x = 650, y = 225, moving_countdown = 0.3 },
        { x = 790, y = 260, moving_countdown = 1.1 },
        { x = 690, y = 300, moving_countdown = 1.3 }
      },
      moving = {
        lg.newQuad(  0, 0, 128, 64, sprites.red_medium_tank:getDimensions()),
        lg.newQuad(128, 0, 128, 64, sprites.red_medium_tank:getDimensions()),
        lg.newQuad(256, 0, 128, 64, sprites.red_medium_tank:getDimensions()),
        lg.newQuad(384, 0, 128, 64, sprites.red_medium_tank:getDimensions()),
        lg.newQuad(512, 0, 128, 64, sprites.red_medium_tank:getDimensions()),
        lg.newQuad(640, 0, 128, 64, sprites.red_medium_tank:getDimensions())
      },
      braking = {
        lg.newQuad(768,  0, 128, 64, sprites.red_medium_tank:getDimensions()),
        lg.newQuad(896,  0, 128, 64, sprites.red_medium_tank:getDimensions()),
        lg.newQuad(1024, 0, 128, 64, sprites.red_medium_tank:getDimensions()),
        lg.newQuad(1152, 0, 128, 64, sprites.red_medium_tank:getDimensions()),
      },
      idling = {
        lg.newQuad(1280, 0, 128, 64, sprites.red_medium_tank:getDimensions())
      },
      firing = {
        lg.newQuad(1280, 0, 128, 64, sprites.red_medium_tank:getDimensions()),
        lg.newQuad(1408, 0, 128, 64, sprites.red_medium_tank:getDimensions()),
        lg.newQuad(1536, 0, 128, 64, sprites.red_medium_tank:getDimensions()),
        lg.newQuad(1664, 0, 128, 64, sprites.red_medium_tank:getDimensions()),
        lg.newQuad(1792, 0, 128, 64, sprites.red_medium_tank:getDimensions()),
      },
      cannoning = {
        lg.newQuad(1920, 0, 128, 64, sprites.red_medium_tank:getDimensions()),
        lg.newQuad(2048, 0, 128, 64, sprites.red_medium_tank:getDimensions()),
        lg.newQuad(2176, 0, 128, 64, sprites.red_medium_tank:getDimensions()),
        lg.newQuad(2304, 0, 128, 64, sprites.red_medium_tank:getDimensions()),
        lg.newQuad(2432, 0, 128, 64, sprites.red_medium_tank:getDimensions()),
        lg.newQuad(2560, 0, 128, 64, sprites.red_medium_tank:getDimensions())
      },
      down = {
        lg.newQuad( 0, 0, 20, 20, sprites.map_red_medium_tank:getDimensions()),
        lg.newQuad(20, 0, 20, 20, sprites.map_red_medium_tank:getDimensions()),
        lg.newQuad(40, 0, 20, 20, sprites.map_red_medium_tank:getDimensions())
      },
      up = {
        lg.newQuad( 60, 0, 20, 20, sprites.map_red_medium_tank:getDimensions()),
        lg.newQuad( 80, 0, 20, 20, sprites.map_red_medium_tank:getDimensions()),
        lg.newQuad(100, 0, 20, 20, sprites.map_red_medium_tank:getDimensions())
      },
      left = {
        lg.newQuad(120, 0, 20, 20, sprites.map_red_medium_tank:getDimensions()),
        lg.newQuad(140, 0, 20, 20, sprites.map_red_medium_tank:getDimensions()),
        lg.newQuad(160, 0, 20, 20, sprites.map_red_medium_tank:getDimensions())
      },
      idle = {
        lg.newQuad(180, 0, 20, 20, sprites.map_red_medium_tank:getDimensions()),
        lg.newQuad(200, 0, 20, 20, sprites.map_red_medium_tank:getDimensions()),
        lg.newQuad(220, 0, 20, 20, sprites.map_red_medium_tank:getDimensions()),
        lg.newQuad(240, 0, 20, 20, sprites.map_red_medium_tank:getDimensions())
      }
    },

    artillery = {
      sprite = sprites.red_artillery,
      map_sprite = sprites.map_red_artillery,
      attacking_positions = {
        { x = -10, y = 160 - 60, moving_countdown = 0.8 },
        { x =  70, y = 200 - 60, moving_countdown = 1.1 },
        { x = -30, y = 225 - 60, moving_countdown = 0.3 },
        { x =  50, y = 260 - 60, moving_countdown = 1.1 },
        { x = -20, y = 300 - 60, moving_countdown = 1.3 }
      },
      target_positions = {
        { x = 750, y = 160 - 60, moving_countdown = 0.8 },
        { x = 700, y = 200 - 60, moving_countdown = 1.1 },
        { x = 650, y = 225 - 60, moving_countdown = 0.3 },
        { x = 790, y = 260 - 60, moving_countdown = 1.1 },
        { x = 690, y = 300 - 60, moving_countdown = 1.3 }
      },
      moving = {
        lg.newQuad(  0, 0, 128, 128, sprites.red_artillery:getDimensions()),
        lg.newQuad(128, 0, 128, 128, sprites.red_artillery:getDimensions()),
        lg.newQuad(256, 0, 128, 128, sprites.red_artillery:getDimensions()),
        lg.newQuad(384, 0, 128, 128, sprites.red_artillery:getDimensions())
      },
      idling = {
        lg.newQuad(384, 0, 128, 128, sprites.red_artillery:getDimensions())
      },
      braking = {
        lg.newQuad(384, 0, 128, 128, sprites.red_artillery:getDimensions())
      },
      cannoning = {
        lg.newQuad(512, 0, 128, 128, sprites.red_artillery:getDimensions()),
        lg.newQuad(640, 0, 128, 128, sprites.red_artillery:getDimensions()),
        lg.newQuad(768, 0, 128, 128, sprites.red_artillery:getDimensions()),
        lg.newQuad(896, 0, 128, 128, sprites.red_artillery:getDimensions())
      },
    }
  }
}

animations.player_2 = {
  cover = lg.newQuad(128, 72, 128, 160, sprites.characters:getDimensions()),

  portrait = {
    lg.newQuad(  0, 36, 35, 35, sprites.characters:getDimensions()),
    lg.newQuad( 36, 36, 35, 35, sprites.characters:getDimensions()),
    lg.newQuad( 72, 36, 35, 35, sprites.characters:getDimensions()),
    lg.newQuad(108, 36, 35, 35, sprites.characters:getDimensions()),
  },

  recon = {
    sprite              = sprites.blue_recon,
    attacking_positions = animations.player_1.recon.attacking_positions,
    target_positions    = animations.player_1.recon.target_positions,
    moving              = animations.player_1.recon.moving,
    braking             = animations.player_1.recon.braking,
    idling              = animations.player_1.recon.idling,
    firing              = animations.player_1.recon.firing
  },

  tank = {
    sprite              = sprites.blue_tank,
    attacking_positions = animations.player_1.tank.attacking_positions,
    target_positions    = animations.player_1.tank.target_positions,
    moving              = animations.player_1.tank.moving,
    braking             = animations.player_1.tank.braking,
    idling              = animations.player_1.tank.idling,
    firing              = animations.player_1.tank.firing,
    cannoning           = animations.player_1.tank.cannoning
  },

  medium_tank = {
    sprite              = sprites.blue_medium_tank,
    attacking_positions = animations.player_1.medium_tank.attacking_positions,
    target_positions    = animations.player_1.medium_tank.target_positions,
    moving              = animations.player_1.medium_tank.moving,
    braking             = animations.player_1.medium_tank.braking,
    idling              = animations.player_1.medium_tank.idling,
    firing              = animations.player_1.medium_tank.firing,
    cannoning           = animations.player_1.medium_tank.cannoning
  }
}

return animations