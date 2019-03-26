# encoding: ascii-8bit
# frozen_string_literal: true

module TLS13
  module Message
    module Extension
      class UknownExtension
        attr_accessor :extension_type
        attr_accessor :extension_data

        # @param extension_type [String]
        # @param extension_data [String]
        #
        # @raise [RuntimeError]
        def initialize(extension_type:, extension_data: '')
          @extension_type = extension_type
          @extension_data = extension_data || ''
        end

        # @return [String]
        def serialize
          @extension_type + uint16_length_prefix(@extension_data)
        end

        # @param binary [String]
        # @param extension_type [String]
        #
        # @return [TLS13::Message::Extension::UknownExtension]
        def self.deserialize(binary, extension_type)
          UknownExtension.new(extension_type: extension_type,
                              extension_data: binary)
        end
      end
    end
  end
end
