require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  RETRY_ATTEMPTS = 3

  handler do |job|
    puts "Running #{job}"
  end

  every(1.day, 'Order mealpass', tz: 'America/New_York', at: '23:02') do
    if [5, 6].include? Time.now.wday
      puts 'not ordering today'
    else
      User.all.each do |user|
        return unless user.order_days.include?((Time.now.wday + 1).to_s)

        RETRY_ATTEMPTS.times do
          begin
            # remove PhantomJS cookies
            system 'rm $HOME/.local/share/Ofi\ Labs/PhantomJS/*'

            break if Orderer.run(user)

            rescue Exception => e
              log_entry = "\n===========================\n#{Time.now}\n#{e.message}"
              File.open('log/log.log', 'a') { |file| file << log_entry }
          end
        end
      end
    end
  end
end
