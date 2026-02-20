class Api::V1::EarthquakesController < ApplicationController
  def index
    earthquakes = Earthquake.order(occurred_at: :desc).limit(200)
    render json: earthquakes
  end
end