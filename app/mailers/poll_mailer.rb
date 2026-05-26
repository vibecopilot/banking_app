class PollMailer < ApplicationMailer
  def poll_notification(user_id, poll)
     @user = user_id
      @poll = poll
      mail(to: @user.email,from: "noreply@myciti.life", subject: "New Notice: #{@poll.title}")
  end
end
