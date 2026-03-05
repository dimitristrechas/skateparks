require 'test_helper'

class AuditLogTest < ActiveSupport::TestCase
  test 'creates audit log with required fields' do
    actor = create(:user, :admin)
    target = create(:user)

    log = AuditLog.create!(
      actor: actor,
      target: target,
      action: 'ban',
      details: { reason: 'Spam' }
    )

    assert log.persisted?
    assert_equal actor, log.actor
    assert_equal target, log.target
    assert_equal 'ban', log.action
    assert_equal({ 'reason' => 'Spam' }, log.details)
  end

  test 'requires action' do
    actor = create(:user, :admin)
    target = create(:user)

    log = AuditLog.new(actor: actor, target: target, action: nil)

    assert_not log.valid?
    assert_includes log.errors[:action], "can't be blank"
  end

  test 'belongs to actor' do
    log = AuditLog.new
    assert_respond_to log, :actor
  end

  test 'belongs to target polymorphically' do
    log = AuditLog.new
    assert_respond_to log, :target
  end
end
