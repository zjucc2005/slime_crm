# encoding: utf-8
module DefaultHelper

  def default_prompt
    'Please select'
  end

  def currency_options
    ApplicationRecord::CURRENCY.to_a.map(&:reverse)
  end

  def currency_display(val)
    ApplicationRecord::CURRENCY[val] || val
  end

  def currency_symbol(val)
    { 'RMB' => '¥', 'USD' => '$' }[val] || val
  end

  def bank_options
    Bank.all.order(:name).pluck(:name)
  end

  def industry_options
    Industry.all.order(:name).pluck(:name)
  end

  ##
  # boolean options for select tag
  def boolean_options
    [[t(:true), 'true'], [t(:false), 'false']]
  end

  def boolean_display(val)
    val.nil? ? val : t(val.to_s.to_sym)
  end

  ##
  # show creator of instance
  def show_creator(instance)
    creator = instance.creator.try(:name_cn) || current_user.name_cn
    "#{mt(:candidate, :created_by)}: #{creator}"
  end

  ##
  # show timestamps of instance
  def show_timestamps(instance)
    if %w[new create].include? action_name

    else
      arr = []
      arr << "#{mt(:user, :created_at)}: #{instance.created_at.strftime('%F %T')}" if instance.created_at
      arr << "#{mt(:user, :updated_at)}: #{instance.updated_at.strftime('%F %T')}" if instance.updated_at
      arr.join(', ')
    end
  end

end