class SyncEarthquakesJob < ApplicationJob
  queue_as :default

  def perform
    UsgsSyncService.call
  end
end