# frozen_string_literal: true

require 'mail'
require_relative 'app_config'

# Service class for sending welcome emails
class WelcomeEmailService
  def self.send_welcome_email(user)
    configure_smtp
    build_mail(user).deliver!
  end

  def self.configure_smtp
    settings = smtp_settings

    Mail.defaults do
      delivery_method :smtp, settings
    end
  end

  def self.build_mail(user)
    email_body = generate_welcome_email_body(user)
    Mail.new do
      from    AppConfig.smtp_from_email
      to      user.email
      subject 'Welcome to Ecommerce-Web - Sign Up Successful!'
      body    email_body
    end
  end

  def self.smtp_settings
    AppConfig.smtp_settings
  end

  def self.generate_welcome_email_body(user)
    template_path = File.join(__dir__, '..', 'views', 'emails', 'welcome.html.erb')
    template = ERB.new(File.read(template_path))
    template.result_with_hash(user: user)
  end
end
