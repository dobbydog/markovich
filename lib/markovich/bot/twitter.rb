# -*- coding: utf-8 -*-

require 'twitter'

include Markovich::Bot

class Markovich::Bot::Twitter

	def initialize(conf)
		twconf = conf['twitter_api']
		dbconf = conf['mongo']
		botconf = conf['bot']
		
		Twitter.configure do |c|
			c.consumer_key = twconf['consumer_key']
			c.consumer_secret = twconf['consumer_secret']
			c.oauth_token = twconf['oauth_token']
			c.oauth_token_secret = twconf['oauth_token_secret']
		end
		
		if botconf['use_db']
			@words = WordCollection::Mongo.new(dbconf)
			@log = Log::Mongo.new(dbconf)
		else
			@words = WordCollection::ArrayList.new
			collect
		end
		@screen_name = botconf['screen_name']
	end
	
	def reply
		replied = @log.last_replied
		Twitter.mentions(:since_id => replied, :count => 20).reverse.each do |r|
			result = @words.build_mention_about(r[:text].gsub(/@[a-zA-Z0-9_]+ ?/, ''))
			next if result.nil?
			reply_text = "@" + r[:user][:screen_name] + " " + result
			Twitter.update(reply_text)
			puts reply_text
			replied = r.id
		end
		@log.save_last_replied(replied)
	end
	
	def tweet(start = "BOS", reverse = false)
		res_text = reverse ? @words.build_sentence_reverse({"third" => start}) : @words.build_sentence({"first" => start})
		Twitter.update(res_text)
		puts res_text
	end
	
	def tweet_gimon
		tweet(/[?？]/, true)
	end
	
	# def tweet_ext(query = "山田")
	#   ext = WordCollection.al_ext_source(query)
	#   res_text = ext.build_sentence({"first" => "BOS"})
	#   puts res_text
	# end
	
	def test(start = "BOS")
		res_text = @words.build_sentence({"first" => start})
		puts res_text
	end
	
	def collect
		last_collected = @log.last_collected
		tl_query = {:count => 200}
		tl_query[:since_id] = last_collected unless since.nil?
		Twitter.home_timeline(tl_query).reverse.each do |tl|
			text = tl[:text]
			# 非公式RTと自分自身は対象外
			next if text.include?("RT @") || tl[:user][:screen_name] == @screen_name
			text.gsub!(/http[-_.!~*\'()a-zA-Z0-9;\/?:\@&=+\$,%#]+/, '')
			text.gsub!(/#.+/, "")
			text.gsub!(/@[a-zA-Z0-9_]+/, '')
			@words.save_text(text)
			last_collected = tl.id
		end
		@log.save_last_collected(last_collected) if last_collected
	end
	
	def init
		print "initialize db? [y/N] "
		yn = gets.chomp
		return false if yn.upcase != "Y"
		@words.drop
		@log.drop
		collect
	end
	
end
