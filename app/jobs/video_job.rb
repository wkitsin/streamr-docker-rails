class VideoJob < ApplicationJob
  queue_as :default

  def perform
    visitor = Visit.all.count

    if visitor != 0
    likes = Ahoy::Event.all.count
    more_than = (likes/visitor.to_f)*100

      if more_than >= 50
        if Video.last.video_type != 'prev'
          VideoJob.disable!
          Video.last.update(video_type: 'prev')
        else
          CleanVisitsEventsJob.perform_now
          VideoJob.play_random_video
        end
      else
        has_available_stream = false
        if Stream.count > 0
          play_stream(has_available_stream)
        else
         VideoJob.play_random_video
        end
      end
    else
      if Stream.count > 0
        play_stream(has_available_stream)
      else
       VideoJob.play_random_video
      end
    end
  end

    def play_stream(has_available_stream)
      while !has_available_stream && Stream.count > 0
        stream = Stream.last
        # video = Yt::Video.new id: stream.stream_id
        #Stream in our database is no longer live
        # if video.live_broadcast_content != 'live'
        if Streaming.count == 0
          Streaming.new(stream_id: stream.stream_id, stream_title: stream.stream_title,
          channel_id: stream.channel_id, channel_title: stream.channel_title, streamer: stream.streamer)
        else
        Streaming.last.update(stream_id: stream.stream_id, stream_title: stream.stream_title,
          channel_id: stream.channel_id, channel_title: stream.channel_title, streamer: stream.streamer)
        end
        Video.last.update(vid_id: stream.stream_id, vid_title: stream.stream_title,
          channel_id: stream.channel_id, channel_title: stream.channel_title, vid_duration: 0)
        stream.destroy
      end
    end

    def self.play_random_video
        live = rand(0..1)
        videos = Yt::Collections::Videos.new
        if live == 1
         luck = rand(0..1)
         luck == 1 ? duration = 'long' : duration = 'medium'
         vid = videos.where(order: 'viewCount', q: 'fun streaming dota', videoEmbeddable: true, videoDuration: duration)
        else
          vid = videos.where(order: 'viewCount', q: 'dota 2 stream', event_type: 'live', videoEmbeddable: true)
        end

      count = rand(1..vid.count)
      @live = vid.take(count).last
      @video = VideoJob.video(@live)
      CleanVisitsEventsJob.perform_now
    end

    def self.video(vid)
      Video.last.update(vid_id: vid.id , vid_duration: vid.duration/2,
          vid_title: vid.title, channel_title: vid.channel_title,
          channel_id: vid.channel_id, video_type: 'nil')
    end

    def self.disable!
      # set a flag in Redis, it will expire after 10 minutes
      Sidekiq.redis {|c| c.set("disable_periodic_jobs", 1, ex: 60) }
    end

end
