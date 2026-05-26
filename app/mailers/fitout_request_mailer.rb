class FitoutRequestMailer < ApplicationMailer
	default from: 'noreply@myciti.life'
	
	def fitout_mail_request(fitout_request)
		@fitout_request = fitout_request
		@user = @fitout_request&.user
		
		return unless @fitout_request && @user&.email
		
		mail(
			to: @user.email, 
			from: 'noreply@myciti.life', 
			subject: "Your Fitout Request ##{@fitout_request.id} has been created"
		)
	end

	def fitout_documents_request(fitout_request)
		@fitout_request = fitout_request
		@user = @fitout_request&.user
		
		return unless @fitout_request && @user&.email
		
		mail(
			to: @user.email, 
			from: 'noreply@myciti.life', 
			subject: "Document Upload Required - Fitout Request ##{@fitout_request.id}"
		)
	end
end
