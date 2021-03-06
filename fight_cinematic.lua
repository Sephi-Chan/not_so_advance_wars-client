local callbacks = {}

local function create(attacking_unit, target_unit, result, whoami, callback)
  return lua_fsm.create({
    initial = "fading",
    events = {
      { name = "startup",                  from = "none",      to = "fading" },
      { name = "keep_fading",              from = "fading",    to = "fading" },
      { name = "start",                    from = "fading",    to = "playing" },
      { name = "keep_playing",             from = "playing",   to = "playing" },
      { name = "update",                   from = "*",         to = "*" },
      { name = "draw",                     from = "*",         to = "*" },
      { name = "sub_animation_ended",      from = "*",         to = "*" },
      { name = "all_sub_animations_ended", from = "*",         to = "finishing" },
      { name = "keep_finishing",           from = "finishing", to = "finishing" },
      { name = "stop",                     from = "finishing", to = "finished" }
    },
    callbacks = {
      on_startup = function(self, event, from, to)
        local is_scrolling     = attacking_unit.unit_type_id ~= "artillery"
        local success, report = pcall(fight_report, whoami, attacking_unit, result.attacking_unit, target_unit, result.target_unit)

        self.result            = result
        self.callback          = callback
        self.tx                = 0
        self.ty                = 150
        self.attackers         = {}
        self.targets           = {}
        self.background        = spawn_background(self, self.tx, self.tx, animations.sprites.plain_large, is_scrolling)
        self.waiting_countdown = 0.2
        self.opacity           = 1

        self.title             = fight_title(attacking_unit, target_unit)
        self.report           = success and report or ""

        local attackers_count_to_display_before = math.ceil(5 * attacking_unit.count/10)
        local attackers_count_to_display_after  = math.ceil(5 * result.attacking_unit.count/10)
        local attackers_losses_to_display       = attackers_count_to_display_before - attackers_count_to_display_after

        for index = 1, attackers_count_to_display_before do
          local will_explode = result.attacking_unit.count == 0 or index <= attackers_losses_to_display
          local attacker     = spawn_attacking_unit(self, index, attacking_unit, will_explode)
          table.insert(self.attackers, attacker)
        end

        local targets_count_to_display_before = math.ceil(5 * target_unit.count/10)
        local targets_count_to_display_after  = math.ceil(5 * result.target_unit.count/10)
        local targets_losses_to_display       = targets_count_to_display_before - targets_count_to_display_after

        for index = 1, targets_count_to_display_before do
          local will_explode = result.target_unit.count == 0 or index <= targets_losses_to_display
          local target       = spawn_target_unit(self, index, target_unit, will_explode, attacking_unit)
          table.insert(self.targets, target)
        end
      end,


      on_update = function(self, event, from, to, delta)
        self.current = from
        if     self.current == "fading"    then self.keep_fading(delta)
        elseif self.current == "playing"   then self.keep_playing(delta)
        elseif self.current == "finishing" then self.keep_finishing(delta)
        end
      end,


      on_keep_fading = function(self, event, from, to, delta)
        self.waiting_countdown = self.waiting_countdown - delta
        if self.waiting_countdown < 0 then self.start(delta) end
        self.opacity = math.max(self.opacity - 0.8 * delta, 0)
      end,


      on_keep_playing = function(self, event, from, to, delta)
        self.background.update(delta)
        for i, attacker in ipairs(self.attackers) do attacker.update(delta) end
        for i, target in ipairs(self.targets) do target.update(delta) end
        self.opacity = math.max(self.opacity - 0.8 * delta, 0)
      end,


      on_draw = function(self, event, from, to)
        self.current = from
        self.background.draw()
        for i, attacker in ipairs(self.attackers) do attacker.draw() end
        for i, target in ipairs(self.targets) do target.draw() end

        lg.setColor(0, 0, 0, self.opacity)
        lg.rectangle("fill", 0, 0, 800, 600)

        lg.setColor(0, 0, 0)
        lg.rectangle("fill", 398, 0, 4, 600)

        lg.setColor(1, 1, 1)
        lg.printf(self.title, 20, 75, 760, "center")
        lg.printf(self.report, 20, 460, 760, "center")
      end,


      on_sub_animation_ended = function(self, event, from, to, id)
        self.current = from

        local all_sub_animations_ended = true

        if self.background.current ~= "finished" then
          all_sub_animations_ended = false
        end

        for i, attacker in ipairs(self.attackers) do
          if attacker.current ~= "finished" then
            all_sub_animations_ended = false
          end
        end

        for i, target in ipairs(self.targets) do
          if target.current ~= "finished" then
            all_sub_animations_ended = false
          end
        end

        if all_sub_animations_ended then
          self.all_sub_animations_ended()
        end
      end,


      on_all_sub_animations_ended = function(self)
        self.outro_countdown = 1.5
        self.opacity = 0
      end,


      on_keep_finishing = function(self, event, from, to, delta)
        self.outro_countdown = self.outro_countdown - delta
        if self.outro_countdown < 0 then self.stop() end
        self.opacity = math.min(self.opacity + 0.8 * delta, 1)
      end,


      on_stop = function(self)
        self.callback()
      end
    }
  })
