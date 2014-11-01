#!/usr/bin/ruby
require 'dbus'

bus = DBus::SystemBus.instance
service = bus.request_service("fi.ouka.edu.lyseo.mimu")

class Player < DBus::Object
  dbus_interface "fi.ouka.edu.lyseo" do
    dbus_method :play, "in shouldPlay:b" do |shouldPlay|
      @playing = shouldPlay
    end #dbus_method
    dbus_method :queue, "in ytid:s" do |ytid|
      @playlist << ytid
    end #dbus_method
    dbus_method :getQueueLength, "out length:i" do
      [@playlist.length]
    end #dbus_method
    dbus_method :getYtid, "in index:i, out ytid:s" do |index|
      [@playlist[index]]
    end #dbus_method
    dbus_signal :nowPlaying, "ytid:s"
    dbus_signal :statusPlaying, "playing:b"
    dbus_signal :errorOccurred, "error:s"
  end #dbus_interface
end #class
      
