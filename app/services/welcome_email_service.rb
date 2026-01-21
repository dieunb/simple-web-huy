# frozen_string_literal: true

require 'mail'

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
      from    ENV.fetch('SMTP_FROM_EMAIL', 'noreply@example.com')
      to      user.email
      subject 'Welcome to Ecommerce-Web - Sign Up Successful!'
      body    email_body
    end
  end

  def self.smtp_settings
    {
      address: ENV.fetch('SMTP_HOST', 'smtp.gmail.com'),
      port: ENV.fetch('SMTP_PORT', '587').to_i,
      domain: ENV.fetch('SMTP_DOMAIN', 'gmail.com'),
      user_name: ENV.fetch('SMTP_USER', nil),
      password: ENV.fetch('SMTP_PASSWORD', nil),
      authentication: :plain,
      enable_starttls_auto: true
    }
  end

  def self.generate_welcome_email_body(user)
    template_path = File.join(__dir__, '..', 'views', 'emails', 'welcome.html.erb')
    template = ERB.new(File.read(template_path))
    template.result_with_hash(user: user)
  end
end

