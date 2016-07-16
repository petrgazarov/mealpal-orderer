require_relative '../lib/mealpass_orderer'
require 'clockwork'

module Clockwork
  RETRY_ATTEMPTS = 3

  handler do |job|
    puts "Running #{job}"
  end

  every(3.minutes, 'Run a job', tz: 'UTC') do
    RETRY_ATTEMPTS.times do
      system 'rm $HOME/.local/share/Ofi\ Labs/PhantomJS/*'

      break if MealpassOrderer.run
    end
  end
end
