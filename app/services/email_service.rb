# frozen_string_literal: true

require 'mail'

# Service class for sending emails
# Follows Service Object pattern to separate email logic from controllers/workers
class EmailService
  class << self
    # Send welcome email to newly registered user
    # @param user [User] The user object to send email to
    # @return [Boolean] true if email sent successfully, false otherwise
    def send_welcome_email(user)
      configure_smtp

      # Generate email body before creating Mail object
      email_body = generate_welcome_email_body(user)

      mail = Mail.new do
        from    ENV.fetch('SMTP_FROM_EMAIL', 'noreply@example.com')
        to      user.email
        subject 'Welcome to SimpleWeb - Sign Up Successful!'
        body    email_body
      end

      mail.deliver!
      true
    rescue StandardError => e
      # Log error in production, for now just print
      puts "EmailService Error: #{e.message}"
      puts e.backtrace.first(5).join("\n")
      false
    end

    private

    # Configure SMTP settings from environment variables
    def configure_smtp
      Mail.defaults do
        delivery_method :smtp, {
          address:              ENV.fetch('SMTP_HOST', 'smtp.gmail.com'),
          port:                 ENV.fetch('SMTP_PORT', '587').to_i,
          domain:               ENV.fetch('SMTP_DOMAIN', 'gmail.com'),
          user_name:            ENV.fetch('SMTP_USER', nil),
          password:             ENV.fetch('SMTP_PASSWORD', nil),
          authentication:       :plain,
          enable_starttls_auto: true
        }
      end
    end

    # Generate welcome email body
    # @param user [User] The user object
    # @return [String] Email body content
    def generate_welcome_email_body(user)
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
end
