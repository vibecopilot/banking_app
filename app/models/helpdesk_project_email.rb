class HelpdeskProjectEmail < ApplicationRecord
    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP } 

    def self.active
     where("active is null or active !=0")
    end

    def self.send_projectemail
      all_emails = HelpdeskProjectEmail.active.pluck(:email)
      Spree::HelpdeskProjectMailer.new_helpdesk_emailer(all_emails).deliver_now
    end
end
