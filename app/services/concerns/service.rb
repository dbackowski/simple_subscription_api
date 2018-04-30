module Service
  extend ActiveSupport::Concern

  class_methods do
    def call(*args)
      new(*args).call
    end
  end

  included do
    private

    def response_struct(success, response, errors)
      OpenStruct.new(success?: success, response: response, errors: errors)
    end
  end
end