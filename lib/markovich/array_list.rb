# -*- coding: utf-8 -*-

module Markovich

	class ArrayList
		include Common
		
		def initialize(collection = [])
			@source = collection
		end

		def search(query)
			result = @source.dup.keep_if { |s| s == s.merge(query) }
			result.sample if result
		end

		def save_doc(doc)
			unless @source.include? doc then
				@source << doc
				true
			else
				false
			end
		end

		def drop
			@source = []
		end

		class << self
			def create(text)
				al = ArrayList.new
				text = [ text ] unless text.is_a? Array
				text.each do |t|
					next unless t.is_a? String
					al.save_text(t)
				end
				al
			end
		end
	end

end