# frozen_string_literal: true

class User < ActiveRecord::Base
  has_secure_password

  has_many :records, dependent: :destroy
  has_many :cards, dependent: :destroy
  has_many :tags, dependent: :destroy
end