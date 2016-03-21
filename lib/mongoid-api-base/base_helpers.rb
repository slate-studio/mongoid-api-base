# Base helpers for MongoidApiBase work. Some methods here can be overwritten and
# you will need to do that to customize your controllers.
module MongoidApiBase
  module BaseHelpers
    extend ActiveSupport::Concern
    included do
      def find_object
        resource_class.find(params[:id])
      end

      def get_object_version(object)
        version = params[:version]
        if version && object.respond_to?(:undo, true)
          object.undo(nil, from: version.to_i + 1, to: object.version)
          object.version = version
        end
        object
      end

      def build_object
        resource_class.new(resource_params)
      end

      def apply_scopes_to_chain!
        if respond_to?(:apply_scopes, true)
          @chain = apply_scopes(@chain)
        end
      end

      def search_filter_chain!
        query = params[:search]
        if query
          normalized_query = query.to_s.downcase
          @chain = @chain.search(normalized_query, match: :all)
        end
      end

      def page
        @page ||= params[:page] || false
      end

      def per_page
        @per_page ||= params[:perPage] || self.class.per_page || 20
      end

      def paginate_chain!
        @chain = begin
          if page
            @chain.page(page).per(per_page)
          else
            @chain.all
          end
        end
      end

      def set_total_count_header!
        if page
          response.headers['X-Total-Count'] = @chain.total_count
        else
          response.headers['X-Total-Count'] = @chain.size
        end
      end

      def resource_class
        @resource_class ||= self.class.resource_class
        @resource_class ||= begin
          namespaced_class = self.class.to_s.split("::").last.
                                  sub(/Controller$/, "").singularize
          namespaced_class.constantize
        end
      end

      def resource_request_name
        resource_class.to_s.underscore.gsub("/", "_").gsub("::", "_")
      end

      def resource_params
        permitted_params
      end

      def permitted_params
        params.require(resource_request_name).permit!
      end

      def json_default_options
        @json_default_options ||= begin
          default_options = {}
          json_options = self.class.json_options || {}
          [:only, :except, :methods].each do |name|
            if json_options.key? name
              default_options[name] = json_options[name]
            end
          end
          default_options[:methods] ||= []
          default_options[:methods].concat(JSON_DEFAULT_ATTRIBUTES).uniq!
          default_options
        end
      end

      def json_config(action)
        json_options = self.class.json_options
        if json_options && json_options.key?(action)
          json_options = json_options[action]
          json_options[:methods] ||= []
          json_options[:methods].concat(JSON_DEFAULT_ATTRIBUTES).uniq!
          json_options
        else
          json_default_options
        end
      end
    end
  end
end
