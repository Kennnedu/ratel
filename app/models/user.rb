# frozen_string_literal: true

class User < ActiveRecord::Base
  has_secure_password

  has_one :gmail_connection, dependent: :destroy
  has_many :records, dependent: :destroy
  has_many :cards, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :reports, dependent: :destroy
end
