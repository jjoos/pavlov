require_relative 'concern'
require 'pavlov/helpers'
require 'virtus'
require_relative 'access_denied'

module Pavlov
  class ValidationError < StandardError
  end

  module Operation
    extend Pavlov::Concern
    include Pavlov::Helpers
    include Virtus.module

    def valid?
      check_validation
      true
    rescue Pavlov::ValidationError
      false
    end

    def call(*args, &block)
      check_validation
      check_authorization
      execute(*args, &block)
    end

    private

    def check_authorization
      raise_unauthorized unless authorized?
    end

    def raise_unauthorized(message = 'Unauthorized')
      raise Pavlov::AccessDenied, message
    end

    def raise_on_argument_missing
      if missing_arguments.any?
        error_message = missing_arguments.map do |argument|
          "#{argument.name} should not be empty"
        end.join(', ')

        raise Pavlov::ValidationError,  error_message
      end
    end

    def check_validation
      raise_on_argument_missing

      validate
    end

    def missing_arguments
      attribute_set.select do |attribute|
        !attribute.options.has_key?(:default) && send(attribute.name).nil?
      end
    end

    def validate
      # no-op, users should override this
    end

    module ClassMethods
      # make our interactors behave as Resque jobs
      def perform(*args)
        new(*args).call
      end

      def queue
        @queue || :interactor_operations
      end
    end
  end
end
