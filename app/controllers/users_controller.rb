# frozen_string_literal: true

# Controller for managing user-related actions
class UsersController < Frack::BaseController
  def new
    render 'users/new'
  end

  def create
    email = request.params['email']
    password = request.params['password']
    password_confirmation = request.params['password_confirmation']
    session = request.session

    if User.find_by(email: email)
      handle_existing_user
    else
      create_new_user(email, password, password_confirmation, session)
    end
  end

  private

  def create_new_user(email, password, password_confirmation, session)
    @user = User.new(
      email: email,
      password: password,
      password_confirmation: password_confirmation
    )
    return signup_success(session) if @user.save

    signup_failed(session)
  end

  def signup_success(session)
    session['user_id'] = @user.id
    session['flash'] = 'Sign up successful'
    EmailWorker.perform_async(@user.id)
    [[], 302, { 'location' => '/' }]
  end

  def signup_failed(session)
    session['flash'] = 'Sign up failed'
    [[], 302, { 'location' => '/sign_up' }]
  end

  def handle_existing_user
    request.session['flash'] = 'Email existed'
    [[], 302, { 'location' => '/sign_up' }]
  end
end