end


function spawn_attacking_unit(cinematic, index, attacking_unit, will_explode)
  return lua_fsm.create({
    initial = "moving",
    events = {
      { name = "startup",      from = "none",    to = "moving" },
      { name = "keep_moving",  from = "moving",  to = "moving" },
      { name = "brake",        from = "moving",  to = "braking" },
      { name = "keep_braking", from = "braking", to = "braking" },
      { name = "idle",         from = "braking", to = "idling" },
      { name = "keep_idling",  from = "idling",  to = "idling" },
      { name = "fire",         from = "idling",  to = "firing" },
      { name = "keep_firing",  from = "firing",  to = "firing" },
      { name = "cease_fire",   from = "firing",  to = "idling" },

      { name = "suffer",         from = "idling",    to = "suffering" },
      { name = "keep_suffering", from = "suffering", to = "suffering" },
      { name = "explode",        from = "suffering", to = "exploding" },
      { name = "keep_exploding", from = "exploding", to = "exploding" },
      { name = "turn_to_ashes",  from = "exploding", to = "finished" },
      { name = "recover",        from = "suffering", to = "finished" },

      { name = "stop",         from = "idling",  to = "finished" },
      { name = "update",       from = "*",       to = "*" },
      { name = "draw",         from = "*",       to = "*" }
    },
    callbacks = {
      on_startup = function(self)
        self.weapon           = attacking_unit.unit_type_id == "recon" and "submachine_gun" or (0 < attacking_unit.ammo and "cannon" or "submachine_gun")
        self.moving           = attacking_unit.unit_type_id ~= "artillery"
        self.id               = "attacker_" .. index
        self.cinematic        = cinematic
        self.frame_duration   = 0.1
        self.frame_countdown  = self.frame_duration
        self.animation        = "moving"
        self.frame            = 1
        self.animations       = animations[attacking_unit.owner][attacking_unit.unit_type_id]
        self.x                = self.animations.attacking_positions[index].x
        self.y                = self.animations.attacking_positions[index].y
        self.moving_countdown = self.animations.attacking_positions[index].moving_countdown
        self.ammo             = self.weapon == "cannon" and 1 or 2
        self.will_explode     = will_explode
      end,


      on_update = function(self, event, from, to, delta)
        self.current = from
        if     self.current == "moving"    then self.keep_moving(delta)
        elseif self.current == "braking"   then self.keep_braking(delta)
        elseif self.current == "idling"    then self.keep_idling(delta)
        elseif self.current == "firing"    then self.keep_firing(delta)
        elseif self.current == "suffering" then self.keep_suffering(delta)
        elseif self.current == "exploding" then self.keep_exploding(delta)
        end
      end,


      on_keep_moving = function(self, event, from, to, delta)
        animate_unit(self, delta)
        self.x = self.moving and self.x + 50 * delta or self.x
        self.moving_countdown = self.moving_countdown - delta
        if self.moving_countdown < 0 then self.brake() end
      end,


      on_brake = function(self)
        self.x                 = math.ceil(self.x)
        self.animation         = "braking"
        self.frame             = 1
        self.braking_countdown = 0.45
      end,


      on_keep_braking = function(self, event, from, to, delta)
        animate_unit(self, delta)
        self.braking_countdown = self.braking_countdown - delta
        if self.braking_countdown < 0 then self.idle(delta) end
      end,


      on_idle = function(self)
        self.animation        = "idling"
        self.frame            = 1
        self.idling_countdown = 0.8
      end,


      on_keep_idling = function(self, event, from, to, delta)
        self.idling_countdown = self.idling_countdown - delta
        if self.idling_countdown < 0 and 0 < self.ammo then
          self.fire(delta)
        elseif self.ammo == 0 then
          self.suffer(delta)
        end
      end,


      on_fire = function(self)
        self.animation        = self.weapon == "cannon" and "cannoning" or "firing"
        self.frame            = 1
        self.firing_countdown = 1

        sound_box.play_sound(self.weapon, 0.4)
      end,


      on_keep_firing = function(self, event, from, to, delta)
        animate_unit(self, delta)
        self.firing_countdown = self.firing_countdown - delta
        if self.firing_countdown < 0 then self.cease_fire(delta) end
      end,


      on_cease_fire = function(self)
        self.animation        = "idling"
        self.frame            = 1
        self.ammo             = self.ammo - 1
        self.idling_countdown = 0.5
      end,


      on_suffer = function(self, event, from, to, delta)
        self.suffering_countdown = 1
        self.flash_countdown     = 0
        self.delay_between_flashes = function() return (math.random() + 0.8) end
        self.flashing_duration   = 0.02
        self.flashing_countdown  = self.flashing_duration
        self.flashing            = false
      end,


      on_keep_suffering = function(self, event, from, to, delta)
        self.suffering_countdown = self.suffering_countdown - delta
        if self.suffering_countdown < 0 then
          if self.will_explode then self.explode(delta)
          else self.recover(delta) end
        end

        self.flash_countdown = self.flash_countdown - delta
        if self.flash_countdown < 0 then
          self.flashing = true
          self.x = self.x - math.random(50, 100) * delta
        end

        if self.flashing then
          self.flashing_countdown = self.flashing_countdown - delta
          if self.flashing_countdown < 0 then
            self.flashing = false
            self.flashing_countdown = self.flashing_duration
            self.flash_countdown = self.delay_between_flashes()
          end
        end
      end,


      on_explode = function(self, event, from, to, delta)
        self.flashing = false
        self.exploded = true
        self.exploding = true
        self.explosion_frame = 1
        self.explosion_frame_duration = 0.1
        self.explosion_frame_countdown = self.explosion_frame_duration
      end,


      on_keep_exploding = function(self, event, from, to, delta)
        self.explosion_frame_countdown = self.explosion_frame_countdown - delta

        if self.explosion_frame_countdown < 0 then
          if self.explosion_frame < #animations.explosion then
            self.explosion_frame = self.explosion_frame + 1
            self.explosion_frame_countdown = self.explosion_frame_duration

          else
            self.exploding = false
            self.turn_to_ashes()
          end
        end
      end,


      on_turn_to_ashes = function(self, event, from, to)
        self.flashing = false
        self.cinematic.sub_animation_ended(self.id)
      end,


      on_recover = function(self, event, from, to, delta)
        self.flashing = false
        self.cinematic.sub_animation_ended(self.id)
      end,


      on_stop = function(self)
        self.flashing = false
        self.cinematic.sub_animation_ended(self.id)
      end,


      on_draw = function(self, event, from, to)
        self.current = from

        if not self.exploded then
          local quad = self.animations[self.animation][self.frame]
          if quad then
            lg.setColor(1, 1, 1)
            lg.draw(self.animations.sprite, quad, self.x, self.y, 0, 2, 2)
          else
            -- FIXME: Bug noticed with artillery when going upright.
            print("FAIL: No quad for", tostring(self.id), tostring(self.animation), tostring(self.frame))
          end
        end

        if self.exploding then
          local quad = animations.explosion[self.explosion_frame]
          lg.draw(animations.sprites.explosion, quad, self.x, self.y, 0, 2, 2)
        end

        if self.flashing then
          lg.setColor(1, 1, 1)
          lg.rectangle("fill", 0, 100, 400, 336)
        end
      end
    }
  })
