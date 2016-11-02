# frozen_string_literal: true
require 'sinatra'
require 'econfig'
require 'YPBT'

# GroupAPI web service
class YPBT_API < Sinatra::Base
  extend Econfig::Shortcut

  Econfig.env = settings.environment.to_s
  Econfig.root = settings.root

  API_VER = 'api/v0.1.4'

  get '/?' do
    "GroupAPI latest version endpoints are at: /#{API_VER}/"
  end

  get "/#{API_VER}/video/:video_id/?" do
    video_id = params[:video_id]
    begin
      video = YoutubeVideo::Video.find(video_id: video_id)

      content_type 'application/json'
      { video_id: video_id, title: video.title }.to_json
    rescue
      halt 404, "Video (video_id: #{video_id}) not found"
    end
  end

  get "/#{API_VER}/video/:video_id/commentthreads/?" do
    video_id = params[:video_id]
    begin
      video = YoutubeVideo::Video.find(video_id: video_id)

      content_type 'application/json'
      {
        commentthreads: video.commentthreads.first(3).map do |comment|
          content = { author_name: comment.author.author_name }
          content[:comment_text] = comment.text_display
          content[:like_count] = comment.author.like_count
          content[:author_channel_url] = comment.author.author_channel_url

          { comment: content }
        end
      }.to_json
    rescue
      halt 404, "Cannot group (id: #{group_id}) feed"
    end
  end
end
