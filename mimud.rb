#!/usr/bin/ruby
require 'dbus'
require 'optparse'

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
  end #def
  dbus_interface "fi.ouka.edu.lyseo.mimu.playlist" do
    dbus_method :play, "in shouldPlay:b" do |shouldPlay|
      @playing = shouldPlay
      if $options[:verbose]
        STDERR.puts "@playing = #{@playing}"
      end #if
    end #dbus_method
    dbus_method :queue, "in ytid:s" do |ytid|
      @playlist << ytid
      if $options[:verbose]
        STDERR.puts "Added #{ytid} to playlist"
      end #if
    end #dbus_method
    dbus_method :getQueueLength, "out length:i" do
      [@playlist.length]
    end #dbus_method
    dbus_method :getYtid, "in index:i, out ytid:s" do |index|
      if @playlist[index]
        [@playlist[index]]
      else
        [""]
      end #if
    end #dbus_method
    dbus_signal :nowPlaying, "ytid:s"
    dbus_signal :statusPlaying, "playing:b"
    dbus_signal :errorOccurred, "error:s"
  end #dbus_interface
end #class

# Configure using Session or System bus, and the service name here
bus = DBus::SessionBus.instance
service = bus.request_service("fi.ouka.edu.lyseo.mimu")

obj = Player.new("/fi/ouka/edu/lyseo/mimu")
service.export(obj)

puts "mimud listening"
main = DBus::Main.new
main << bus
main.run