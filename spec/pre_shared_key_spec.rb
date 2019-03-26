# encoding: ascii-8bit
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PreSharedKey do
  context 'valid pre_shared_key of ClientHello' do
    let(:identity) do
      OpenSSL::Random.random_bytes(32)
    end

    let(:obfuscated_ticket_age) do
      OpenSSL::BN.rand_range(1 << 32).to_i
    end

    let(:binders) do
      [
        OpenSSL::Random.random_bytes(32)
      ]
    end

    let(:identities) do
      [
        PskIdentity.new(
          identity: identity,
          obfuscated_ticket_age: obfuscated_ticket_age
        )
      ]
    end

    let(:offered_psks) do
      OfferedPsks.new(
        identities: identities,
        binders: binders
      )
    end

    let(:extension) do
      PreSharedKey.new(msg_type: HandshakeType::CLIENT_HELLO,
                       offered_psks: offered_psks)
    end

    it 'should be generated' do
      expect(extension.msg_type).to eq HandshakeType::CLIENT_HELLO
      expect(extension.extension_type).to eq ExtensionType::PRE_SHARED_KEY
      expect(extension.offered_psks).to eq offered_psks
      expect(extension.selected_identity).to be_nil
    end

    it 'should be serialized' do
      expect(extension.serialize).to eq ExtensionType::PRE_SHARED_KEY \
                                        + i2uint16(75) \
                                        + i2uint16(38) \
                                        + i2uint16(32) \
                                        + identity \
                                        + i2uint32(obfuscated_ticket_age) \
                                        + i2uint16(33) \
                                        + "\x20" \
                                        + binders.join
    end
  end

  context 'valid pre_shared_key, ClientHello,' do
    let(:identity_1) do
      OpenSSL::Random.random_bytes(32)
    end
    let(:identity_2) do
      OpenSSL::Random.random_bytes(32)
    end

    let(:obfuscated_ticket_age_1) do
      OpenSSL::BN.rand_range(1 << 32).to_i
    end
    let(:obfuscated_ticket_age_2) do
      OpenSSL::BN.rand_range(1 << 32).to_i
    end

    let(:binders) do
      [
        OpenSSL::Random.random_bytes(32),
        OpenSSL::Random.random_bytes(32)
      ]
    end

    let(:identities) do
      [
        PskIdentity.new(
          identity: identity_1,
          obfuscated_ticket_age: obfuscated_ticket_age_1
        ),
        PskIdentity.new(
          identity: identity_2,
          obfuscated_ticket_age: obfuscated_ticket_age_2
        )
      ]
    end

    let(:offered_psks) do
      OfferedPsks.new(
        identities: identities,
        binders: binders
      )
    end

    let(:extension) do
      PreSharedKey.new(msg_type: HandshakeType::CLIENT_HELLO,
                       offered_psks: offered_psks)
    end

    it 'should be generated' do
      expect(extension.msg_type).to eq HandshakeType::CLIENT_HELLO
      expect(extension.extension_type).to eq ExtensionType::PRE_SHARED_KEY
      expect(extension.offered_psks).to eq offered_psks
      expect(extension.selected_identity).to be_nil
    end

    it 'should be serialized' do
      expect(extension.serialize).to eq ExtensionType::PRE_SHARED_KEY \
                                        + i2uint16(146) \
                                        + i2uint16(76) \
                                        + uint16_length_prefix(identity_1) \
                                        + i2uint32(obfuscated_ticket_age_1) \
                                        + uint16_length_prefix(identity_2) \
                                        + i2uint32(obfuscated_ticket_age_2) \
                                        + i2uint16(66) \
                                        + uint8_length_prefix(binders[0]) \
                                        + uint8_length_prefix(binders[1])
    end
  end

  context 'valid pre_shared_key binary' do
    let(:extension) do
      PreSharedKey.deserialize(TESTBINARY_PRE_SHARED_KEY,
                               HandshakeType::CLIENT_HELLO)
    end

    it 'should generate valid object' do
      expect(extension.msg_type).to eq HandshakeType::CLIENT_HELLO
      expect(extension.extension_type).to eq ExtensionType::PRE_SHARED_KEY
    end

    it 'should generate valid serializable object' do
      expect(extension.serialize).to eq ExtensionType::PRE_SHARED_KEY \
                                        + uint16_length_prefix(
                                          TESTBINARY_PRE_SHARED_KEY
                                        )
    end
  end
end
