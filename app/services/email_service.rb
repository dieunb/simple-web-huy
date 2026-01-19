# frozen_string_literal: true

require 'mail'

# Service class for sending emails
class EmailService
  def self.send_welcome_email(user)
    configure_smtp
    build_mail(user).deliver!
    true
  rescue StandardError => e
    puts "EmailService Error: #{e.message}"
    puts e.backtrace.first(5).join("\n")
    false
  end

  private

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
      subject 'Welcome to SimpleWeb - Sign Up Successful!'
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
    <<~EMAIL
      Hello #{user.email},
      Welcome to SimpleWeb!
      Thank you for signing up. Your account has been successfully created.
      We're excited to have you on board!
      Best regards,
      The SimpleWeb Team
    EMAIL
  end
end
