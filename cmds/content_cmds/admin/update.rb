require 'rails_helper'

RSpec.describe ContentCmds::Admin::Update do
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
    describe 'success' do
      let(:content) { contents[0] }
      let(:params) {
        {
          content: {
            id: content.id,
            title: "update content title",
            body: "update content body",
            start_time: Time.now,
            end_time: Time.now + 1.day,
            target_flag: "all_user",
            for_customer: false,
            for_employee: false,
          },
          brand_ids: Brand.ids.join(',')
        }
      }
      let(:content_params) { params[:content] }

      it 'correct attributes' do
        ContentCmds::Admin::Update.call(context, content, content_params.merge(company_id: current_admin_user.company_id), params)
        content.reload
        expect(content.title).to eq "update content title"
      end
    end

    describe "validation" do
      let(:content1) { contents[0] }
      let(:params) { 
        {
          content: {
            title: "new content title",
            body: "new content body",
            start_time: Time.now,
            end_time: Time.now + 1.day,
            target_flag: "all_user",
            for_customer: false,
            for_employee: false,
          },
          brand_ids: Brand.ids.join(',')
        }
      }

      context "when title blank" do
        before(:each) do
          params[:content][:title] = ""
        end    

        it "render new with error" do
          content_params = params[:content]
          
          cmd = ContentCmds::Admin::Update.call(context, content1, content_params.merge(company_id: current_admin_user.company_id), params)
          content, brands, content_ranks, content_ranks_data, content_params, all_brands = cmd.result
          expect(content.errors[:title]).to include("を入力してください。")
        end

        it "should not change content's attribute" do
          content_params = params[:content]

          old_value = content1.title
          cmd = ContentCmds::Admin::Update.call(context, content1, content_params.merge(company_id: current_admin_user.company_id), params)
          expect(Content.find(content1.id).title).to eq(old_value)
        end
  
        it "should not change content number" do
          content_params = params[:content]

          expect {
            ContentCmds::Admin::Update.call(context, content1, content_params.merge(company_id: current_admin_user.company_id), params)
          }.to change { Content.count }.by(0)
        end
      end

      context "when title is too long" do
        before(:each) do
          params[:content][:title] = "a"*201
        end    

        it "render new with error" do
          content_params = params[:content]
          
          cmd = ContentCmds::Admin::Update.call(context, content1, content_params.merge(company_id: current_admin_user.company_id), params)
          content, brands, content_ranks, content_ranks_data, content_params, all_brands = cmd.result
          expect(content.errors[:title]).to include("は正しく入力されていません。")
        end

        it "should not change content's attribute" do
          content_params = params[:content]

          old_value = content1.title
          cmd = ContentCmds::Admin::Update.call(context, content1, content_params.merge(company_id: current_admin_user.company_id), params)
          expect(Content.find(content1.id).title).to eq(old_value)
        end
  
        it "should not change content number" do
          content_params = params[:content]

          expect {
            ContentCmds::Admin::Update.call(context, content1, content_params.merge(company_id: current_admin_user.company_id), params)
          }.to change { Content.count }.by(0)
        end
      end

      context "when title has trailing whitespace" do
        before(:each) do
          params[:content][:title] = "      new content title       "
        end    

        it "correct attributes" do
          content_params = params[:content]

          cmd = ContentCmds::Admin::Update.call(context, content1, content_params.merge(company_id: current_admin_user.company_id), params)
          content, brands, content_ranks, content_ranks_data, content_params, all_brands = cmd.result
          expect(content.title).to eq(params[:content][:title].strip)
        end
  
        it "should not increase content number" do
          content_params = params[:content]

          expect {
            ContentCmds::Admin::Update.call(context, content1, content_params.merge(company_id: current_admin_user.company_id), params)
          }.to change { Content.count }.by(0)
        end
      end

      context "when body blank" do
        before(:each) do
          params[:content][:body] = ""
        end    

        it "render new with error" do
          content_params = params[:content]

          cmd = ContentCmds::Admin::Update.call(context, content1, content_params.merge(company_id: current_admin_user.company_id), params)
          content, brands, content_ranks, content_ranks_data, content_params, all_brands = cmd.result
          expect(content.errors[:body]).to include("を入力してください。")
        end

        it "should not change content's attribute" do
          content_params = params[:content]

          old_value = content1.body
          cmd = ContentCmds::Admin::Update.call(context, content1, content_params.merge(company_id: current_admin_user.company_id), params)
          expect(Content.find(content1.id).body).to eq(old_value)
        end
  
        it "should not change content number" do
          content_params = params[:content]

          expect {
            ContentCmds::Admin::Update.call(context, content1, content_params.merge(company_id: current_admin_user.company_id), params)
          }.to change { Content.count }.by(0)
        end
      end

      context "when start_time blank" do
        before(:each) do
          params[:content][:start_time] = ""
        end    

        it "render new with error" do
          content_params = params[:content]

          cmd = ContentCmds::Admin::Update.call(context, content1, content_params.merge(company_id: current_admin_user.company_id), params)
          content, brands, content_ranks, content_ranks_data, content_params, all_brands = cmd.result
          expect(content.errors[:start_time]).to include("を選択してください。")
        end

        it "should not change content's attribute" do
          content_params = params[:content]

          old_value = content1.start_time
          cmd = ContentCmds::Admin::Update.call(context, content1, content_params.merge(company_id: current_admin_user.company_id), params)
          expect(Content.find(content1.id).start_time).to eq(old_value)
        end
  
        it "should not change content number" do
          content_params = params[:content]

          expect {
            ContentCmds::Admin::Update.call(context, content1, content_params.merge(company_id: current_admin_user.company_id), params)
          }.to change { Content.count }.by(0)
        end
      end

      context "when end_time blank" do
        before(:each) do
          params[:content][:end_time] = ""
        end    

        it "render new with error" do
          content_params = params[:content]

          cmd = ContentCmds::Admin::Update.call(context, content1, content_params.merge(company_id: current_admin_user.company_id), params)
          content, brands, content_ranks, content_ranks_data, content_params, all_brands = cmd.result
          expect(content.errors[:end_time]).to include("を選択してください。")
        end

        it "should not change content's attribute" do
          content_params = params[:content]

          old_value = content1.end_time
          cmd = ContentCmds::Admin::Update.call(context, content1, content_params.merge(company_id: current_admin_user.company_id), params)
          expect(Content.find(content1.id).end_time).to eq(old_value)
        end
  
        it "should not change content number" do
          content_params = params[:content]
          
          expect {
            ContentCmds::Admin::Update.call(context, content1, content_params.merge(company_id: current_admin_user.company_id), params)
          }.to change { Content.count }.by(0)
        end
      end

      context "when end_time is before start_time" do
        before(:each) do
          params[:content][:start_time] = Time.now + 1.hour
          params[:content][:end_time] = Time.now
        end   

        it 'render new with error' do
          content_params = params[:content]

          cmd = ContentCmds::Admin::Update.call(context, content1, content_params.merge(company_id: current_admin_user.company_id), params)
          content, brands, content_ranks, content_ranks_data, content_params, all_brands = cmd.result
          expect(content.errors[:end_time]).to include("は 利用開始日時 より後の日付にしてください。")
        end
  
        it "should not change content number" do
          content_params = params[:content]

          expect {
            ContentCmds::Admin::Update.call(context, content1, content_params.merge(company_id: current_admin_user.company_id), params)
          }.to change { Content.count }.by(0)
        end
      end

      context "when brand_ids blank" do
        before(:each) do
          params[:brand_ids] = ""
        end

        it "render new with error" do
          content_params = params[:content]

          cmd = ContentCmds::Admin::Update.call(context, content1, content_params.merge(company_id: current_admin_user.company_id), params)
          content, brands, content_ranks, content_ranks_data, content_params, all_brands = cmd.result
          expect(content.errors[:content_brands]).to include("を選択してください。")
        end
  
        it "should not change content number" do
          content_params = params[:content]

          expect {
            ContentCmds::Admin::Update.call(context, content1, content_params.merge(company_id: current_admin_user.company_id), params)
          }.to change { Content.count }.by(0)
        end
      end
    end
  end
end
