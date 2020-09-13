# frozen_string_literal: true

class FindReports < BaseQuery
  def call
    order({})
  end

  def default_relation
    Report.all
  end

  def default_order
    @relation.order('created_at DESC')
  end
end
