require 'rails_helper'

RSpec.describe ContentCmds::Admin::Build do
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
    describe 'without params' do
      describe 'build a exist content' do
        let(:content1) { contents[0] }
        let(:params) { {} }
        let(:content_params) { {} }

        it 'correct attributes' do
          cmd = ContentCmds::Admin::Build.call(context, content1, content_params.merge(company_id: current_admin_user.company_id), params)
          content, brands, content_ranks, content_ranks_data, content_params, all_brands = cmd.result
          expect(content.title).to eq content1.title
          expect(content.body).to eq content1.body
        end
      end

      describe 'build a new content' do
        let(:params) { {} }
        let(:content_params) { {} }

        it 'correct attributes' do
          content1 = current_admin_user.company.contents.new
          cmd = ContentCmds::Admin::Build.call(context, content1, content_params.merge(company_id: current_admin_user.company_id), params)
          content, brands, content_ranks, content_ranks_data, content_params, all_brands = cmd.result
          expect(content.title).to be_nil
          expect(content.body).to be_nil
        end
      end
    end

    describe 'with params' do
      describe 'build a exist content' do
        let(:content1) { contents[0] }
        let(:params) { 
          {
            content: {
              id: content1.id,
              title: "new content title",
              body: "new content body",
              start_time: Time.now,
              end_time: Time.now + 1.day,
              target_flag: "all_user",
              for_customer: false,
              for_employee: false,
            },
            brand_ids: Brand.ids.join(','),
            is_back: true
          }
        }
        let(:content_params) { params[:content] }

        it 'correct attributes' do
          cmd = ContentCmds::Admin::Build.call(context, content1, content_params.merge(company_id: current_admin_user.company_id), params)
          content, brands, content_ranks, content_ranks_data, content_params, all_brands = cmd.result
          expect(content.title).to eq content_params[:title]
          expect(content.body).to eq content_params[:body]
        end
      end

      describe 'build a new content' do
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
            brand_ids: Brand.ids.join(','),
            is_back: true
          }
        }
        let(:content_params) { params[:content] }

        it 'correct attributes' do
          content1 = current_admin_user.company.contents.new
          cmd = ContentCmds::Admin::Build.call(context, content1, content_params.merge(company_id: current_admin_user.company_id), params)
          content, brands, content_ranks, content_ranks_data, content_params, all_brands = cmd.result
          expect(content.title).to eq content_params[:title]
          expect(content.body).to eq content_params[:body]
        end
      end
    end

    describe "#load_or_build_content_ranks" do
      let(:content1) { contents[0] }
      let!(:rank) { create(:rank, company_id: company.id) }
      let!(:content_rank) { content1.content_ranks.create(content_id: content1.id, rank_id: rank.id) }
      let!(:rank1) { create(:rank, name: 'rank 1', company_id: company.id) }
      let(:params) { 
        {
          content: {
            id: content1.id,
            title: "new content title",
            body: "new content body",
            start_time: Time.now,
            end_time: Time.now + 1.day,
            target_flag: "all_user",
            for_customer: false,
            for_employee: false,
          },
          brand_ids: Brand.ids.join(','),
          is_back: true
        }
      }
      let(:content_params) { params[:content] }

      it 'build ranks' do
        cmd = ContentCmds::Admin::Build.call(context, content1, content_params.merge(company_id: current_admin_user.company_id), params)
        content, brands, content_ranks, content_ranks_data, content_params, all_brands = cmd.result
        expect(content.title).to eq content_params[:title]
        expect(content.body).to eq content_params[:body]
      end
    end
  end
end
