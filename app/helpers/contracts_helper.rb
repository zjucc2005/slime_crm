# encoding: utf-8
module ContractsHelper

  def payment_time_options
    Contract::PAYMENT_TIME.to_a.map(&:reverse)
  end

end