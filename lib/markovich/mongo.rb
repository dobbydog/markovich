# -*- coding: utf-8 -*-

require 'mongo'

module Markovich

	class Mongo

		include Common
		
		def initialize(dbconf)
			conn = ::Mongo::Connection.new
			db = conn.db(dbconf['db'])
			@source = db.collection(dbconf['words_collection'])
		end

		def search(query)
			@source.find(query).to_a.sample
		end

		def save_doc(doc)
			if @source.find_one(doc).nil? then
				@source.save(doc)
				true
			else
				false
			end
		end

		def drop
			@source.drop
		end

	end
end