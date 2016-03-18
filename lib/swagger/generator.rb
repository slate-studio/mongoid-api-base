module SwaggerGenerator
  extend ActiveSupport::Concern

  included do
    include Swagger::Blocks
  end

  class_methods do
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
      #   key :required, %w(name email)

      #   property :created_at do
      #     key :type,   :string
      #     key :format, 'date-time'
      #   end

      #   property :updated_at do
      #     key :type,   :string
      #     key :format, 'date-time'
      #   end

      #   property :name do
      #     key :type, :string
      #   end

      #   property :email do
      #     key :type, :string
      #   end
      end

      # swagger_schema :UserInput do
      #   key :required, %w(name email password password_confirmation)

      #   property :name do
      #     key :type, :string
      #   end

      #   property :email do
      #     key :type, :string
      #   end

      #   property :password do
      #     key :type,   :string
      #     key :format, :password
      #   end

      #   property :password_confirmation do
      #     key :type,   :string
      #     key :format, :password
      #   end
      # end
    end

    def generate_swagger_paths
      name   = resource_name
      plural = collection_name
      path   = plural.underscore
      tag    = path.singularize
      tags   = [ tag ]

      swagger_path "/#{ path }.json" do
        operation :get do
          key :tags, tags
          key :operationId, "find#{ plural }"
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
          key :operationId, "add#{ plural }"
          key :produces,    %w(application/json)
          parameter do
            key :name,     :user
            key :in,       :body
            key :required, true
            # schema do
            #   key :'$ref', :UserInput
            # end
          end
          response 200 do
            schema do
              key :'$ref', name
            end
          end
        end
      end

      swagger_path "/#{ path }/{id}.json" do
        operation :get do
          key :tags, tags
          key :operationId, "find#{ name }ById"
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
            key :name,     :user
            key :in,       :body
            key :required, true
            # schema do
            #   key :'$ref', :UserInput
            # end
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
            key :description, "#{ tag } deleted"
          end
        end
      end
    end
  end
end
