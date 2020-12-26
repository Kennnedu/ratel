# frozen_string_literal: true

class GmailConnection < ActiveRecord::Base
  belongs_to :user

  def q
    str = String.new
    str.insert(-1, "from: #{report_sender}") if report_sender
    str.insert(-1, " after: #{connected_at.to_i}") if connected_at
    str.presence
  end
end
