require_relative '../lib/mealpass_orderer'

RETRY_ATTEMPTS = 3

RETRY_ATTEMPTS.times do
  break if MealpassOrderer.run
end
