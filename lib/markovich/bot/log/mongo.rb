# -*- coding: utf-8 -*-

require 'mongo'

include Markovich::Bot::Log

class Markovich::Bot::Log::Mongo

  attr_accessor :last_replied, :last_collected

  def initialize(dbconf)
    conn = Mongo::Connection.new
    db = conn.db(dbconf['db'])
    @data = db.collection(dbconf['log_collection'])
    @last_replied = ( replied_doc = @data.find_one({:name => 'replied'}) ) ? replied_doc['id'] : nil
    @last_collected = ( collected_doc = @data.find_one({:name => 'collected'}) ) ? collected_doc['id'] : nil
  end

  def save_last_replied(id = nil)
    @last_replied = id unless id.nil?
    @data.update({:name => 'replied'}, {'$set' => {:id => @last_replied}})
  end

  def save_last_collected(id = nil)
    @last_collected = id unless id.nil?
    @data.update({:name => 'collected'}, {'$set' => {:id => @last_collected}})
  end

  def drop
    @data.drop
    @last_replied = nil
    @last_collected = nil
  end

end
