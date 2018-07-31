module Admin
  class GigsController < Admin::ApplicationController

    def create
      parameters = gig_params.clone
      parameters.delete :performance_ids
      parameters.delete :children
      gig = Gig.new(parameters)
      create_performances(gig)
      if gig.save
        redirect_to(
          [namespace, 'gigs'],
          notice: translate_with_resource("create.success"),
        )
      else
        render :new, locals: {
          page: Administrate::Page::Form.new(dashboard, gig),
        }
      end
    end

    def update
      gig = Gig.find(params[:id])
      gig.performances.destroy_all
      create_performances(gig)
      if gig.update(gig_params)
        redirect_to(
          [namespace, 'gigs'],
          notice: translate_with_resource("update.success"),
        )
      else
        render :edit, locals: {
          page: Administrate::Page::Form.new(dashboard, gig),
        }
      end
    end

private

    def valid_action?(name, resource = resource_class)
      %w[show].exclude?(name.to_s) && super
    end

    def gig_params
      gig_parameters = params.require(:gig).permit!
      gig_parameters[:starts] = Time.parse(gig_parameters[:starts].to_s)
      gig_parameters[:ends] = Time.parse(gig_parameters[:ends].to_s)
      gig_parameters
    end

    def create_performances(gig)
      gig_params[:performance_ids].each do |pid|
        if pid.length > 0
          ids = pid.split("_")
          gig.performances.build({musician_id: ids[0], instrument_id: ids[1]})
        end
      end
      gig_params.delete :performance_ids
    end

  end
end
