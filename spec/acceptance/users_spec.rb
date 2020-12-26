# frozen_string_literal: true

resource 'Users' do
  let(:user) { create :user }

  before do
    header 'Authorization', "Berier #{JWT.encode({ user_id: user.id }, ENV.fetch('SECRET_KEY'), 'HS256')}"
  end

  header 'Accept', 'application/json'

  get '/user' do
    context 'status 200' do
      example_request 'Show profile' do
        expect(status).to eq 200
      end
    end
  end

  put '/user' do
    parameter :username, 'Username', scope: :user, type: :string, example: 'ivan'
    parameter :password, 'Password', scope: :user, type: :string
    parameter :password_confirmation, 'Password Confirmaiton', scope: :user, type: :string
    parameter :report_sender, 'Email of the contact who send reports', scope: [:user, :gmail_connection_attributes], type: :string, example: 'sender@gmail.com'
    parameter :connected_at, 'Date since last uploaded report', scope: [:user, :gmail_connection_attributes], type: :string, example: '2020-02-02T18:56:00.000Z'

    context 'status 200' do
      let(:username) { Faker::Internet.username }
      let(:password) { 'password' }
      let(:password_confirmation) { 'password' }
      let(:report_sender) { Faker::Internet.free_email }
      let(:connected_at) { Time.now.to_s }

      example_request 'Update' do
        updated_user = User.last

        expect(status).to eq 200
        expect(updated_user.username).to eq username
        expect(updated_user.gmail_connection.report_sender).to eq report_sender
      end
    end

    context 'status 400' do
      let(:username) { Faker::Internet.username }
      let(:password) { 'password' }
      let(:password_confirmation) { 'paaasword1$' }
      let(:report_sender) { Faker::Internet.free_email }
      let(:connected_at) { Time.now.to_s }

      example_request 'Update validation error' do
        expect(status).to eq 400
        expect(response_body).to eq({ 'message' => ['Password confirmation doesn\'t match Password'] }.to_json)
      end
    end
  end
end
