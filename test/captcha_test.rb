# frozen_string_literal: true

require 'minitest/autorun'
require 'pagy'
require 'pagy/extras/overflow'
require 'pagy/extras/bootstrap'
require 'rack'
require 'tilt'
require 'erubi'
require_relative '../lib/frack/base_controller'

# A dummy controller to test CAPTCHA helpers
class DummyController < Frack::BaseController
  attr_accessor :mock_request

  # rubocop:disable Lint/MissingSuper
  def initialize(session = {})
    @mock_request = Struct.new(:session, :params).new(session, {})
  end
  # rubocop:enable Lint/MissingSuper

  def request
    @mock_request
  end

  public :generate_captcha, :valid_captcha?
end

class CaptchaTest < Minitest::Test
  def setup
    @controller = DummyController.new
  end

  def test_generate_captcha
    @controller.generate_captcha('test_scope')
    assert_includes @controller.request.session, 'captcha_answer_test_scope'
    assert_kind_of Integer, @controller.request.session['captcha_answer_test_scope']
  end

  def test_valid_captcha_with_correct_answer
    @controller.generate_captcha('test_scope')
    ans = @controller.request.session['captcha_answer_test_scope']
    @controller.request.params['captcha'] = ans.to_s
    assert @controller.valid_captcha?('test_scope')
  end

  def test_invalid_captcha_with_incorrect_answer
    @controller.generate_captcha('test_scope')
    ans = @controller.request.session['captcha_answer_test_scope']
    @controller.request.params['captcha'] = (ans + 1).to_s
    refute @controller.valid_captcha?('test_scope')
  end

  def test_invalid_captcha_with_missing_param
    @controller.generate_captcha('test_scope')
    @controller.request.params['captcha'] = nil
    refute @controller.valid_captcha?('test_scope')
  end
end
