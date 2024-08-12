require 'rails_helper'

RSpec.describe ContentCmds::Admin::Confirm do
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
    describe 'confirm a exist content' do
      let(:content) { contents[0] }
      let(:params) { 
        {
          content: {
            id: content.id,
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
      let(:content_params) { params[:content] }

      it 'correct attributes' do
        cmd = ContentCmds::Admin::Confirm.call(context, content, content_params.merge(company_id: current_admin_user.company_id), params)
        content, brands, content_ranks, content_ranks_data, content_params, all_brands = cmd.result
        expect(content.title).to eq content_params[:title]
        expect(content.body).to eq content_params[:body]
      end
    end

    describe 'confirm a new content' do
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
      let(:content_params) { params[:content] }

      it 'correct attributes' do
        content = Content.new
        cmd = ContentCmds::Admin::Confirm.call(context, content, content_params.merge(company_id: current_admin_user.company_id), params)
        content, brands, content_ranks, content_ranks_data, content_params, all_brands = cmd.result
        expect(content.title).to eq content_params[:title]
        expect(content.body).to eq content_params[:body]
      end
    end

    describe "validations" do
      describe 'when brand_ids is blank' do
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
            brand_ids: ''
          }
        }
        let(:content_params) { params[:content] }
  
        it 'correct attributes' do
          content = Content.new
          cmd = ContentCmds::Admin::Confirm.call(context, content, content_params.merge(company_id: current_admin_user.company_id), params)
          content, brands, content_ranks, content_ranks_data, content_params, all_brands = cmd.result
          expect(content.errors[:content_brands]).to include("を選択してください。")
        end
      end
    end
  end
end