end


function spawn_target_unit(cinematic, index, target_unit, is_destroyed, attacking_unit)
  return lua_fsm.create({
    initial = "moving",
    events = {
      { name = "startup",         from = "none",       to = "idling" },
      { name = "keep_idling",     from = "idling",     to = "idling" },
      { name = "suffer",          from = "idling",     to = "suffering" },
      { name = "keep_suffering",  from = "suffering",  to = "suffering" },
      { name = "explode",         from = "suffering",  to = "exploding" },
      { name = "keep_exploding",  from = "exploding",  to = "exploding" },
      { name = "turn_to_ashes",   from = "exploding",  to = "finished" },
      { name = "recover",         from = "suffering",  to = "finished" },
      { name = "update" ,         from = "*",          to = "*" },
      { name = "draw",            from = "*",          to = "*" }
    },
    callbacks = {
      on_startup = function(self)
        self.id               = "target_" .. index
        self.cinematic        = cinematic
        self.is_destroyed     = is_destroyed
        self.frame_duration   = 0.1
        self.frame_countdown  = self.frame_duration
        self.animations       = animations[target_unit.owner][target_unit.unit_type_id]
        self.x                = self.animations.target_positions[index].x
        self.y                = self.animations.target_positions[index].y
        self.moving_countdown = self.animations.target_positions[index].moving_countdown
        self.weapon           = target_unit.unit_type_id == "recon" and "submachine_gun" or (0 < target_unit.ammo and "cannon" or "submachine_gun")
        self.animation        = "idling"
        self.will_retaliate   = target_unit.unit_type_id ~= "artillery" and attacking_unit.unit_type_id ~= "artillery"
        self.frame            = 1
        self.idling_countdown = 2.2
        self.exploded         = false
      end,


      on_keep_idling = function(self, event, from, to, delta)
        self.idling_countdown = self.idling_countdown - delta
        if self.idling_countdown < 0 then self.suffer(delta) end
      end,


      on_suffer = function(self, event, from, to, delta)
        self.suffering_countdown = 3
        self.animation           = self.will_retaliate and "firing" or "idling"
        self.flash_countdown     = 0
        self.delay_between_flashes = function() return (math.random() + 0.8) end
        self.flashing_duration   = 0.02
        self.flashing_countdown  = self.flashing_duration
        self.flashing            = false
        if self.will_retaliate then sound_box.play_sound("submachine_gun", 0.4) end
      end,


      on_keep_suffering = function(self, event, from, to, delta)
        animate_unit(self, delta)
        self.suffering_countdown = self.suffering_countdown - delta
        if self.suffering_countdown < 0 then
          if self.is_destroyed then self.explode(delta)
          else self.recover(delta) end
        end

        self.flash_countdown = self.flash_countdown - delta
        if self.flash_countdown < 0 then
          self.flashing = true
          self.x = self.x + math.random(50, 100) * delta
        end

        if self.flashing then
          self.flashing_countdown = self.flashing_countdown - delta
          if self.flashing_countdown < 0 then
            self.flashing = false
            self.flashing_countdown = self.flashing_duration
            self.flash_countdown = self.delay_between_flashes()
          end
        end
      end,


      on_explode = function(self, event, from, to, delta)
        self.animation = "idling"
        self.frame = 1
        self.flashing = false
        self.exploded = true
        self.exploding = true
        self.explosion_frame = 1
        self.explosion_frame_duration = 0.1
        self.explosion_frame_countdown = self.explosion_frame_duration
      end,


      on_keep_exploding = function(self, event, from, to, delta)
        self.explosion_frame_countdown = self.explosion_frame_countdown - delta

        if self.explosion_frame_countdown < 0 then
          if self.explosion_frame < #animations.explosion then
            self.explosion_frame = self.explosion_frame + 1
            self.explosion_frame_countdown = self.explosion_frame_duration

          else
            self.exploding = false
            self.turn_to_ashes()
          end
        end
      end,


      on_turn_to_ashes = function(self, event, from, to)
        self.flashing = false
        self.cinematic.sub_animation_ended(self.id)
      end,


      on_recover = function(self, event, from, to, delta)
        self.animation = "idling"
        self.frame = 1
        self.flashing = false
        self.cinematic.sub_animation_ended(self.id)
      end,


      on_update = function(self, event, from, to, delta)
        self.current = from

        if     self.current == "idling"    then self.keep_idling(delta)
        elseif self.current == "suffering" then self.keep_suffering(delta)
        elseif self.current == "exploding" then self.keep_exploding(delta)
        end
      end,


      on_draw = function(self, event, from, to)
        self.current = from

        if not self.exploded then
          lg.setColor(1, 1, 1)
          lg.draw(self.animations.sprite, self.animations[self.animation][self.frame], self.x, self.y, 0, -2, 2)
        end

        if self.exploding then
          local quad = animations.explosion[self.explosion_frame]
          lg.draw(animations.sprites.explosion, quad, self.x - 120, self.y, 0, 2, 2)
        end

        if self.flashing then
          lg.setColor(1, 1, 1)
          lg.rectangle("fill", 400, 100, 400, 336)
        end
      end
    }
  })
