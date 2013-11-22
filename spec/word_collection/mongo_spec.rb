# -*- coding: utf-8 -*-

require "markovich"

include Markovich::WordCollection

describe Mongo do

	context "正しい引数が渡された場合" do
		before :all do
			@mongo = Markovich::WordCollection::Mongo.new({
				"db" => 'markovich_test',
				"words_collection" => 'words',
				"log_collection" => 'log'
			})
			@test_doc = {"first" => "しかし", "second" => "本文", "third" => "の"}
			@test_doc_first_only = @test_doc.select{|k,v| k == "first"}
			@none_doc = {"first" => "存在", "second" => "しま", "third" => "せん"}
			@test_text = "しかし、本文の該当権は、一般の投稿さえ重要な例外が著作に含まれ、同じ方針ができる日本語に抜粋を作ることを規定します。"
		end

		subject { @mongo }

		describe ".new" do
			it "インスタンスが生成されること" do
				subject.should be_instance_of Markovich::WordCollection::Mongo
			end
		end

		describe "#save_doc" do
			it "データを保存できること" do
				subject.save_doc(@test_doc).should be_instance_of BSON::ObjectId
			end
		end

		describe "#save_text" do
			it "文章が保存できること" do
				subject.save_text(@test_text).should be_instance_of Markovich::WordCollection::Mongo
			end
		end

		describe "#build_mention_about" do
			it "文章が保存されたら同じ文章から言及が生成できること" do
				subject.save_text(@test_text).build_mention_about(@test_text).class.should == String
			end
		end

		context "コレクションが空の場合" do
			before :each do
				subject.drop
			end

			describe "#search" do
				it "データを取得しようとするとnilが返ること" do
					subject.search(@test_doc).should be_nil
				end
			end

			describe "#build_sentence" do
				it "文章が生成できずnilが返ること" do
					subject.build_sentence(@test_doc).should be_nil
				end
			end

			describe "#build_sentence_reverse" do
				it "文章が生成できずnilが返ること" do
					subject.build_sentence_reverse(@test_doc).should be_nil
				end
			end

			after :each do
				subject.drop
			end
		end

		context "コレクションが存在する場合" do
			before :each do
				subject.save_doc(@test_doc)
			end

			describe "#save_doc" do
				it "登録済みのデータを保存しようとするとnilが返ること" do
					subject.save_doc(@test_doc).should be_nil
				end
			end

			describe "#search" do
				it "登録済みのデータが取得できること" do
					result = subject.search(@test_doc)
					result["first"].should == @test_doc["first"]
					result["second"].should == @test_doc["second"]
					result["third"].should == @test_doc["third"]
				end

				it "未登録のデータを取得しようとするとnilが返ること" do
					subject.search(@none_doc).should be_nil
				end
			end

			describe "#build_sentence" do
				it "生成された文章が返ること" do
					subject.build_sentence(@test_doc).should be_instance_of String
				end
			end

			describe "#build_sentence_reverse" do
				it "生成された文章が返ること" do
					subject.build_sentence_reverse(@test_doc).should be_instance_of String
				end
			end

			describe "#drop" do
				it "コレクションをdropし、登録したデータが取得できないこと" do
					subject.drop
					subject.search(@test_doc).should be_nil
				end
			end

			after :each do
				subject.drop
			end
		end			

		after :all do
			subject.drop
		end
	end
	
	context "引数なしの場合" do
		describe ".new" do
			it "ArgumentErrorが発生する" do
				expect{Markovich::WordCollection::Mongo.new}.to raise_error ArgumentError
			end
		end
	end

end