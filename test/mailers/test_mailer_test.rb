class TestMailer < ApplicationMailer
  default from: "noreply@myciti.life"

  def test_email
    @message = "SMTP is working!"
    mail(to: "your_email@example.com", subject: "Test Email from MyCiti App")
  end
end
