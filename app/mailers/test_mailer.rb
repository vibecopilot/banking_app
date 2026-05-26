class TestMailer < ApplicationMailer
  default from: "noreply@myciti.life"

  def test_email
    mail(
      to: "akshaymugale1@gmail.com",
      subject: "SMTP Test Email from MyCiti"
    )
  end
end
class TestMailer < ApplicationMailer
end
