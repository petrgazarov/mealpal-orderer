class ApplicationMailer < ActionMailer::Base
  default from: "admin@mealpal-orderer.com"

  layout 'mailer'
end
