class BaseRowDecorator < SimpleDelegator
  def as_json
    { 'name' => name, 'card' => card, 'amount' => amount, 'performed_at' => performed_at }
  end
end
