require 'pavlov'

module Pavlov
  def self.old_command command_name, *args
    class_name = "Commands::"+string_to_classname(command_name)
    klass = get_class_by_string(class_name)
    attributes = arguments_to_attributes(klass, args)
    klass.new(attributes).call
  end

  def self.old_interactor command_name, *args
    class_name = "Interactors::"+string_to_classname(command_name)
    klass = get_class_by_string class_name
    attributes = arguments_to_attributes(klass, args)
    klass.new(attributes).call
  end

  def self.old_query command_name, *args
    class_name = "Queries::"+string_to_classname(command_name)
    klass = get_class_by_string class_name
    attributes = arguments_to_attributes(klass, args)
    klass.new(attributes).call
  end

  def self.arguments_to_attributes(operation_class, arguments)
    attribute_keys = operation_class.attribute_set.map(&:name)

    # TODO: this can be done so much better, but I don't know how.
    hash={}
    arguments.each_with_index do |value, index|
      hash[attribute_keys[index].to_sym] = value
    end
    return hash
  end

  module Helpers
    def old_interactor name, *args
      args = add_compatablity_pavlov_options args
      Pavlov.old_interactor name, *args
    end

    def old_query name, *args
      args = add_compatablity_pavlov_options args
      Pavlov.old_query name, *args
    end

    def old_command name, *args
      args = add_compatablity_pavlov_options args
      Pavlov.old_command name, *args
    end

    private
    def add_compatablity_pavlov_options args
      # TODO: we should do this at a point where we know how many arguments we need
      # so we can decide if we need to merge with another options object or
      # just add it.
      new_args = Array(args)
      if pavlov_options != {}
        new_args << pavlov_options
      end
      new_args
    end
  end

  module Operation
    module ClassMethods
      def arguments(*args)
        # Add generic attribute for each argument
        args.each do |argument|
          attribute argument, Object
        end

        # Add attribute for pavlov_options
        attribute :pavlov_options, Hash, default: {}
      end
    end
  end
end
