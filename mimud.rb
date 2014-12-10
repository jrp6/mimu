#!/usr/bin/ruby
require 'dbus'
require 'thread'
require 'optparse'
Thread.abort_on_exception = true

$options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: mimud.rb [options]"
  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    $options[:verbose] = v
  end #opts.on
end.parse! #OptionParser.new

class Player < DBus::Object
  def initialize(o)
    super(o)
    @playlist = []
    @playing = false
  end #def

  attr_accessor :playing
  attr_accessor :playlist
  
  dbus_interface "fi.ouka.edu.lyseo.mimu.playlist" do
    dbus_method :play, "in shouldPlay:b" do |shouldPlay|
      @playing = shouldPlay
      if $options[:verbose]
        STDERR.puts "@playing = #{@playing}"
      end #if
      self.statusChanged(shouldPlay)
    end #dbus_method
    dbus_method :queue, "in ytid:s" do |ytid|
      @playlist << ytid
      STDERR.puts "Added #{ytid} to playlist" if $options[:verbose]
    end #dbus_method
    dbus_method :unqueue, "in index:i" do |index|
      if @playlist.length > index
        @playlist.delete_at(index)
        STDERR.puts "Removed item no. #{index} from playlist" if $options[:verbose]
      end #if # fail silently if the index doesn't exist
    end #dbus_method
    dbus_method :getQueueLength, "out length:i" do
      [@playlist.length]
    end #dbus_method
    dbus_method :getYtid, "in index:i, out ytid:s" do |index|
      if @playlist[index]
        [@playlist[index]]
      else # fail silently if the index doesn't exist
        [""]
      end #if
    end #dbus_method
    dbus_method :getStatus, "out status:b" do
      [@playing]
    end #dbus_method

    dbus_signal :nowPlaying, "ytid:s"
    dbus_signal :statusChanged, "playing:b"
    dbus_signal :errorOccurred, "error:s"
  end #dbus_interface
end #class

# Configure using Session or System bus, and the service name here
bus = DBus::SessionBus.instance
service = bus.request_service("fi.ouka.edu.lyseo.mimu")

obj = Player.new("/fi/ouka/edu/lyseo/mimu")
service.export(obj)

Thread.new do
  loop do
    if obj.playing
      if obj.playlist.length == 0
        obj.playing = false
        obj.statusChanged(false)
      else
        obj.nowPlaying(obj.playlist[0])
        system("vlc --play-and-exit $(youtube-dl -g \"https://www.youtube.com/watch?v=#{obj.playlist.shift}\")")
      end #if
    else
      sleep(1)
    end #if
  end #loop
end #Thread

puts "mimud listening"
main = DBus::Main.new
main << bus
main.run
