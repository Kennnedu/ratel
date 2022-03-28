# frozen_string_literal: true

class Usd < ActiveRecord::Base
  establish_connection ENV['DATABASE_CURRENCY_URL']
end
