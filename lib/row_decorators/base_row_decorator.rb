class BaseRowDecorator < SimpleDelegator
  attr_writer :name, :card, :amount, :rest, :performed_at

  def name
    @name || ''
  end

  def card
    @card || nil
  end

  def amount
    @amount || 0
  end

  def rest
    @rest || 0
  end

  def performed_at
    @performed_at || nil
  end

  def as_json
    { 'name' => name, 'card' => card, 'amount' => amount, 'rest' => rest, 'performed_at' => performed_at }
  end
end
