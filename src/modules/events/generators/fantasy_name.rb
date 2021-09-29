# frozen_string_literal: true

module Bot
  module DiscordEvents
    # Fantasy Name Generator
    module FantasyNameGenerator
      extend Discordrb::EventContainer

      message(content: /^!g fantasy name$/) do |event|
        last_names = YAML.load_file("#{Dir.pwd}/data/tables/last_name.yaml")
        first_names = YAML.load_file("#{Dir.pwd}/data/tables/fantasy_name.yaml")

        first_name = first_names[:names][rand(0..(first_names[:names].length - 1))]
        last_name = last_names[:names][rand(0..(last_names[:names].length - 1))]

        event.respond ":small_orange_diamond: Nom aléatoire : #{first_name} #{last_name}"
      end
    end
  end
end
