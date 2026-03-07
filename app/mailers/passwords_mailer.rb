class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: I18n.t('passwords_mailer.subject'), to: user.email_address
  end
end
