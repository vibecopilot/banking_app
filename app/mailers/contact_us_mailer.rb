class ContactUsMailer < ApplicationMailer
	def contact_us(name:, email:, message:, existing_customer:)
		@name = name
		@email = email
		@message = message
		@existing_customer = existing_customer
	mail(from: 'noreply@myciti.life', to: @email, subject: "New contact_us Message From #{name}")
	end
end