end


function animate_unit(fsm, delta)
  fsm.frame_countdown = fsm.frame_countdown - delta
  if fsm.frame_countdown < 0 then
    fsm.frame_countdown = 0
    fsm.frame           = fsm.frame + 1
    fsm.frame_countdown = fsm.frame_duration
    if fsm.frame > #fsm.animations[fsm.animation] then
      fsm.frame = 1
    end
  end
end


function fight_title(attacking_unit, target_unit)
  local attacker_grammar = attacking_unit.count == 1 and "singular" or "plural"
  local attacker_name    = unit_types[attacking_unit.unit_type_id].fight_title[attacker_grammar]
  local attacker_title   = attacking_unit.count .. " " .. attacker_name

  local target_grammar = target_unit.count == 1 and "singular" or "plural"
  local target_name    = unit_types[target_unit.unit_type_id].fight_title[target_grammar]
  local target_title   = target_unit.count .. " " .. target_name

  return attacker_title .. " VS " .. target_title
end


function fight_report(whoami, attacking_unit_before, attacking_unit_after, target_unit_before, target_unit_after)
  local attackers_report = nil
  local targets_report   = nil
  local attacker_names   = unit_types[attacking_unit_after.unit_type_id].fight_title
  local attacker_losses  = attacking_unit_before.count - attacking_unit_after.count
  local target_names     = unit_types[target_unit_after.unit_type_id].fight_title
  local target_losses    = target_unit_before.count - target_unit_after.count

  -- I'm the attacker commenting about our remaining units.
  if attacking_unit_after.owner == whoami then
    if attacking_unit_before.count == attacking_unit_after.count and attacking_unit_before.count == 1 then
      attackers_report = "Quelle chance ! Notre dernier " .. attacker_names.singular .. " est toujours debout !"
    elseif attacking_unit_before.count == attacking_unit_after.count then
      attackers_report = "Hourra ! Nos " .. attacker_names.plural .. " sont tous intacts !"
    elseif attacking_unit_after.count == 0 and attacking_unit_before.count == 1 then
      attackers_report = "Notre dernier " .. attacker_names.singular .. " a finalement été détruit..."
    elseif attacking_unit_after.count == 0 then
      attackers_report = "Malheur ! Nous avons perdu tous nos " .. attacker_names.plural .. " dans cet assault..."
    else
      local name = attacker_names[attacker_losses == 1 and "singular" or "plural"]
      attackers_report = "Nous avons perdu " .. attacker_losses .. " " .. name .. " dans cet assault..."
    end

  -- I'm the defender commenting about attacker's remaining units.
  else
    if attacking_unit_before.count == attacking_unit_after.count and attacking_unit_before.count == 1 then
      attackers_report = "Malheur ! Le dernier " .. attacker_names.singular .. " ennemi est toujours intact !"
    elseif attacking_unit_before.count == attacking_unit_after.count then
      attackers_report = "Malheur ! Les " .. attacker_names.plural .. " ennemis sont intacts !"
    elseif attacking_unit_after.count == 0 and attacking_unit_before.count == 1 then
      attackers_report = "Victoire ! L'ennemi a perdu son dernier " .. attacker_names.singular .. " dans cet assault !"
    elseif attacking_unit_after.count == 0 then
      attackers_report = "Victoire ! L'ennemi a perdu tous ses " .. attacker_names.plural .. " dans cet assault !"
    else
      local name = attacker_names[attacker_losses == 1 and "singular" or "plural"]
      attackers_report = "Nous avons détruit " .. attacker_losses .. " " .. name .. " ennemis."
    end
  end


  -- I'm the attacker commenting about target's remaining units.
  if attacking_unit_after.owner == whoami then
    if target_unit_before.count == target_unit_after.count and target_unit_before.count == 1 then
      targets_report = "Malheur ! Leur dernier " .. target_names.singular .. " est intact ! Qu'il est coriace !"
    elseif target_unit_before.count == target_unit_after.count then
      targets_report = "Malheur ! Tous leurs " .. target_names.plural .. " ont résisté à notre assaut !"
    elseif target_unit_after.count == 0 and target_unit_before.count == 1 then
      targets_report = "Le dernier " .. target_names.singular .. " a enfin été éliminé !."
    elseif target_unit_after.count == 0 then
      targets_report = "Hourra ! Nous avons éliminé tous les " .. target_names.plural .. " !"
    else
      local name = target_names[target_losses == 1 and "singular" or "plural"]
      targets_report = "Nous avons éliminé " .. target_losses .. " " .. name .. " au cours de l'assault !"
    end

  -- I'm the defender commenting about our remaining units.
  else
    if target_unit_before.count == target_unit_after.count and target_unit_before.count == 1 then
      targets_report = "Ouf ! Notre dernier " .. target_names.singular .. " a tenu bon !"
    elseif target_unit_before.count == target_unit_after.count then
      targets_report = "Hourra ! Tous nos " .. target_names.plural .. " sont intacts !"
    elseif target_unit_after.count == 0 and target_unit_before.count == 1 then
      targets_report = "Diantre ! L'ennemi a abattu notre dernier " .. target_names.singular .. "..."
    elseif target_unit_after.count == 0 then
      targets_report = "Malheur ! L'ennemi a éliminé tous nos " .. target_names.plural .. " !"
    else
      local name = target_names[target_losses == 1 and "singular" or "plural"]
      targets_report = "L'ennemi a réduit " .. target_losses .. " " .. name .. " en poussières dans son assault..."
    end
  end

  return attackers_report .. "\n" .. targets_report
