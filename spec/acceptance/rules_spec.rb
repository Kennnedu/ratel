# frozen_string_literal: true

resource 'Rules' do
  let(:user) { create :user }
  let(:tag) { create :tag, user: user }

  before do
    header 'Authorization', "Berier #{JWT.encode({ user_id: user.id }, ENV.fetch('SECRET_KEY'), 'HS256')}"
  end

  header 'Accept', 'application/json'

  get '/rules' do
    example_request 'List' do
      expect(status).to eq 200
    end
  end

  post '/rules' do
    context 'status 200 TagRule type' do
      let(:raw_post) { { condition: { 'in' => ['shop', { 'var' => 'name' }] }, tag_id: tag.id, type: 'TagRule', name: "Tag #{tag.name}" }.to_json }

      example_request 'Create TagRule' do
        expect(status).to eq 200
      end
    end

    context 'status 400' do
      let(:raw_post) { { condition: {}, tag_id: nil }.to_json }

      example_request 'Create validation error' do
        expect(status).to eq 400
      end
    end
  end

  delete '/rules/:id' do
    let(:rule) { create :rule, user: user, tag_id: tag.id, type: 'TagRule' }

    context 'status 200' do
      let!(:id) { rule.id }

      example_request 'Delete' do
        expect(status).to eq 200
      end
    end

    context 'status 404' do
      let!(:id) { 666 }

      example_request 'Delete Not found' do
        expect(status).to eq 404
        expect(response_body).to eq({ 'message' => 'Not found' }.to_json)
      end
    end
  end
end
