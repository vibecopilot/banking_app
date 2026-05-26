class UserMailer < ApplicationMailer
  # default from: "noreply@myciti.life"
  default from: "noreply@vibecopilot.ai"


  def user_welcome_mailer(user , password)
    @user = user
    @password = password
    mail(to: @user.try(:email), from: "noreply@vibecopilot.ai", subject: "WELCOME TO RAGHAV REALTY SERVICE MANAGEMENT PORTAL!")
  end

  def new_user_welcome_mailer(user,password)
    @user = user
    @password = password
    site_name = @user&.site&.name || 'Service Management' # Fallback if site name is nil
    mail(
      to: @user.try(:email),
      from: "#{site_name} <noreply@myciti.life>", # Interpolation requires double quotes
      subject: "WELCOME TO #{site_name} SERVICE MANAGEMENT PORTAL!"
    )
  end

  def send_otp(user, otp)
    @user = user
    @otp = otp

    mail(
      to: @user.email,
      subject: "Your OTP Verification Code"
    )
  end
end
