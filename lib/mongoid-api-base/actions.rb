# Holds all default actions for MongoidApiBase.
module MongoidApiBase
  module Actions
    extend ActiveSupport::Concern
    included do
      def index
        @chain = resource_class

        apply_scopes_to_chain!
        search_filter_chain!
        paginate_chain!
        set_total_count_header!

        respond_to do |format|
          format.json { render json: @chain.as_json(json_config(:index)) }
          format.csv  { render csv: @chain }
        end
      end

      def show
        object = find_object
        object = get_object_version(object)
        render json: object.as_json(json_config(:show))
      end

      def create
        object = build_object
        if object.save
          render json: object.as_json(json_config(:create))
        else
          render json: object.errors, status: :unprocessable_entity
        end
      end

      def update
        object = find_object
        if object.update_attributes(resource_params)
          render json: object.as_json(json_config(:update))
        else
          render json: object.errors, status: :unprocessable_entity
        end
      end

      def destroy
        object = find_object
        if object.destroy
          render nothing: true, status: 204
        else
          render json: object.errors, status: :unprocessable_entity
        end
      end
    end
  end
end
