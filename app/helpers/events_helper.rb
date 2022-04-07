module EventsHelper
  def accommodations_poc_contact(event)
    contact_methods = []
    contact_methods << mail_to(event.accommodations_email) if event.accommodations_email.present?
    contact_methods << event.accommodations_phone if event.accommodations_phone.present?
    safe_join(contact_methods, " or ")
  end
end
