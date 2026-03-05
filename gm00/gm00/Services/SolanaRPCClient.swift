import Foundation

enum SolanaCluster: String, CaseIterable, Identifiable {
    case devnet
    case testnet
    case mainnetBeta = "mainnet-beta"

    var id: String { rawValue }

    var url: URL {
        switch self {
        case .devnet: return URL(string: "https://doublezerolocalnet.rpcpool.com/8a4fd3f4-0977-449f-88c7-63d4b0f10f16")!
        case .testnet: return URL(string: "https://doublezerolocalnet.rpcpool.com/8a4fd3f4-0977-449f-88c7-63d4b0f10f16")!
        case .mainnetBeta: return URL(string: "https://doublezero-mainnet-beta.rpcpool.com/db336024-e7a8-46b1-80e5-352dd77060ab")!
        }
    }

    var programId: String {
        switch self {
        case .devnet: return "GYhQDKuESrasNZGyhMJhGYFtbzNijYhcrN9poSqCQVah"
        case .testnet: return "DZtnuQ839pSaDMFG5q1ad2V95G82S5EC4RrB3Ndw2Heb"
        case .mainnetBeta: return "ser2VaTMAcYTaauMrTSfSrxBaUDq7BLNs2xfUugTAGv"
        }
    }

    var displayName: String {
        switch self {
        case .devnet: return "Devnet"
        case .testnet: return "Testnet"
        case .mainnetBeta: return "Mainnet Beta"
        }
    }

    var telemetryProgramId: String {
        switch self {
        case .devnet: return "C9xqH76NSm11pBS6maNnY163tWHT8Govww47uyEmSnoG"
        case .testnet: return "3KogTMmVxc5eUHtjZnwm136H5P8tvPwVu4ufbGPvM7p1"
        case .mainnetBeta: return "tE1exJ5VMyoC9ByZeSmgtNzJCFF74G9JAv338sJiqkC"
        }
    }
}

enum RPCError: Error, LocalizedError {
    case networkError(Error)
    case httpError(Int)
    case rpcError(code: Int, message: String)
    case invalidResponse
    case accountNotFound
    case decodingError(String)

    var errorDescription: String? {
        switch self {
        case .networkError(let err): return "Network error: \(err.localizedDescription)"
        case .httpError(let code): return "HTTP error: \(code)"
        case .rpcError(let code, let msg): return "RPC error \(code): \(msg)"
        case .invalidResponse: return "Invalid RPC response"
        case .accountNotFound: return "Account not found"
        case .decodingError(let msg): return "Decoding error: \(msg)"
        }
    }
}

