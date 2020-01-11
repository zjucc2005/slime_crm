module DefaultHelper

  def default_prompt
    'Please select'
  end

  def currency_options
    ApplicationRecord::CURRENCY.to_a.map(&:reverse)
  end

end