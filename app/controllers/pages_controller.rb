class PagesController < ApplicationController

  def welcome
  end

  def home
    # Ahoy Vists
    ahoy.track_visit
    @total_visits = Visit.all.count
    @total_keeps = Ahoy::Event.distinct.count('visit_id')

    # For chat
    @messages = Message.all.order(:created_at)

    #  For video
    @video = Video.last
  end

  def voting
    @total_keeps = Ahoy::Event.distinct.count('visit_id')
    json_content = {data: @total_keeps}
  	render json: json_content
  end

  def update_video
    ahoy.track_visit
  	json_content = {video_data: Video.last, visitor_data: Visit.count, ahoy_data: Ahoy::Event.distinct.count('visit_id')}
  	render json: json_content
  end

end
