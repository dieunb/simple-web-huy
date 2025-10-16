# frozen_string_literal: true

# Controller for managing user sessions (login/logout)
class SessionsController < Frack::BaseController
  def new
    [[], 302, { 'location' => '/sign_in' }]
  end

  def create
    email = request.params['email']
    password = request.params['password']
    User.find_by(email: email)
    return login_success(authenticated_user) if authenticated_user
    login_failed
  end

  def destroy
    request.session.delete('user_id')
    request.session['flash'] = 'You have successfully signed out!'
    [[], 302, { 'location' => '/' }]
  end

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
