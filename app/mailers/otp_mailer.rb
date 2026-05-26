class OtpMailer < ApplicationMailer
  def send_otp(user, otp)
    @user = user
    @otp = otp

  mail(
      to: @user.email,
      subject: "Your OTP Verification Code"
    )
  end


end