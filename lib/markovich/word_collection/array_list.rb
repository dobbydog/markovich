# -*- coding: utf-8 -*-

include Markovich::WordCollection

class Markovich::WordCollection::ArrayList
	include Common
	
	def initialize(collection = [])
		@source = collection
	end

	def search(query)
		res_array = Array.new
		@source.each do |s|
			res_array << s if s == s.merge(query)
		end
		res_array.sample
	end

	def save_doc(doc)
		@source << doc
	end

	def drop
		@source = []
	end
end
