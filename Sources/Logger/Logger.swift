import Foundation

/// Severity level for log messages.
///
/// Each case carries an emoji used as a visual prefix in formatted output.
public enum LogLevel: Sendable, Equatable {
  case debug
  case info
  case warning
  case error
  case custom(String)

  var rawValue: String {
    switch self {
    case .debug: "🔍"
    case .info: "📋"
    case .warning: "⚠️"
    case .error: "❌"
    case let .custom(string): string
    }
  }
}

/// A type that can receive log messages.
///
/// Conform to this protocol to create custom logging destinations
/// (e.g. remote servers, analytics services, crash reporters).
///
/// ```swift
/// struct AnalyticsLogger: LoggerClientProtocol {
///   func log(_ message: String, level: LogLevel) {
///     AnalyticsService.track(event: message, severity: level.rawValue)
///   }
/// }
/// ```
public protocol LoggerClientProtocol {
  /// Logs a message at the given severity level.
  ///
  /// - Parameters:
  ///   - message: The log message.
  ///   - level: The severity level of the message.
  func log(_ message: String, level: LogLevel)
}

/// A logging client that prints timestamped messages to standard output.
///
/// Output format: `[yyyy-MM-dd HH:mm:ss.SSS] [<emoji>] <message>`
public struct ConsoleLogger: LoggerClientProtocol {
  private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    return formatter
  }()

  /// Creates a new console logger.
  public init() {}

  public func log(_ message: String, level: LogLevel) {
    let timestamp = dateFormatter.string(from: Date())
    print("[\(timestamp)] [\(level.rawValue)] \(message)")
  }
}

/// A logging client that appends timestamped messages to a file on disk.
///
/// The file is created automatically if it does not already exist.
///
/// Output format (per line): `[yyyy-MM-dd HH:mm:ss.SSS] [<emoji>] <message>`
public struct FileLogger: LoggerClientProtocol {
  private let fileURL: URL
  private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    return formatter
  }()

  /// Creates a new file logger.
  ///
  /// - Parameter fileURL: The URL of the log file. Created if it does not exist.
  public init(fileURL: URL) {
    self.fileURL = fileURL
    if !FileManager.default.fileExists(atPath: fileURL.path) {
      FileManager.default.createFile(atPath: fileURL.path, contents: nil)
    }
  }

  public func log(_ message: String, level: LogLevel) {
    let timestamp = dateFormatter.string(from: Date())
    let line = "[\(timestamp)] [\(level.rawValue)] \(message)\n"
    guard let data = line.data(using: .utf8),
          let handle = try? FileHandle(forWritingTo: fileURL) else { return }
    handle.seekToEndOfFile()
    handle.write(data)
    handle.closeFile()
  }
}

/// A multi-client logger that fans out each log call to all registered clients.
///
/// `Logger` itself conforms to ``LoggerClientProtocol``, so it can be nested
/// inside other loggers if needed.
///
/// ```swift
/// let logger = Logger(clients: [ConsoleLogger(), FileLogger(fileURL: url)])
/// logger.log("App launched", level: .info)
/// ```
public struct Logger {
  /// The logging clients that receive every message.
  public let clients: [LoggerClientProtocol]

  /// Creates a logger with the given clients.
  ///
  /// - Parameter clients: An array of logging destinations. Defaults to a single ``ConsoleLogger``.
  public init(clients: [LoggerClientProtocol] = [ConsoleLogger()]) {
    self.clients = clients
  }
}

extension Logger: LoggerClientProtocol {
  public func log(_ message: String, level: LogLevel) {
    clients.forEach { $0.log(message, level: level) }
  }
}
