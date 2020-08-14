# frozen_string_literal: true

class CreateSession
  JWT_ALG = 'HS256'

  def initialize(params)
    @username = params.fetch('username')
    @password = params.fetch('password')
    @secure = params['secure_login']
  end

  def process
    user = User.find_by(username: @username)

    return unless user&.authenticate(@password)

    exp = (DateTime.current + (@secure ? 10.minutes : 1.month)).to_i
    JWT.encode({ user_id: user.id, exp: exp }, ENV.fetch('SECRET_KEY'), JWT_ALG)
  end
end
