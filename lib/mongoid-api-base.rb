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
# -----------------------------------------------------------------------------
# Some more ideas for future improvements can be pulled from here:
#  - https://github.com/jamesgolick/resource_controller
# =============================================================================

require 'kaminari'
require 'csv'
require 'action_controller/metal/renderers'
require 'renderers/csv'
require 'swagger/blocks'
require 'swagger/generator'
require 'mongoid-api-base/actions'
require 'mongoid-api-base/base_helpers'
require 'mongoid-api-base/version'

module MongoidApiBase
  extend ActiveSupport::Concern
  included do
    respond_to :json
    respond_to :csv, only: %w(index)

    class_attribute :resource_class
    class_attribute :per_page
    class_attribute :csv_options
    class_attribute :json_options

    JSON_DEFAULT_ATTRIBUTES = [ :created_at,
                                :updated_at,
                                :slug,
                                :_position,
                                :_list_item_title,
                                :_list_item_subtitle,
                                :_list_item_thumbnail,
                                :_document_versions ].freeze

    include Actions
    include BaseHelpers
  end

  class_methods do
    def defaults(options)
      if options.key?(:resource_class)
        self.resource_class = options[:resource_class]
      end

      if options.key?(:per_page)
        self.per_page = options[:per_page]
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
