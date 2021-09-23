# frozen_string_literal: true

module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module LevelUp
      extend Discordrb::EventContainer

      message(content: /^!exp$/) do |event|
        event.message.delete

        settings = Character::Check.all(event)
        next if settings == false

        charsheet = Database::Character.find_sheet(event.user.id, event.server.id)
        next if charsheet.nil?

        msg = 'Tape `!exp 555` en remplaçant `555` par la valeur que tu as reçue **SANS** modificateur.'

        embed = Character::Embed.char_message(charsheet, msg)

        event.channel.send_message('', false, embed)
      end

      message(content: /^!exp\s*\d*/) do |event|
        settings = Character::Check.all(event)
        next if settings == false

        charsheet = Database::Character.find_sheet(event.user.id, event.server.id)
        next if charsheet.nil?

        @exp = event.content.sub(/^!exp\s*/, '').to_i
        msg = "Valeur d'expérience invalide."

        if @exp.zero?
          event.message.delete

          embed = Character::Embed.char_message(charsheet, msg)

          event.channel.send_message('', false, embed)
          next
        end

        mod_exp = charsheet.mod_att?(10)
        mod_exp = charsheet.mod_att?(5) if mod_exp.zero?

        @mod_exp = mod_exp.zero? ? 0 : @exp * mod_exp / 100

        @old_xp = charsheet.exp

        @new_xp = @old_xp + @exp + @mod_exp

        msg = "**Expérience** gagnée : #{@exp}"
        msg += " + #{@mod_exp} (#{mod_exp}%)" unless mod_exp.zero?
        msg += "\n\n#{@old_xp}  :arrow_right:  #{@new_xp}\n\n"

        charsheet.update(exp: @new_xp)

        if @new_xp >= charsheet.next_lvl['XP'].to_i
          new_lvl = charsheet.level + 1
          msg += "Tu passes niveau #{new_lvl} !\n\n"

          regex_dv = /^(?<number>\d*)d(?<die>\d*)\+*(?<mod>\d*)$/i
          match_old_dv = charsheet.actual_lvl['DV'].match(regex_dv)
          match_new_dv = charsheet.next_lvl['DV'].match(regex_dv)

          if match_new_dv['mod'].empty?
            dice = match_new_dv['number'].to_i - match_old_dv['number'].to_i
            die = match_new_dv['die'].to_i

            pv = []
            dice.times do
              pv << rand(1..die)
            end

            @new_pvmax = pv.sum + charsheet.const_mod
            @pvmax = charsheet.pv_max + @new_pvmax

            msg += "Tu **gagnes #{dice}d#{die} dés de vie** supplémentaire.\n\n"
            msg += "**PV Max - Jet de dés !**\n\n"
            msg += ":heart: DV : #{dice}d#{die}\n\n"
            msg += ":game_die: Jet de dés : #{pv.join(', ')}\n\n"
            msg += ':ox: Modificateur de CONstitution : '
            msg += '+' if charsheet.const_mod.positive? || charsheet.const_mod.zero?
            msg += charsheet.const_mod.to_s
            msg += "\n\n:diamond_shape_with_a_dot_inside: Résultat : #{@new_pvmax}\n\n"
            msg += "Tes **nouveaux** points de vie maximum s'élèvent à..... **#{@pvmax}** !\n"

          else
            pv_mod = match_new_dv['mod'].to_i
            @pvmax = charsheet.pv_max + pv_mod

            msg += "Tu gagnes #{pv_mod} point(s) de vie maximum."
          end
          charsheet.update(level: new_lvl, pv_max: @pvmax)
        end

        charsheet.update_message!

        event.message.delete

        embed = Character::Embed.char_message(charsheet, msg)

        event.channel.send_message('', false, embed)
      end
    end
  end
end
