# frozen_string_literal: true

# Controller for managing user sessions (login/logout)
class SessionsController < Frack::BaseController
  def new
    render 'sessions/new'
  end

  def create
    email = request.params['email']
    password = request.params['password']
    user = User.find_by(email: email)
    if user&.authenticate(password)
      login_success(user)
    else
      login_failed
    end
  end

  def destroy
    request.session.delete('user_id')
    request.session['flash'] = 'You have successfully signed out!'
    [[], 302, { 'location' => '/' }]
  end

  private

  def login_success(user)
    request.session['user_id'] = user.id
    request.session['flash'] = 'Login successful!'
    [[], 302, { 'location' => '/' }]
  end

  def login_failed
    request.session['flash'] = 'Invalid email or password'
    [[], 302, { 'location' => '/sign_in' }]
  end
end
