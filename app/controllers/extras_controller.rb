# encoding: utf-8
class ExtrasController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!

  def import_gllue_candidates
    @max_gid = Candidate.maximum("CAST(property->>'gllue_id' AS INTEGER)") || 0

    if request.post?
      begin
        gid_ge = Integer params[:gid_ge]
        gid_le = Integer params[:gid_le]
        raise '每次最多导入100个Gllue ID' if gid_le - gid_ge >= 100
        raise '请填写有效的id范围' if gid_ge > gid_le

        Utils::Gllue.import_by_range(gid_ge..gid_le, current_user.id)
        flash[:success] = t(:operation_succeeded)
        redirect_to import_gllue_candidates_extras_path
      rescue Exception => e
        flash.now[:error] = e.message
        render :import_gllue_candidates
      end
    end
  end

end