# EXTRA LINKS:
# - https://github.com/OAI/OpenAPI-Specification/blob/master/versions/2.0.md
# - https://github.com/fotinakis/swagger-blocks
# - https://github.com/westfieldlabs/apivore
# - https://github.com/notonthehighstreet/svelte

module SwaggerGenerator
  extend ActiveSupport::Concern

  included do
    include Swagger::Blocks
  end

  class_methods do
    REJECT_NAMES = %w(_id _keywords created_at updated_at).freeze
    ALLOW_TYPES  = %w(Object String)

    def generate_swagger
      generate_swagger_schemas
      generate_swagger_paths
    end

    def collection_name
      @collection_name ||= to_s.split("::").last.sub(/Controller$/, '')
    end

    def resource_name
      @resource_name ||= collection_name.singularize
    end

    def generate_swagger_schemas
      name = resource_name

      if resource_class
        # TODO: add support for resource class option
      else
        resource_class = name.constantize
      end

      swagger_schema name do
        # TODO: autogenerate list of required fields
        # key :required, %w(name email)

        resource_class.fields.each do |name, options|
          type = options.type.to_s
          if ALLOW_TYPES.include? type
            unless REJECT_NAMES.include? name
              property name do
                key :type, :string
                # TODO: autodetect property type
                # key :format, 'date-time'
              end
            end
          end
        end
      end
    end

    def generate_swagger_paths
      name   = resource_name
      plural = collection_name
      path   = plural.underscore
      tags   = [ plural ]

      swagger_path "/#{ path }" do
        operation :get do
          key :tags, tags
          key :operationId, "index#{ plural }"
          key :produces, %w(application/json text/csv)

          parameter do
            key :name,     :page
            key :in,       :query
            key :required, false
            key :type,     :integer
            key :format,   :int32
          end

          parameter do
            key :name,     :perPage
            key :in,       :query
            key :required, false
            key :type,     :integer
            key :format,   :int32
          end

          parameter do
            key :name,     :search
            key :in,       :query
            key :required, false
            key :type,     :string
          end

          response 200 do
            schema type: :array do
              items do
                key :'$ref', name
              end
            end
          end
        end

        operation :post do
          key :tags, tags
          key :operationId, "create#{ plural }"
          key :produces,    %w(application/json)
          parameter do
            key :name,     name.underscore.to_sym
            key :in,       :form
            key :required, true
            schema do
              key :'$ref', name # input
            end
          end
          response 200 do
            schema do
              key :'$ref', name
            end
          end
        end
      end

      swagger_path "/#{ path }/{id}" do
        operation :get do
          key :tags, tags
          key :operationId, "show#{ name }ById"
          key :produces,    %w(application/json)
          parameter do
            key :name,     :id
            key :in,       :path
            key :required, true
            key :type,     :string
          end
          response 200 do
            schema do
              key :'$ref', name
            end
          end
        end

        operation :put do
          key :tags, tags
          key :operationId, "update#{ name }"
          key :produces,    %w(application/json)
          parameter do
            key :name,     :id
            key :in,       :path
            key :required, true
            key :type,     :string
          end
          parameter do
            key :name,     name.underscore.to_sym
            key :in,       :form
            key :required, true
            schema do
              key :'$ref', name # input
            end
          end
          response 200 do
            schema do
              key :'$ref', name
            end
          end
        end

        operation :delete do
          key :tags, tags
          key :operationId, "delete#{ name }"
          parameter do
            key :name,     :id
            key :in,       :path
            key :required, true
            key :type,     :string
          end
          response 204 do
            key :description, "#{ name } deleted"
          end
        end
      end
    end
  end
end
