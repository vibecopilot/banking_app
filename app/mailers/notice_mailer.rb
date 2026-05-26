class NoticeMailer < ApplicationMailer
	def notice_notification(user_id, notice)
	    @user = user_id
	    @notice = notice
	    @tracking_pixel_url = track_email_open_notice_url(@notice, user_id: @user.id, host: default_url_host)
	    @view_notice_url = track_email_click_notice_url(@notice, user_id: @user.id, host: default_url_host)
	    mail(to: @user.email, from: "noreply@myciti.life", subject: "New Notice: #{@notice.notice_title}")
  	end

  	private

  	def default_url_host
  		Rails.application.config.action_mailer.default_url_options[:host] rescue 'myciti.life'
  	end
end
