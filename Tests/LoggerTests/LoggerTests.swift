import XCTest
@testable import Logger

final class SpyLogger: LoggerClientProtocol {
  var messages: [(String, LogLevel)] = []

  func log(_ message: String, level: LogLevel) {
    messages.append((message, level))
  }
}

final class LoggerTests: XCTestCase {
  func testLoggerFansOutToAllClients() {
    let spy1 = SpyLogger()
    let spy2 = SpyLogger()
    let logger = Logger(clients: [spy1, spy2])

    logger.log("hello", level: .info)

    XCTAssertEqual(spy1.messages.count, 1)
    XCTAssertEqual(spy1.messages.first?.0, "hello")
    XCTAssertEqual(spy1.messages.first?.1, .info)

    XCTAssertEqual(spy2.messages.count, 1)
    XCTAssertEqual(spy2.messages.first?.0, "hello")
    XCTAssertEqual(spy2.messages.first?.1, .info)
  }

  func testAllLogLevels() {
    let spy = SpyLogger()
    let logger = Logger(clients: [spy])

    logger.log("d", level: .debug)
    logger.log("i", level: .info)
    logger.log("w", level: .warning)
    logger.log("e", level: .error)

    XCTAssertEqual(spy.messages.count, 4)
    XCTAssertEqual(spy.messages[0].1, .debug)
    XCTAssertEqual(spy.messages[1].1, .info)
    XCTAssertEqual(spy.messages[2].1, .warning)
    XCTAssertEqual(spy.messages[3].1, .error)
  }

  func testEmptyClientsDoesNotCrash() {
    let logger = Logger(clients: [])
    logger.log("no clients", level: .error)
  }

  func testFileLoggerWritesToFile() throws {
    let tempURL = FileManager.default.temporaryDirectory
      .appendingPathComponent("test_log_\(UUID().uuidString).log")
    let fileLogger = FileLogger(fileURL: tempURL)

    fileLogger.log("test message", level: .warning)

    let contents = try String(contentsOf: tempURL, encoding: .utf8)
    XCTAssertTrue(contents.contains("test message"))
    XCTAssertTrue(contents.contains(LogLevel.warning.rawValue))

    try FileManager.default.removeItem(at: tempURL)
  }
}
