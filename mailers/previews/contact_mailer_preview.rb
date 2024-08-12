# Preview all emails at http://localhost:3000/rails/mailers/contact_mailer
class ContactMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/contact_mailer/confirm_user
  def confirm_user
    ContactMailer.confirm_user
  end

  # Preview this email at http://localhost:3000/rails/mailers/contact_mailer/confirm_admin
  def confirm_admin
    ContactMailer.confirm_admin
  end
end