actor SolanaRPCClient {
    private let session: URLSession
    private var rpcURL: URL
    private(set) var programId: String
    private var requestId: Int = 0

    init(cluster: SolanaCluster) {
        self.rpcURL = cluster.url
        self.programId = cluster.programId
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }

    init(url: URL, programId: String) {
        self.rpcURL = url
        self.programId = programId
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }

    func updateCluster(_ cluster: SolanaCluster) {
        self.rpcURL = cluster.url
        self.programId = cluster.programId
    }

    func updateCustom(url: URL, programId: String) {
        self.rpcURL = url
        self.programId = programId
    }

    private func nextId() -> Int {
        requestId += 1
        return requestId
    }

    private func makeRequest(method: String, params: [Any]) async throws -> Any {
        let body: [String: Any] = [
            "jsonrpc": "2.0",
            "id": nextId(),
            "method": method,
            "params": params
        ]

        var request = URLRequest(url: rpcURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw RPCError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw RPCError.httpError(httpResponse.statusCode)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw RPCError.invalidResponse
        }

        if let error = json["error"] as? [String: Any] {
            let code = error["code"] as? Int ?? -1
            let message = error["message"] as? String ?? "Unknown error"
            throw RPCError.rpcError(code: code, message: message)
        }

        guard let result = json["result"] else {
            throw RPCError.invalidResponse
        }

        return result
    }

    func getAccountInfo(pubkey: String) async throws -> Data {
        let params: [Any] = [
            pubkey,
            ["encoding": "base64"] as [String: Any]
        ]

        let result = try await makeRequest(method: "getAccountInfo", params: params)

        guard let resultDict = result as? [String: Any],
              let value = resultDict["value"] as? [String: Any],
              let dataArray = value["data"] as? [Any],
              let base64String = dataArray.first as? String,
              let data = Data(base64Encoded: base64String) else {
            throw RPCError.accountNotFound
        }

        return data
    }

    func getProgramAccounts(programId explicitProgramId: String, filters: [[String: Any]] = []) async throws -> [(pubkey: String, data: Data)] {
        let params: [Any] = [
            explicitProgramId,
            [
                "encoding": "base64",
                "filters": filters
            ] as [String: Any]
        ]

        let result = try await makeRequest(method: "getProgramAccounts", params: params)

        guard let accounts = result as? [[String: Any]] else {
            throw RPCError.invalidResponse
        }

        var decoded: [(pubkey: String, data: Data)] = []
        for account in accounts {
            guard let pubkey = account["pubkey"] as? String,
                  let accountInfo = account["account"] as? [String: Any],
                  let dataArray = accountInfo["data"] as? [Any],
                  let base64String = dataArray.first as? String,
                  let data = Data(base64Encoded: base64String) else {
                continue
            }
            decoded.append((pubkey: pubkey, data: data))
        }

        return decoded
    }

    func getProgramAccounts(filters: [[String: Any]] = []) async throws -> [(pubkey: String, data: Data)] {
        try await getProgramAccounts(programId: programId, filters: filters)
    }

    func getMultipleAccounts(pubkeys: [String]) async throws -> [(pubkey: String, data: Data?)] {
        // Solana limits getMultipleAccounts to 100 per call
        var allResults: [(pubkey: String, data: Data?)] = []

        for chunk in pubkeys.chunked(into: 100) {
            let params: [Any] = [
                chunk,
                ["encoding": "base64"] as [String: Any]
            ]

            let result = try await makeRequest(method: "getMultipleAccounts", params: params)

            guard let resultDict = result as? [String: Any],
                  let values = resultDict["value"] as? [Any?] else {
                throw RPCError.invalidResponse
            }

            for (i, value) in values.enumerated() {
                if let accountInfo = value as? [String: Any],
                   let dataArray = accountInfo["data"] as? [Any],
                   let base64String = dataArray.first as? String,
                   let data = Data(base64Encoded: base64String) {
                    allResults.append((pubkey: chunk[i], data: data))
                } else {
                    allResults.append((pubkey: chunk[i], data: nil))
                }
            }
        }

        return allResults
    }

    func getDevicesForLocation(pubkey: String) async throws -> [(pubkey: String, data: Data)] {
        let filters: [[String: Any]] = [
            ["memcmp": ["offset": 0, "bytes": Base58.encode(Data([AccountTypeDiscriminator.device]))] as [String: Any]],
            ["memcmp": ["offset": 50, "bytes": pubkey] as [String: Any]]
        ]
        return try await getProgramAccounts(filters: filters)
    }

    func getDevicesForExchange(pubkey: String) async throws -> [(pubkey: String, data: Data)] {
        let filters: [[String: Any]] = [
            ["memcmp": ["offset": 0, "bytes": Base58.encode(Data([AccountTypeDiscriminator.device]))] as [String: Any]],
            ["memcmp": ["offset": 82, "bytes": pubkey] as [String: Any]]
        ]
        return try await getProgramAccounts(filters: filters)
    }

    func getAccountsByType(_ accountType: UInt8) async throws -> [(pubkey: String, data: Data)] {
        let filters: [[String: Any]] = [
            [
                "memcmp": [
                    "offset": 0,
                    "bytes": Base58.encode(Data([accountType]))
                ] as [String: Any]
            ]
        ]
        return try await getProgramAccounts(filters: filters)
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
