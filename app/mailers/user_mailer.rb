class UserMailer < ApplicationMailer
  def send_signup_email(user)
    @user = user

    mail(
      to: @user.mealpal_email,
      subject: 'Thanks for signing up for Mealpal Orderer!'
    )
  end
end
