# -*- coding: utf-8 -*-

require 'mongo'

include Markovich::WordCollection

class Markovich::WordCollection::Mongo

	include Common
	
	def initialize(dbconf)
		conn = Mongo::Connection.new
		db = conn.db(dbconf['db'])
		@source = db.collection(dbconf['words_collection'])
	end

	def search(query)
		@source.find(query).to_a.sample
	end

	def save_doc(doc)
		if @source.find_one(doc).nil? then
			@source.save(doc)
		else
			nil
		end
	end

	def drop
		@source.drop
	end

end
