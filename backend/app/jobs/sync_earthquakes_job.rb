class SyncEarthquakesJob < ApplicationJob
  queue_as :default

  def perform
    UsgsSyncService.call
    # Programar la siguiente ejecución en 5 minutos
    SyncEarthquakesJob.set(wait: 5.minutes).perform_later
  end
end