require_relative '../lib/mealpass_orderer'
require 'clockwork'

module Clockwork
  RETRY_ATTEMPTS = 3

  handler do |job|
    puts "Running #{job}"
  end

  every(1.day, 'Run a job', tz: 'UTC', at: '7:05pm') do
    if [5, 6].include? Time.now.wday
      puts 'not ordering today'

      return
    end

    RETRY_ATTEMPTS.times do
      system 'rm $HOME/.local/share/Ofi\ Labs/PhantomJS/*'

      break if MealpassOrderer.run
    end
  end
end
