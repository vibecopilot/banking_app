# require 'test_helper'

# class MailTestControllerTest < ActionDispatch::IntegrationTest
#   test "should get send_email" do
#     get mail_test_send_email_url
#     assert_response :success
#   end

# end

class MailTestController < ApplicationController
  def send_email
    TestMailer.test_email.deliver_now
    render plain: "Email sent!"
  end
end
