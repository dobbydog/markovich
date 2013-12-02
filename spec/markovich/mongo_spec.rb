# -*- coding: utf-8 -*-

require "markovich"

describe Markovich::Mongo do

	let :instance do
		described_class.new({
			"db" => 'markovich_test',
			"words_collection" => 'words',
			"log_collection" => 'log'
		})
	end

	let :test_doc do
		{"first" => "しかし", "second" => "本文", "third" => "の"}
	end

	let :none_doc do
		{"first" => "存在", "second" => "しま", "third" => "せん"}
	end

	let :test_text do
		"しかし、本文の該当権は、一般の投稿さえ重要な例外が著作に含まれ、同じ方針ができる日本語に抜粋を作ることを規定します。"
	end


	shared_context "コレクションが空の場合", have_item: false do
		before { instance.drop }
	end

	shared_context "コレクションが存在する場合", have_item: true do
		before { instance.save_doc(sample_doc) }
		after { instance.drop }
	end

	shared_context "文章が保存されている場合", text_saved: true do
		before { instance.save_text(sample_text) }
		after { instance.drop }
	end


	shared_examples "文章生成" do
		context "コレクションが空の場合", have_item: false do
			it "文章が生成できずnilが返ること" do
				should be_nil
			end
		end

		context "コレクションが存在する場合", have_item: true do
			it "生成された文章が返ること" do
				should be_instance_of String
			end
		end
	end
	

	describe "#save_doc" do
		subject { instance.save_doc(sample_doc) }
		let(:sample_doc) { test_doc }

		it "データを保存できること" do
			should be_true
		end

		context "コレクションが存在する場合", have_item: true do
			it "同じデータを保存しようとするとnilが返ること" do
				should be_false
			end
		end

		after :each do
			instance.drop
		end
	end

	describe "#save_text" do
		subject { instance.save_text(sample_doc) }
		let(:sample_doc) { test_text }

		it "文章が保存できること" do
			should be_instance_of described_class
		end
	end

	describe "#build_mention_about" do
		subject { instance.build_mention_about(sample_text) }
		let(:sample_text) { test_text }

		context "文章が保存されている場合", text_saved: true do
			it "同じ文章から言及が生成できること" do
				should be_instance_of String
			end
		end
	end

	describe "#search" do
		subject { instance.search(sample_doc) }
		let(:sample_doc) { test_doc }

		context "コレクションが空の場合", have_item: false do
			it "データを取得しようとするとnilが返ること" do
				should be_nil
			end
		end

		context "コレクションが存在する場合", have_item: true do
			let(:empty_search) { instance.search(none_doc) }
			
			it "登録済みのデータが取得できること" do
				subject["first"].should == sample_doc["first"]
				subject["second"].should == sample_doc["second"]
				subject["third"].should == sample_doc["third"]
			end

			it "未登録のデータを取得しようとするとnilが返ること" do
				expect(empty_search).to be_nil
			end
		end

		context "文章が保存されている場合", text_saved: true do
			let(:sample_text) { test_text }
			let(:sample_doc) { {"first" => "BOS"} }

			it "{\"first\" => \"BOS\"}で検索できること" do
				should_not be_nil
			end
		end
	end

	describe "#build_sentence" do
		subject { instance.build_sentence(sample_doc) }
		let(:sample_doc) { test_doc }

		it_behaves_like "文章生成"
	end

	describe "#build_sentence_reverse" do
		subject { instance.build_sentence_reverse(sample_doc) }
		let(:sample_doc) { test_doc }

		it_behaves_like "文章生成"
	end

end