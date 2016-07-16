require_relative '../lib/mealpass_orderer'
require 'clockwork'

module Clockwork
  RETRY_ATTEMPTS = 3

  handler do |job|
    puts "Running #{job}"
  end

  every(1.day, 'Order mealpass', tz: 'America/New_York', at: '19:05') do
    if [5, 6].include? Time.now.wday
      puts 'not ordering today'
    else
      RETRY_ATTEMPTS.times do
        system 'rm $HOME/.local/share/Ofi\ Labs/PhantomJS/*'

        break if MealpassOrderer.run
      end
    end
  end
end
