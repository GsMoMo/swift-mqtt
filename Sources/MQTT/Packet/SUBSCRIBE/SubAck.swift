import Foundation

/// # Reference
/// [SUBACK – Subscribe acknowledgement](http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.html#_Toc398718068)
public final class SubAckPacket: MQTTPacket {
    private let variableHeader: VariableHeader

    public let returnCodes: [ReturnCode]

    public var identifier: UInt16 {
        variableHeader.identifier
    }

    init(fixedHeader: FixedHeader, data: inout Data) throws {
        guard data.hasSize(2) else {
            throw DecodeError.malformedData
        }
        variableHeader = VariableHeader(identifier: data.read2BytesInt())
        returnCodes = try data.map { try ReturnCode(code: $0) }
        super.init(fixedHeader: fixedHeader)
    }
}

extension SubAckPacket {
    public enum ReturnCode: Equatable {
        case success(QoS)
        case failure

        init(code: UInt8) throws {
            switch code {
            case 0x00, 0x01, 0x02:
                self = .success(try QoS(value: code))
            case 0x80:
                self = .failure
            default:
                throw DecodeError.malformedSubAckReturnCode
            }
        }

        public static func == (lhs: ReturnCode, rhs: ReturnCode) -> Bool {
            switch (lhs, rhs) {
            case (.failure, .failure):
                return true
            case let (.success(qosL), .success(qosR)):
                return qosL == qosR
            default:
                return false
            }
        }
    }

    struct VariableHeader {
        let identifier: UInt16
    }
}
