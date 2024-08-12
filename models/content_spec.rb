require "rails_helper"

RSpec.describe Content, type: :model do
  context "db" do
    context "attributes" do
      it "default fields" do
        content = Content.new
        expect(content.kind).to eq("brand")
      end
    end

    context "associations" do
      it { should have_many(:content_relations) }
    end
  end

  describe "methods" do
    let!(:company) { create(:company_use_cip) }
    let(:content) { create :content, company_id: company.id }
    let(:user) { create(:user) }

    describe "#discard" do
      let!(:company) { create(:company, id: nil, domain: ENV['DEFAULT_DOMAIN'], can_use_point: true) }
      let!(:company_2) { create(:company, id: nil, domain: srand.to_s.last(6)) }
      let!(:content) { create(:content, discarded_at: nil, company: company) }
      let!(:rank) { create(:rank, company_id: company.id) }
      let!(:content_rank) { create(:content_rank, content_id: content.id, rank_id: rank.id) }
      let!(:brand) { create(:brand, name: "brand name 1 n", code: "abcd12341", company: company) }
      let!(:content_relation) { ContentRelation.create(content_id: content.id, relation: brand) }

      it "discards all associated content_rank when content is discarded" do
        expect {
          content.discard
        }.to change { ContentRank.count }.by(-1)
      end

      it "discards all associated content_brand when content is discarded" do
        expect {
          content.discard
        }.to change { ContentRelation.count }.by(-1)
      end
    end

    describe "#content_brand_names" do
      let!(:company) { create(:company, id: nil, domain: ENV['DEFAULT_DOMAIN'], can_use_point: true) }
      let!(:content) { create(:content, discarded_at: nil, company: company) }
      let!(:brand) { create(:brand, name: "brand name 1 n", code: "abcd12341", company: company) }
      let!(:content_relation) { ContentRelation.create(content_id: content.id, relation: brand) }

      it "when has one rank" do
        expect(content.content_relation_names).to eq(brand.name)
      end

      it "when has one rank" do
        brand1 = create(:brand, name: "brand name 2 n", code: "abcd22341", company: company)
        content_brand1 = ContentRelation.create(content_id: content.id, relation: brand1)
        expect(content.content_relation_names).to eq(brand.name + '、' + brand1.name)
      end
    end

    describe ".by_brand_id" do
      let(:brand_1) { create :brand, company_id: company.id}
      let(:brand_2) { create :brand, company_id: company.id }
      let!(:content_1) { create :content }
      let!(:content_2) { create :content }
      let!(:content_relation_1) { ContentRelation.create(content_id: content_1.id, relation: brand_1) }
      let!(:content_relation_2) { ContentRelation.create(content_id: content_2.id, relation: brand_2) }

      it do
        expect(Content.by_relation_id(brand_1.id).ids).to eq([content_1.id])
      end
    end
  end
end
