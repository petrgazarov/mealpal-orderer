require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  RETRY_ATTEMPTS = 3

  handler do |job|
    puts "Running #{job}"
  end

  every(1.day, 'Order mealpass', tz: 'America/New_York', at: '19:05') do
    if [5, 6].include? Time.now.wday
      puts 'not ordering today'
    else
      User.all.each do |user|
        RETRY_ATTEMPTS.times do
          system 'rm $HOME/.local/share/Ofi\ Labs/PhantomJS/*'

          break if Orderer.run(user)
        end
      end
    end
  end
end
