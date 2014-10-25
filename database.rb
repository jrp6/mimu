require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite:///tmp/mimu-default.db")

class Video
  include DataMapper::Resource

  property :id,    Serial
  property :ytid,  String, :required => true
  property :title, String
end

class State # This wouldn't really need a DB, but we might as well chuck it in since we are using one anyway
  include DataMapper::Resource

  property :id,         Serial
  property :playing,    Boolean, :default => false
  property :playing_id, Integer, :default => 0
end

DataMapper.finalize
DataMapper.auto_upgrade!
