class SessionCleanupWorker
  include Sidekiq::Worker

  def perform
    Session.expired.delete_all
  end
end
