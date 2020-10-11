# frozen_string_literal: true

class AuthorizeRequest
  def process(auth_token)
    payload = JWT.decode(auth_token, ENV.fetch('SECRET_KEY'), true, algorithm: CreateSession::JWT_ALG).first
    User.find payload['user_id']
  end
end
