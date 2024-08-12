require 'rails_helper'

RSpec.describe ContentCmds::Admin::GetList do
  let!(:company) { create(:company, id: nil, domain: ENV['DEFAULT_DOMAIN'], can_use_point: true) }
  let!(:current_admin_user) { create(:company_staff, company: company) }
  let!(:company_2) { create(:company, id: nil, domain: srand.to_s.last(6)) }
  let!(:contents) { 
    (1..5).to_a.map { |i| create(:content, discarded_at: nil, company: company) } + 
    (1..5).to_a.map { |i| create(:content, discarded_at: nil, company: company_2) } + 
    (1..5).to_a.map { |i| create(:content, discarded_at: nil, company_id: nil) }
  }
  let!(:brands) { (1..5).to_a.map { |i| create(:brand, name: "brand name #{i} n", code: "abcd#{i}2341", company: company) } }
  let!(:content_brands) { Content.all.map { |item| create(:content_brand, content_id: item.id, brand_id: brands[0].id) } }
  let(:context) { { current_user: current_admin_user, current_company: current_admin_user.company } }

  describe '#call' do
    describe "displays n th page" do
      let!(:new_contents) {
        (1..Settings.default_page_size).to_a.map { |i| create(:content, discarded_at: nil, company: company) } 
      }

      it "page 1 with default_page_size" do
        params = { page: 1 }

        scope = Content.accessible_by(ContentAbility.new(current_admin_user), :read)
        cmd_result = ContentCmds::Admin::GetList.call(scope, params)
        expect(cmd_result.records.size).to eq(Settings.default_page_size)
      end
      
      it "page 2 with default_page_size" do
        params = { page: 2 }
        
        scope = Content.accessible_by(ContentAbility.new(current_admin_user), :read)
        cmd_result = ContentCmds::Admin::GetList.call(scope, params)
        expect(cmd_result.records.size).to be >= 1
      end

      it "page 1 with per_page params" do
        params = { page: 1, per_page: 10 }
        
        scope = Content.accessible_by(ContentAbility.new(current_admin_user), :read)
        cmd_result = ContentCmds::Admin::GetList.call(scope, params)
        expect(cmd_result.records.size).to eq(10)
      end

      it "page 2 with per_page params" do
        params = { page: 2, per_page: 10 }
        
        scope = Content.accessible_by(ContentAbility.new(current_admin_user), :read)
        cmd_result = ContentCmds::Admin::GetList.call(scope, params)
        expect(cmd_result.records.size).to be >= 1
      end
    end

    it 'return correct contents for company staff' do
      params = {}

      scope = Content.accessible_by(ContentAbility.new(current_admin_user), :read)
      cmd_result = ContentCmds::Admin::GetList.call(scope, params)
      expect(cmd_result.records.pluck(:company_id)).to include(company.id)
      expect(cmd_result.records.pluck(:company_id)).not_to include(company_2.id)
    end

    describe "sort contents" do
      before :each do
        contents.each(&:destroy)
      end

      describe "returns contents sorted by id" do
        let!(:sort_contents) { 
          [
            create(:content, discarded_at: nil, title: "title1", company: company),
            create(:content, discarded_at: nil, title: "title2", company: company),
          ]
        }
        let(:sort_asc_content_ids) { [ sort_contents[0].id, sort_contents[1].id ] }
        let(:sort_desc_content_ids) { [ sort_contents[1].id, sort_contents[0].id ] }
        
        it "returns contents sorted by id ascending" do
          params = { q: { s: "id asc", per_page: 3 } }

          scope = Content.accessible_by(ContentAbility.new(current_admin_user), :read)
          cmd_result = ContentCmds::Admin::GetList.call(scope, params)
          actual_content_ids = cmd_result.records.pluck(:id).uniq
          expect(actual_content_ids).to eq(sort_asc_content_ids)
        end

        it "returns contents sorted by id descending" do
          params = { q: { s: "id desc", per_page: 3 } }

          scope = Content.accessible_by(ContentAbility.new(current_admin_user), :read)
          cmd_result = ContentCmds::Admin::GetList.call(scope, params)
          actual_content_ids = cmd_result.records.pluck(:id).uniq
          expect(actual_content_ids).to eq(sort_desc_content_ids)
        end
      end

      describe "returns contents sorted by title" do
        let!(:sort_contents) { 
          [
            create(:content, discarded_at: nil, title: "title1", company: company),
            create(:content, discarded_at: nil, title: "title2", company: company),
          ]
        }
        let(:sort_asc_content_ids) { [ sort_contents[0].id, sort_contents[1].id ] }
        let(:sort_desc_content_ids) { [ sort_contents[1].id, sort_contents[0].id ] }
        
        it "returns contents sorted by title ascending" do
          params = { q: { s: "title asc", per_page: 3 } }
          
          scope = Content.accessible_by(ContentAbility.new(current_admin_user), :read)
          cmd_result = ContentCmds::Admin::GetList.call(scope, params)
          actual_content_ids = cmd_result.records.pluck(:id).uniq
          expect(actual_content_ids).to eq(sort_asc_content_ids)
        end

        it "returns contents sorted by title descending" do
          params = { q: { s: "title desc", per_page: 3 } }
          
          scope = Content.accessible_by(ContentAbility.new(current_admin_user), :read)
          cmd_result = ContentCmds::Admin::GetList.call(scope, params)
          actual_content_ids = cmd_result.records.pluck(:id).uniq
          expect(actual_content_ids).to eq(sort_desc_content_ids)
        end
      end

      describe "returns contents sorted by body" do
        let!(:sort_contents) { 
          [
            create(:content, discarded_at: nil, company: company, body: "body1"),
            create(:content, discarded_at: nil, company: company, body: "body2"),
          ]
        }
        let(:sort_asc_content_ids) { [ sort_contents[0].id, sort_contents[1].id ] }
        let(:sort_desc_content_ids) { [ sort_contents[1].id, sort_contents[0].id ] }
        
        it "returns contents sorted by body ascending" do
          params = { q: { s: "body asc", per_page: 3 } }
          
          scope = Content.accessible_by(ContentAbility.new(current_admin_user), :read)
          cmd_result = ContentCmds::Admin::GetList.call(scope, params)
          actual_content_ids = cmd_result.records.pluck(:id).uniq
          expect(actual_content_ids).to eq(sort_asc_content_ids)
        end

        it "returns contents sorted by body descending" do
          params = { q: { s: "body desc", per_page: 3 } }

          scope = Content.accessible_by(ContentAbility.new(current_admin_user), :read)
          cmd_result = ContentCmds::Admin::GetList.call(scope, params)
          actual_content_ids = cmd_result.records.pluck(:id).uniq
          expect(actual_content_ids).to eq(sort_desc_content_ids)
        end
      end

      describe "returns contents sorted by start_time" do
        let!(:sort_contents) { 
          [
            create(:content, discarded_at: nil, company: company, start_time: Time.now),
            create(:content, discarded_at: nil, company: company, start_time: Time.now + 1.hour),
          ]
        }
        let(:sort_asc_content_ids) { [ sort_contents[0].id, sort_contents[1].id ] }
        let(:sort_desc_content_ids) { [ sort_contents[1].id, sort_contents[0].id ] }
        
        it "returns contents sorted by start_time ascending" do
          params = { q: { s: "start_time asc", per_page: 3 } }

          scope = Content.accessible_by(ContentAbility.new(current_admin_user), :read)
          cmd_result = ContentCmds::Admin::GetList.call(scope, params)
          actual_content_ids = cmd_result.records.pluck(:id).uniq
          expect(actual_content_ids).to eq(sort_asc_content_ids)
        end

        it "returns contents sorted by start_time descending" do
          params = { q: { s: "start_time desc", per_page: 3 } }

          scope = Content.accessible_by(ContentAbility.new(current_admin_user), :read)
          cmd_result = ContentCmds::Admin::GetList.call(scope, params)
          actual_content_ids = cmd_result.records.pluck(:id).uniq
          expect(actual_content_ids).to eq(sort_desc_content_ids)
        end
      end

      describe "returns contents sorted by end_time" do
        let!(:sort_contents) { 
          [
            create(:content, discarded_at: nil, company: company, end_time: Time.now + 1.day),
            create(:content, discarded_at: nil, company: company, end_time: Time.now + 1.day + 1.hour),
          ]
        }
        let(:sort_asc_content_ids) { [ sort_contents[0].id, sort_contents[1].id ] }
        let(:sort_desc_content_ids) { [ sort_contents[1].id, sort_contents[0].id ] }
        
        it "returns contents sorted by end_time ascending" do
          params = { q: { s: "end_time asc", per_page: 3 } }

          scope = Content.accessible_by(ContentAbility.new(current_admin_user), :read)
          cmd_result = ContentCmds::Admin::GetList.call(scope, params)
          actual_content_ids = cmd_result.records.pluck(:id).uniq
          expect(actual_content_ids).to eq(sort_asc_content_ids)
        end

        it "returns contents sorted by end_time descending" do
          params = { q: { s: "end_time desc", per_page: 3 } }

          scope = Content.accessible_by(ContentAbility.new(current_admin_user), :read)
          cmd_result = ContentCmds::Admin::GetList.call(scope, params)
          actual_content_ids = cmd_result.records.pluck(:id).uniq
          expect(actual_content_ids).to eq(sort_desc_content_ids)
        end
      end
    end

    describe "search by title_or_body_cont" do
      before :each do
        contents.each(&:destroy)
      end

      let(:keyword) { "keyword" }
      let!(:search_contents) { 
        [
          create(:content, discarded_at: nil, title: "keyword title", company_id: company.id),
          create(:content, discarded_at: nil, title: "keyword title2", company_id: company.id),
          create(:content, discarded_at: nil, body: "keyword body", company_id: company.id),
          create(:content, discarded_at: nil, body: "keyword body2", company_id: company.id)
        ]
      }
      let(:search_content_ids) { search_contents.map(&:id) }
      let!(:other_contents) { 
        (1..5).to_a.map { |i| create(:content, title: "other#{i}", body: "other#{i}", company_id: company.id) } + 
        (1..5).to_a.map { |i| create(:content, title: "other#{i}", body: "other#{i}", company_id: nil) }
      }

      it "returns correct title_or_body_cont" do
        all_contents = Content.count + 1
        params = { q: { title_or_body_cont: keyword }, per_page: all_contents }
        
        scope = Content.accessible_by(ContentAbility.new(current_admin_user), :read)
        cmd_result = ContentCmds::Admin::GetList.call(scope, params)
        id_result = cmd_result.records.pluck(:id).uniq
        expect(id_result.sort).to eq(search_content_ids.sort)
      end
    end
  end
end
