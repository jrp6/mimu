#!/usr/bin/ruby

require 'sinatra'
require 'slim'
require 'dbus'
require 'video_info'

before do
  @bus = DBus::SessionBus.instance
  @srv = @bus.service("fi.ouka.edu.lyseo.mimu")
  @player = @srv.object("/fi/ouka/edu/lyseo/mimu")
  @player.introspect
  @player.default_iface = "fi.ouka.edu.lyseo.mimu.playlist"
end

get '/watch' do
  slim :watch, locals: {:ytid => params[:v]}
end #get

get '/' do
  redirect to('/playlist')
end #get

get '/playlist' do
  playlistLength = @player.getQueueLength()[0]
  @playlist = []
  for i in 0...playlistLength
    @playlist << VideoInfo.new("https://youtube.com/watch?v="+@player.getYtid(i)[0])
  end
  slim :playlist
end #get

post '/playlist' do
  @player.queue(params[:ytid])
  redirect to('/playlist')
end #post

delete '/playlist/:id' do |id|
  @player.unqueue(id.to_i)
  redirect to('/playlist')
end #delete

get '/play-pause' do
  if @player.getStatus()[0]
    "playing"
  else
    "paused"
  end #if
end #get

post '/play-pause' do
  t = params[:status]
  if t == "play"
    @player.play(true)
  elsif t == "pause"
    @player.play(false)
  end
  redirect to('/playlist')
end #post
