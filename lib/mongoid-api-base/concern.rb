# =============================================================================
# MongoidApiBase
# Rails concern to implement API controllers for Mongoid models.
# -----------------------------------------------------------------------------
# Usage Example:
#
#   include MongoidApiBase
#
#   defaults resource_class: Journal::JournalPost,
#            per_page: 30
#
#   has_scope :by_category
#   has_scope :hidden,     type: :boolean
#   has_scope :not_hidden, type: :boolean
#
#   json_config methods: %w(hex slug sorted_categories opengraph_image_url meta_title meta_description),
#               index: {
#                 except:  %w(body_markdown body_html),
#                 methods: %w(hex slug)
#               }
# =============================================================================
module MongoidApiBase
  extend ActiveSupport::Concern
  included do
    respond_to :json
    respond_to :csv, only: %w(index)

    class_attribute :resource_class
    class_attribute :per_page
    class_attribute :csv_options
    class_attribute :json_options

    def index
      @chain = resource_class

      apply_scopes_to_chain!
      search_filter_chain!
      paginate_chain!
      set_total_count_header!

      respond_to do |format|
        format.json { render json: @chain.as_json(json_config(:index)) }
        format.csv { render csv: @chain }
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
        render nothing: true
      else
        render json: object.errors, status: :unprocessable_entity
      end
    end

    def find_object
      resource_class.find(params[:id])
    end

    def get_object_version(object)
      version = params[:version]
      if version && object.respond_to?(:undo, true)
        object.undo(nil, from: version.to_i + 1, to: resource.version)
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
      @page ||= params[:page] || 1
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

    def json_default_methods
      [ :_list_item_title,
        :_list_item_subtitle,
        :_list_item_thumbnail,
        :_document_versions ]
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
        default_options[:methods].concat(json_default_methods).uniq!
        default_options
      end
    end

    def json_config(action)
      json_options = self.class.json_options
      if json_options && json_options.key?(action)
        json_options = json_options[action]
        json_options[:methods] ||= []
        json_options[:methods].concat(json_default_methods).uniq!
        json_options
      else
        json_default_options
      end
    end
  end

  class_methods do
    def defaults(options)
      if options.key?(:resource_class)
        self.resource_class = options[:resource_class]
      end

      if options.key?(:per_page)
        self.resource_class = options[:per_page]
      end
    end

    def csv_config(options={})
      self.csv_options = options
    end

    def json_config(options)
      self.json_options = options
    end
  end
end
