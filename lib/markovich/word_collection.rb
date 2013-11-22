# -*- coding: utf-8 -*-

begin
  require 'MeCab'
rescue LoadError
  abort "MeCab load error"
end

include Markovich

module Markovich::WordCollection

	TAGGER = MeCab::Tagger.new("-Owakati")

	module Common
		attr_reader :source
		
		def build_sentence(query, interrogative = false)
			seed = search(query)
			return nil if seed.nil?
			second = seed["second"]
			third = seed["third"]
			out = query["first"] + second
			while third != "EOS"
				out += third
				query = {"first" => second, "second" => third}
				seed = search(query)
				break if seed.nil?
				second = third
				third = seed["third"]
			end
			out.gsub(/^BOS/, '').gsub(/EOS$/, '')
		end
		
		def build_sentence_reverse(query)
			seed = search(query)
			return nil if seed.nil?
			first = seed["first"]
			second = seed["second"]
			third = seed["third"]
			out = second + third
			while first != "BOS"
				out = first + out
				query = {"second" => first, "third" => second}
				seed = search(query)
				break if seed.nil?
				second = first
				first = seed["first"]
			end
			out.gsub(/^BOS/, '').gsub(/EOS$/, '')
		end

		def build_mention_about(text)
			node = TAGGER.parseToNode(text).next
			nouns = Array.new
			result = nil
			while node do
				surface = node.surface.force_encoding("utf-8")
				feature = node.feature.force_encoding("utf-8").split(",")
				nouns << surface if feature[0] =~ /(名詞|動詞|形容詞)/
				node = node.next
			end
			while !nouns.empty? do
				seed = nouns.slice!(rand(nouns.size))
				result = build_sentence({"first" => seed})
				next if result.nil?
				break
			end
			result
		end
		
		def save_text(text)
			WordCollection::parse(text).each_cons(3) do |a|
				save_doc({"first" => a[0], "second" => a[1], "third" => a[2]})
			end
			self
		end

		def search; end
		def save_doc; end
		def drop; end
	end
	
	class << self
		def make_al_from_array(arr)
			al = ArrayList.new
			arr.each do |t|
				al.save_text(t)
			end
		end
		
		def parse(text)
			TAGGER.parse("BOS" + text + "EOS").force_encoding("UTF-8").split(" ")
		end
	end
	
end