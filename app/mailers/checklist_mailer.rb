class ChecklistMailer < ApplicationMailer
  default from: 'noreply@vibecopilot.ai'

  def checklist_created(checklist, user)
    @checklist = checklist
    @user = user
    mail(
      to: @user.try(:email), 
      subject: "New Checklist Created - #{@checklist.name}"
    )
  end

  def checklist_updated(checklist, user)
    @checklist = checklist
    @user = user
    mail(
      to: @user.try(:email), 
      subject: "Checklist Updated - #{@checklist.name}"
    )
  end
end