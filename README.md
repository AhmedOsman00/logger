# Logger

A lightweight, protocol-based logging library for Swift. Supports iOS 14+, macOS 11+, tvOS 14+, and watchOS 7+.

## Features

- **Multi-client fan-out** -- a single `Logger` dispatches every message to all registered clients.
- **Built-in clients** -- `ConsoleLogger` (stdout) and `FileLogger` (append to file on disk).
- **Extensible** -- conform to `LoggerClientProtocol` to add custom destinations (analytics, crash reporters, remote servers, etc.).
- **Four log levels** -- `debug`, `info`, `warning`, `error`.

## Installation

Add the package to your `Package.swift` dependencies:

```swift
dependencies: [
  .package(url: "https://github.com/AhmedOsman00/logger", from: "<version>"),
]
```

Then add `"Logger"` to the target that needs it:

```swift
.product(name: "Logger", package: "logger"),
```

## Quick Start

```swift
import Logger

// Console only (default)
let logger = Logger()
logger.log("App launched", level: .info)

// Console + file
let fileLogger = FileLogger(fileURL: URL(fileURLWithPath: "/tmp/app.log"))
let logger = Logger(clients: [ConsoleLogger(), fileLogger])
logger.log("Something went wrong", level: .error)
```

## Custom Logging Clients

Conform to `LoggerClientProtocol` to create your own destination:

```swift
struct RemoteLogger: LoggerClientProtocol {
  func log(_ message: String, level: LogLevel) {
    // send to your remote logging service
  }
}

let logger = Logger(clients: [ConsoleLogger(), RemoteLogger()])
```

## Log Levels

| Level     | Emoji | Typical Use                     |
|-----------|-------|---------------------------------|
| `debug`   | `🔍`  | Verbose development-time info   |
| `info`    | `📋`  | General operational messages    |
| `warning` | `⚠️`  | Potential issues                |
| `error`   | `❌`  | Failures requiring attention    |

## Testing

```bash
swift test
```

## License

See [LICENSE](LICENSE) for details.
