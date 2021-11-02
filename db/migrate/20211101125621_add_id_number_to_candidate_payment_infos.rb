class AddIdNumberToCandidatePaymentInfos < ActiveRecord::Migration[6.0]
  def change
    add_column :candidate_payment_infos, :id_number, :string
  end
end
