# frozen_string_literal: true

require 'app/workers/email_worker'

# User model for authentication and user management
class User < ActiveRecord::Base
  has_secure_password
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }

  after_commit :send_welcome_email, on: :create

  private

  def send_welcome_email
    EmailWorker.perform_async(id)
  end
end
