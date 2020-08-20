# frozen_string_literal: true

class ReportIteratorBase
  attr_accessor :file

  def initialize(file)
    @file = file
  end

  def foreach
    @item_decorator = item_decorator_instance

    collection.each do |row|
      @item_decorator.__setobj__(row)
      yield @item_decorator.as_json
    end
  end

  def item_decorator_instance
    raise NotImplementedError
  end

  def collection
    raise NotImplementedError
  end
end
