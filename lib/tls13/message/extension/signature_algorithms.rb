# encoding: ascii-8bit
# frozen_string_literal: true

module TLS13
  using Refinements
  module Message
    module Extension
      class SignatureAlgorithms
        DEFAULT_SIGNATURE_ALGORITHMS = [
          SignatureScheme::ECDSA_SECP256R1_SHA256,
          SignatureScheme::ECDSA_SECP384R1_SHA384,
          SignatureScheme::ECDSA_SECP521R1_SHA512,
          SignatureScheme::RSA_PSS_PSS_SHA256,
          SignatureScheme::RSA_PSS_PSS_SHA384,
          SignatureScheme::RSA_PSS_PSS_SHA512,
          SignatureScheme::RSA_PSS_RSAE_SHA256,
          SignatureScheme::RSA_PSS_RSAE_SHA384,
          SignatureScheme::RSA_PSS_RSAE_SHA512,
          SignatureScheme::RSA_PKCS1_SHA256,
          SignatureScheme::RSA_PKCS1_SHA384,
          SignatureScheme::RSA_PKCS1_SHA512
        ].freeze

        attr_accessor :extension_type # for signature_algorithms_cert getter
        attr_reader   :supported_signature_algorithms

        # @param supported_signature_algorithms [Array of SignatureScheme]
        def initialize(supported_signature_algorithms)
          @extension_type = ExtensionType::SIGNATURE_ALGORITHMS
          @supported_signature_algorithms = supported_signature_algorithms || []
          raise Error::TLSError, :internal_error \
            if @supported_signature_algorithms.empty? ||
               @supported_signature_algorithms.length * 2 > 2**16 - 3
        end

        # @return [String]
        def serialize
          binary = @supported_signature_algorithms.join

          @extension_type + binary.prefix_uint16_length.prefix_uint16_length
        end

        # @param binary [String]
        #
        # @raise [TLS13::Error::TLSError]
        #
        # @return [TLS13::Message::Extensions::SignatureAlgorithms, nil]
        def self.deserialize(binary)
          raise Error::TLSError, :internal_error if binary.nil?

          return nil if binary.length < 2

          ssa_len = Convert.bin2i(binary.slice(0, 2))
          i = 2
          supported_signature_algorithms = []
          while i < ssa_len + 2
            return nil if i + 2 > binary.length

            supported_signature_algorithms << binary.slice(i, 2)
            i += 2
          end
          return nil unless ssa_len + 2 == binary.length

          SignatureAlgorithms.new(supported_signature_algorithms)
        end
      end
    end
  end
end
