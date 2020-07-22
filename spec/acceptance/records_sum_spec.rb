# frozen_string_literal: true

require_relative '../spec_helper'

resource 'Records Sum' do
  let(:user) { create :user }
  let!(:records) { create_list :record, 10, user: user }

  before do
    header 'Authorization', "Berier #{JWT.encode({ user_id: user.id }, ENV.fetch('SECRET_KEY'), 'HS256')}"
  end

  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  get '/records/sum' do
    parameter :name, 'Record name (enumiration through & and ! to exclude)', type: :string, example: 'ex&!blo'
    parameter :card, 'Card name (enumiration through & and ! to exclude)', type: :string, example: '33&!66'
    parameter :tags, 'Tags name (enumiration through & and ! to exclude)', type: :string, example: 'blo&!mor'
    parameter :gt, 'Performed at greater than', scope: :performed_at, type: :string, example: '2020-02-02T18:56:00.000Z'
    parameter :lt, 'Performed at less than', scope: :performed_at, type: :string, example: '2020-02-02T18:56:00.000Z'

    let(:name) { 'bo' }

    example_request 'index' do
      expect(status).to eq 200
    end
  end
end
