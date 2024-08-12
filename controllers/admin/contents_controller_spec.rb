require "rails_helper"

RSpec.describe Admin::ContentsController, type: :controller do
  render_views
  include Warden::Test::Helpers
  Warden.test_mode!

  def symbol_object
    :content
  end

  def assigns_list
    assigns(:contents)
  end

  def assigns_object
    assigns(:content)
  end

  def model_class
    Content
  end

  def create_object(hash)
    create(:content, hash)
  end

  def edit_params(content, hash = {})
    { 
      content: content.attributes.symbolize_keys.merge(hash),
      relation_ids: Brand.ids.join(','),
      id: content.id
    }
  end

  def is_back_edit_params(content, hash = {})
    { 
      content: content.attributes.symbolize_keys.merge(hash),
      relation_ids: Brand.ids.join(','),
      id: content.id,
      is_back: true
    }
  end

  def new_params(content, hash = {})
    { 
      content: content.attributes.symbolize_keys.except(:id).merge(hash),
      relation_ids: Brand.ids.join(','),
    }
  end

  def is_back_new_params(content, hash = {})
    { 
      content: content.attributes.symbolize_keys.except(:id).merge(hash),
      relation_ids: Brand.ids.join(','),
      is_back: true
    }
  end

  context "when user is company_staff" do
    let!(:company) { create(:company, id: nil, domain: ENV['DEFAULT_DOMAIN'], can_use_point: true) }
    let!(:company_staff) { create(:company_staff, company: company) }
    let!(:company_2) { create(:company, id: nil, domain: srand.to_s.last(6)) }
    let!(:list) { 
      (1..5).to_a.map { |i| create_object(discarded_at: nil, company: company) } + 
      (1..5).to_a.map { |i| create_object(discarded_at: nil, company: company_2) } + 
      (1..5).to_a.map { |i| create_object(discarded_at: nil, company_id: nil) }
    }
    let!(:brands) { (1..5).to_a.map { |i| create(:brand, name: "brand name #{i} n", code: "abcd#{i}2341", company: company) } }
    let!(:content_brands) { Content.all.map { |item| ContentRelation.create(content_id: item.id, relation: brands[rand(0..4)]) } }

    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:admin_user]
      @user                          = company_staff
      sign_in(@user, scope: :admin_user)
    end

    describe "#index" do
      it "render layout list screen" do
        get :index
        assert_select("h1", "ブランド検索用のコンテンツ一覧画面")
        assert_select("th span", "ID")
        assert_select("th span", "タイトル")
        assert_select("th span", "内容")
        assert_select("th span", "適用開始日時")
        assert_select("th span", "適用終了日時")
        assert_select("th span", "削除")
      end

      describe "displays n th page" do
        let!(:new_objects) {
          (1..Settings.default_page_size).to_a.map { |i| create_object(discarded_at: nil, company: company) } 
        }

        it "page 1 with default_page_size" do
          get :index, params: { page: 1 }
          expect(assigns_list.size).to eq(Settings.default_page_size)
        end
        
        it "page 2 with default_page_size" do
          get :index, params: { page: 2 }
          expect(assigns_list.size).to be >= 1
        end

        it "page 1 with per_page params" do
          get :index, params: { page: 1, per_page: 10 }
          expect(assigns_list.size).to eq(10)
        end

        it "page 2 with per_page params" do
          get :index, params: { page: 2, per_page: 10 }
          expect(assigns_list.size).to be >= 1
        end
      end

      it "return correct list for company staff" do
        list_count = model_class.count + 1
        get :index, params: { per_page: list_count }
        expect(assigns_list.pluck(:company_id)).to include(company.id)
        expect(assigns_list.pluck(:company_id)).not_to include(company_2.id)
      end

      describe "sort list" do
        before :each do
          list.each(&:destroy)
        end

        describe "returns sorted by id" do
          let!(:sort) { 
            [
              create_object(discarded_at: nil, company: company),
              create_object(discarded_at: nil, company: company),
            ]
          }
          let(:sort_asc_ids) { [ sort[0].id, sort[1].id ] }
          let(:sort_desc_ids) { [ sort[1].id, sort[0].id ] }
          
          it "returns sorted by id ascending" do
            get :index, params: { q: { s: "id asc", per_page: 3 } }
            actual_ids = assigns_list.pluck(:id).uniq
            expect(actual_ids).to eq(sort_asc_ids)
          end

          it "returns sorted by id descending" do
            get :index, params: { q: { s: "id desc", per_page: 3 } }
            actual_ids = assigns_list.pluck(:id).uniq
            expect(actual_ids).to eq(sort_desc_ids)
          end
        end

        describe "returns sorted by title" do
          let!(:sort) { 
            [
              create_object(discarded_at: nil, title: "title 1", company: company),
              create_object(discarded_at: nil, title: "title 2", company: company),
            ]
          }
          let(:sort_asc_ids) { [ sort[0].id, sort[1].id ] }
          let(:sort_desc_ids) { [ sort[1].id, sort[0].id ] }
          
          it "returns sorted by title ascending" do
            get :index, params: { q: { s: "title asc", per_page: 3 } }
            actual_ids = assigns_list.pluck(:id).uniq
            expect(actual_ids).to eq(sort_asc_ids)
          end

          it "returns sorted by title descending" do
            get :index, params: { q: { s: "title desc", per_page: 3 } }
            actual_ids = assigns_list.pluck(:id).uniq
            expect(actual_ids).to eq(sort_desc_ids)
          end
        end

        describe "returns sorted by body" do
          let!(:sort) { 
            [
              create_object(discarded_at: nil, body: "body 1", company: company),
              create_object(discarded_at: nil, body: "body 2", company: company),
            ]
          }
          let(:sort_asc_ids) { [ sort[0].id, sort[1].id ] }
          let(:sort_desc_ids) { [ sort[1].id, sort[0].id ] }
          
          it "returns sorted by body ascending" do
            get :index, params: { q: { s: "body asc", per_page: 3 } }
            actual_ids = assigns_list.pluck(:id).uniq
            expect(actual_ids).to eq(sort_asc_ids)
          end
  
          it "returns sorted by body descending" do
            get :index, params: { q: { s: "body desc", per_page: 3 } }
            actual_ids = assigns_list.pluck(:id).uniq
            expect(actual_ids).to eq(sort_desc_ids)
          end
        end

        describe "returns sorted by start_time" do
          let!(:sort) { 
            [
              create_object(discarded_at: nil, start_time: Time.now, company: company),
              create_object(discarded_at: nil, start_time: Time.now + 1.hour, company: company),
            ]
          }
          let(:sort_asc_ids) { [ sort[0].id, sort[1].id ] }
          let(:sort_desc_ids) { [ sort[1].id, sort[0].id ] }
          
          it "returns sorted by start_time ascending" do
            get :index, params: { q: { s: "start_time asc", per_page: 3 } }
            actual_ids = assigns_list.pluck(:id).uniq
            expect(actual_ids).to eq(sort_asc_ids)
          end
  
          it "returns sorted by start_time descending" do
            get :index, params: { q: { s: "start_time desc", per_page: 3 } }
            actual_ids = assigns_list.pluck(:id).uniq
            expect(actual_ids).to eq(sort_desc_ids)
          end
        end

        describe "returns sorted by end_time" do
          let!(:sort) { 
            [
              create_object(discarded_at: nil, start_time: Time.now, end_time: Time.now + 1.hour, company: company),
              create_object(discarded_at: nil, start_time: Time.now + 2.hour, end_time: Time.now + 3.hour, company: company),
            ]
          }
          let(:sort_asc_ids) { [ sort[0].id, sort[1].id ] }
          let(:sort_desc_ids) { [ sort[1].id, sort[0].id ] }
          
          it "returns sorted by end_time ascending" do
            get :index, params: { q: { s: "end_time asc", per_page: 3 } }
            actual_ids = assigns_list.pluck(:id).uniq
            expect(actual_ids).to eq(sort_asc_ids)
          end
  
          it "returns sorted by end_time descending" do
            get :index, params: { q: { s: "end_time desc", per_page: 3 } }
            actual_ids = assigns_list.pluck(:id).uniq
            expect(actual_ids).to eq(sort_desc_ids)
          end
        end
      end

      describe "search by title_or_body_cont" do
        before :each do
          list.each(&:destroy)
        end

        let(:keyword) { "keyword" }
        let!(:search_objects) { 
          [
            create_object(discarded_at: nil, title: "keyword title", company_id: company.id),
            create_object(discarded_at: nil, title: "keyword title2", company_id: company.id),
            create_object(discarded_at: nil, body: "keyword body", company_id: company.id),
            create_object(discarded_at: nil, body: "keyword body2", company_id: company.id)
          ]
        }
        let(:search_object_ids) { search_objects.map(&:id) }
        let!(:other_objects) { 
          (1..5).to_a.map { |i| create_object(title: "other#{i}", body: "other#{i}", company_id: company.id) } + 
          (1..5).to_a.map { |i| create_object(title: "other#{i}", body: "other#{i}", company_id: nil) }
        }

        it "returns correct title_or_body_cont" do
          list_count = model_class.count + 1
          get :index, params: { q: { title_or_body_cont: keyword }, per_page: list_count }
          id_result = assigns_list.pluck(:id).uniq
          expect(id_result.sort).to eq(search_object_ids.sort)
        end
      end
    end

    describe "#show" do
      let(:object) { list[0] }

      it "show detail" do
        get :show, params: { id: object.id }
        expect(assigns_object.title).to eq object.title
        assert_select("h1", "ブランド検索用のコンテンツ詳細")
        assert_select("th span", "タイトル"); assert_select("td", object.title)
        assert_select("th span", "適用対象");
        assert_select("th span", "表示対象");
        assert_select("th span", "内容");
        assert_select("th span", "適用開始日時");
        assert_select("th span", "適用終了日時");
        assert_select("th span", "ブランド");
      end
    end

    describe "#new" do
      it "render layout new screen" do
        get :new
        expect(response).to render_template(:new)
        assert_select("h1", "ブランド検索用のコンテンツ登録")
        assert_select("th span", "タイトル");
        assert_select("th span", "適用対象");
        assert_select("th span", "表示対象");
        assert_select("th span", "内容");
        assert_select("th span", "適用開始日時");
        assert_select("th span", "適用終了日時");
        assert_select("th span", "ブランド");
      end
      
      context "when back" do
        let(:object) { list[0] }
        let(:params) { is_back_new_params(object) }
        
        it "correct attributes" do
          get :new, params: params
          expect(assigns_object.title).to eq params[symbol_object][:title]
          expect(assigns_object.body).to eq params[symbol_object][:body]
        end
      end
    end

    describe "#create" do
      describe "success" do
        let(:object) { list[0] }
        let(:params) { new_params(object) }

        it "redirect to complete screen" do
          post :create, params: params
          expect(response.status).to eq 302
          expect(response.location.include?("/complete")).to eq true
        end

        it "correct attributes, belong to company" do
          post :create, params: params
          expect(assigns_object.title).to eq params[symbol_object][:title]
          expect(assigns_object.body).to eq params[symbol_object][:body]
          expect(assigns_object.company).to eq(company)
        end

        it "should increase count number" do
          expect {
            post :create, params: params
          }.to change { model_class.count }.by(1)
        end
      end

      describe "validation" do
        let(:object) { list[0] }
        let(:params) { new_params(object) }

        context "when title blank" do
          before(:each) do
            params[symbol_object][:title] = ""
          end    

          it "render new with error" do
            post :create, params: params
            expect(assigns_object.errors[:title]).to include("を入力してください。")
            expect(response).to render_template(:new)
          end
    
          it "should not change number" do
            expect {
              post :create, params: params
            }.to change { model_class.count }.by(0)
          end
        end

        context "when title is too long" do
          before(:each) do
            params[symbol_object][:title] = "a"*201
          end    

          it "render new with error" do
            post :create, params: params
            expect(assigns_object.errors[:title]).to include("は正しく入力されていません。")
            expect(response).to render_template(:new)
          end
    
          it "should not change number" do
            expect {
              post :create, params: params
            }.to change { model_class.count }.by(0)
          end
        end

        context "when title has trailing whitespace" do
          before(:each) do
            params[symbol_object][:title] = "      new content title       "
          end    

          it "correct attributes" do
            post :create, params: params
            expect(assigns_object.title).to eq(params[symbol_object][:title].strip)
          end
    
          it "should increase number" do
            expect {
              post :create, params: params
            }.to change { model_class.count }.by(1)
          end
        end

        context "when body blank" do
          before(:each) do
            params[symbol_object][:body] = ""
          end    

          it "render new with error" do
            post :create, params: params
            expect(assigns_object.errors[:body]).to include("を入力してください。")
            expect(response).to render_template(:new)
          end
    
          it "should not change number" do
            expect {
              post :create, params: params
            }.to change { model_class.count }.by(0)
          end
        end

        context "when start_time blank" do
          before(:each) do
            params[symbol_object][:start_time] = ""
          end    

          it "render new with error" do
            post :create, params: params
            expect(assigns_object.errors[:start_time]).to include("を選択してください。")
            expect(response).to render_template(:new)
          end
    
          it "should not change number" do
            expect {
              post :create, params: params
            }.to change { model_class.count }.by(0)
          end
        end

        context "when end_time blank" do
          before(:each) do
            params[symbol_object][:end_time] = ""
          end    

          it "render new with error" do
            post :create, params: params
            expect(assigns_object.errors[:end_time]).to include("を選択してください。")
            expect(response).to render_template(:new)
          end
    
          it "should not change number" do
            expect {
              post :create, params: params
            }.to change { model_class.count }.by(0)
          end
        end

        context "when end_time is before start_time" do
          before(:each) do
            params[symbol_object][:start_time] = Time.now + 1.hour
            params[symbol_object][:end_time] = Time.now
          end   

          it 'render new with error' do
            post :create, params: params
            expect(assigns_object.errors[:end_time]).to include("は 適用開始日時 より後の日付にしてください。")
            expect(response).to render_template(:new)
          end
    
          it "should not change number" do
            expect {
              post :create, params: params
            }.to change { model_class.count }.by(0)
          end
        end

        context "when relation_ids blank" do
          before(:each) do
            params[:relation_ids] = ""
          end

          it "render new with error" do
            post :create, params: params
            expect(assigns_object.errors[:content_relations]).to include("を選択してください。")
            expect(response).to render_template(:new)
          end
    
          it "should not change number" do
            expect {
              post :create, params: params
            }.to change { model_class.count }.by(0)
          end
        end
      end
    end

    describe "#edit" do
      let(:object) { list[0] }

      it "render layout edit screen" do
        get :edit, params: { id: object.id }
        expect(response).to render_template(:edit)
        assert_select("h1", "ブランド検索用のコンテンツ編集")
        assert_select("th span", "タイトル"); assert_select("input", value: object.title)
        assert_select("th span", "適用対象");
        assert_select("th span", "表示対象");
        # assert_select("th span", "ランク表示制限");
        assert_select("th span", "内容");
        assert_select("th span", "適用開始日時");
        assert_select("th span", "適用終了日時");
        assert_select("th span", "ブランド");
      end

      it "can not get edit other company" do
        object.company = company_2
        object.save
        get :edit, params: { id: object.id }
        expect(response.status).to eq 302
        expect(response.location.include?("/error/server_error")).to eq true
      end

      context "when back" do
        let(:object) { list[0] }
        let(:params) { is_back_edit_params(object) }
        
        it "correct attributes" do
          get :edit, params: params
          expect(assigns_object.title).to eq params[symbol_object][:title]
          expect(assigns_object.body).to eq params[symbol_object][:body]
        end
      end
    end

    describe "#update" do
      describe "success" do
        let(:object) { list[0] }
        let(:params) { edit_params(object, title: "update title") }

        it "should update with valid params" do
          post :update, params: params
          object.reload
          expect(object.title).to eq "update title"
        end

        it "should not change number" do
          expect {
            post :update, params: params
          }.to change { model_class.count }.by(0)
        end
      end

      describe "validation" do
        let(:object) { list[0] }
        let(:params) { edit_params(object) }

        context "when title blank" do
          before(:each) do
            params[symbol_object][:title] = ""
          end    

          it "render edit with error" do
            post :update, params: params
            expect(assigns_object.errors[:title]).to include("を入力してください。")
            expect(response).to render_template(:edit)
          end

          it "should not change attribute" do
            old_value = object.title
            post :update, params: params
            expect(model_class.find(object.id).title).to eq(old_value)
          end
    
          it "should not change number" do
            expect {
              post :update, params: params
            }.to change { model_class.count }.by(0)
          end
        end

        context "when title is too long" do
          before(:each) do
            params[symbol_object][:title] = "a"*201
          end    

          it "render edit with error" do
            post :update, params: params
            expect(assigns_object.errors[:title]).to include("は正しく入力されていません。")
            expect(response).to render_template(:edit)
          end

          it "should not change attribute" do
            old_value = object.title
            post :update, params: params
            expect(model_class.find(object.id).title).to eq(old_value)
          end
    
          it "should not change number" do
            expect {
              post :update, params: params
            }.to change { model_class.count }.by(0)
          end
        end

        context "when title has trailing whitespace" do
          before(:each) do
            params[symbol_object][:title] = "      new title       "
          end    

          it "correct attributes" do
            post :update, params: params
            expect(assigns_object.title).to eq(params[symbol_object][:title].strip)
          end
    
          it "should not increase number" do
            expect {
              post :update, params: params
            }.to change { model_class.count }.by(0)
          end
        end

        context "when body blank" do
          before(:each) do
            params[symbol_object][:body] = ""
          end    

          it "render edit with error" do
            post :update, params: params
            expect(assigns_object.errors[:body]).to include("を入力してください。")
            expect(response).to render_template(:edit)
          end

          it "should not change attribute" do
            old_value = object.body
            post :update, params: params
            expect(model_class.find(object.id).body).to eq(old_value)
          end
    
          it "should not change number" do
            expect {
              post :update, params: params
            }.to change { model_class.count }.by(0)
          end
        end

        context "when start_time blank" do
          before(:each) do
            params[symbol_object][:start_time] = ""
          end    

          it "render edit with error" do
            post :update, params: params
            expect(assigns_object.errors[:start_time]).to include("を選択してください。")
            expect(response).to render_template(:edit)
          end

          it "should not change attribute" do
            old_value = object.start_time
            post :update, params: params
            expect(model_class.find(object.id).start_time).to eq(old_value)
          end
    
          it "should not change number" do
            expect {
              post :update, params: params
            }.to change { model_class.count }.by(0)
          end
        end

        context "when end_time blank" do
          before(:each) do
            params[symbol_object][:end_time] = ""
          end    

          it "render edit with error" do
            post :update, params: params
            expect(assigns_object.errors[:end_time]).to include("を選択してください。")
            expect(response).to render_template(:edit)
          end

          it "should not change attribute" do
            old_value = object.end_time
            post :update, params: params
            expect(model_class.find(object.id).end_time).to eq(old_value)
          end
    
          it "should not change number" do
            expect {
              post :update, params: params
            }.to change { model_class.count }.by(0)
          end
        end

        context "when end_time is before start_time" do
          before(:each) do
            params[symbol_object][:start_time] = Time.now + 1.hour
            params[symbol_object][:end_time] = Time.now
          end   

          it 'render edit with error' do
            post :update, params: params
            expect(assigns_object.errors[:end_time]).to include("は 適用開始日時 より後の日付にしてください。")
            expect(response).to render_template(:edit)
          end

          it "should not change attribute" do
            old_value = object.start_time
            old_value_2 = object.end_time
            post :update, params: params
            expect(model_class.find(object.id).start_time).to eq(old_value)
            expect(model_class.find(object.id).end_time).to eq(old_value_2)
          end
    
          it "should not change number" do
            expect {
              post :update, params: params
            }.to change { model_class.count }.by(0)
          end
        end

        context "when relation_ids blank" do
          before(:each) do
            params[:relation_ids] = ""
          end

          it "render new with error" do
            post :update, params: params
            expect(assigns_object.errors[:content_relations]).to include("を選択してください。")
            expect(response).to render_template(:edit)
          end

          it "should not change attribute" do
            old_value = object.relations.order(id: :asc)
            post :update, params: params
            expect(model_class.find(object.id).relations.order(id: :asc)).to eq(old_value)
          end
    
          it "should not change number" do
            expect {
              post :update, params: params
            }.to change { model_class.count }.by(0)
          end
        end
      end
    end

    describe "#destroy" do
      let(:object) { list[0] }
      
      it "should decrease content number" do
        expect {
          post :destroy, params: { id: object.id }
        }.to change { model_class.count }.by(-1)
      end

      it "can not delete content of other company" do
        object.company = company_2
        object.save
        post :destroy, params: { id: object.id }
        expect(response.status).to eq 302
        expect(response.location.include?("/error/server_error")).to eq true
      end
    end

    describe "#confirm" do
      describe "when new" do
        let(:object) { list[0] }
        let(:params) { new_params(object) }
        
        it "correct attributes" do
          post :confirm, params: params
          expect(assigns_object.title).to eq params[symbol_object][:title]
          expect(assigns_object.body).to eq params[symbol_object][:body]
        end
      end

      describe "when edit" do
        let(:object) { list[0] }
        let(:params) { edit_params(object) }

        it "correct attributes" do
          post :confirm, params: params
          expect(assigns_object.title).to eq params[symbol_object][:title]
          expect(assigns_object.body).to eq params[symbol_object][:body]
        end
      end
    end
  end
end
