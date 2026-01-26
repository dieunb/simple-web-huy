# frozen_string_literal: true

# Simple global configuration helpers for the app.
module AppConfig
  def self.smtp_from_email
    ENV.fetch('SMTP_FROM_EMAIL', 'noreply@example.com')
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

  def self.setup_mail
    Mail.defaults do
      delivery_method :smtp, smtp_settings
    end
  end
end
