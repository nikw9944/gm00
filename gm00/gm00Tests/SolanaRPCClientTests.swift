import XCTest
@testable import gm00

final class SolanaRPCClientTests: XCTestCase {

    func testClusterURLs() {
        XCTAssertEqual(SolanaCluster.devnet.url.absoluteString, "https://api.devnet.solana.com")
        XCTAssertEqual(SolanaCluster.testnet.url.absoluteString, "https://api.testnet.solana.com")
        XCTAssertEqual(SolanaCluster.mainnetBeta.url.absoluteString, "https://api.mainnet-beta.solana.com")
    }

    func testClusterProgramIds() {
        XCTAssertEqual(SolanaCluster.devnet.programId, "GYhQDKuESrasNZGyhMJhGYFtbzNijYhcrN9poSqCQVah")
        XCTAssertEqual(SolanaCluster.testnet.programId, "DZtnuQ839pSaDMFG5q1ad2V95G82S5EC4RrB3Ndw2Heb")
        XCTAssertEqual(SolanaCluster.mainnetBeta.programId, "ser2VaTMAcYTaauMrTSfSrxBaUDq7BLNs2xfUugTAGv")
    }

    func testClusterDisplayNames() {
        XCTAssertEqual(SolanaCluster.devnet.displayName, "Devnet")
        XCTAssertEqual(SolanaCluster.testnet.displayName, "Testnet")
        XCTAssertEqual(SolanaCluster.mainnetBeta.displayName, "Mainnet Beta")
    }

    func testArrayChunked() {
        let array = [1, 2, 3, 4, 5, 6, 7]
        let chunks = array.chunked(into: 3)
        XCTAssertEqual(chunks.count, 3)
        XCTAssertEqual(chunks[0], [1, 2, 3])
        XCTAssertEqual(chunks[1], [4, 5, 6])
        XCTAssertEqual(chunks[2], [7])
    }

    func testArrayChunkedExactDivision() {
        let array = [1, 2, 3, 4, 5, 6]
        let chunks = array.chunked(into: 3)
        XCTAssertEqual(chunks.count, 2)
        XCTAssertEqual(chunks[0], [1, 2, 3])
        XCTAssertEqual(chunks[1], [4, 5, 6])
    }

    func testArrayChunkedEmpty() {
        let array: [Int] = []
        let chunks = array.chunked(into: 3)
        XCTAssertTrue(chunks.isEmpty)
    }

    func testRPCErrorDescriptions() {
        let networkErr = RPCError.networkError(URLError(.notConnectedToInternet))
        XCTAssertTrue(networkErr.localizedDescription.contains("Network error"))

        let httpErr = RPCError.httpError(429)
        XCTAssertTrue(httpErr.localizedDescription.contains("429"))

        let rpcErr = RPCError.rpcError(code: -32600, message: "Invalid request")
        XCTAssertTrue(rpcErr.localizedDescription.contains("Invalid request"))

        let notFound = RPCError.accountNotFound
        XCTAssertTrue(notFound.localizedDescription.contains("not found"))
    }
}
