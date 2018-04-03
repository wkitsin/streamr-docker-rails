# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

if Video.find(0) == nil
  Video.create(vid_id: "uJenkalUzms", vid_duration: 1654,
    vid_title: "Dota 2 | Streaming for fun, Currently Ancient [0]", vid_copy: nil,
    channel_title: "RippedCore", channel_id: "UCmQiZ9jUe8g4_bwcT-WX34A", embeddable: nil, video_type: "nil")
end