end


function spawn_background(cinematic, x, y, sprite, is_scrolling)
  return lua_fsm.create({
    initial = "scrolling",
    events = {
      { name = "startup",        from = "none",      to = "scrolling" },
      { name = "keep_scrolling", from = "scrolling", to = "scrolling" },
      { name = "stop",           from = "scrolling", to = "finished" },
      { name = "update",         from = "*",         to = "*" },
      { name = "draw",           from = "*",         to = "*" }
    },
    callbacks = {
      on_startup = function(self)
        self.cinematic           = cinematic
        self.sprite              = sprite
        self.x                   = x
        self.y                   = y
        self.scrolling_countdown = 1
      end,


      on_update = function(self, event, from, to, delta)
        self.current = from
        if self.current == "scrolling" then self.keep_scrolling(delta) end
      end,


      on_keep_scrolling = function(self, event, from, to, delta)
        self.x = is_scrolling and self.x - 100 * delta or self.x
        self.scrolling_countdown = self.scrolling_countdown - delta
        if self.scrolling_countdown < 0 then self.stop() end
      end,


      on_stop = function(self, event, from, to)
        self.cinematic.sub_animation_ended("background")
      end,


      on_draw = function(self, event, from, to)
        self.current = from
        lg.setColor(1, 1, 1)
        lg.draw(self.sprite, self.x, self.y + 100, 0, 2, 2)
        lg.draw(self.sprite, 400, 100, 0, 2, 2)
      end,
    }
  })
end


function callbacks.update(fsm, delta)
  fsm.update(delta)
end


function callbacks.draw(fsm)
  fsm.draw()
end


function callbacks.event_received(fsm, event)
end


function callbacks.mousemoved(fsm, x, y)
end


function callbacks.mousepressed(fsm, x, y, button)
end


function callbacks.keypressed(fsm, key)
  if key == "escape" then
    love.event.quit()
  end
end


return { callbacks = callbacks, create = create }
