require_relative '../lib/mealpass_orderer'
require 'clockwork'

module Clockwork
  RETRY_ATTEMPTS = 3

  handler do |job|
    puts "Running #{job}"
  end

  every(6.minutes, 'Run a job', tz: 'UTC') do
    RETRY_ATTEMPTS.times do
      break if MealpassOrderer.run
    end
  end
end
