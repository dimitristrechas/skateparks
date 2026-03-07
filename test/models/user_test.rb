require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'new user defaults to user role' do
    user = User.new(email_address: 'test@example.com', password: 'password123')

    assert_equal 'user', user.role
  end

  test 'user can be promoted to admin' do
    user = users(:one)
    user.update(role: :admin)

    assert_predicate user, :admin?
  end

  test 'banned user is not active' do
    user = users(:one)
    user.ban!(reason: 'Violation')

    assert_not user.active?
  end

  test 'ban! sets banned_at and ban_reason' do
    user = users(:one)
    user.ban!(reason: 'Spam')

    assert_predicate user, :banned?
    assert_equal 'Spam', user.ban_reason
  end

  test 'role can be set directly but should use strong params in controllers' do
    user = User.new(email_address: 'test@example.com', password: 'password123', role: :admin)

    assert_equal 'admin', user.role
  end

  test 'active user is not banned' do
    user = users(:one)

    assert_predicate user, :active?
  end
end
