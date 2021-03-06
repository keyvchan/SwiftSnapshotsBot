// It just works.
// There are various bug need to solve.
import AsyncHTTPClient
import ConsoleKit
import Foundation
import Logging
import SwiftDate
import SwiftSoup
import SwiftyJSON

// Using logger to print log to console.
LoggingSystem.bootstrap { _ in
    let console = Terminal()
    let consoleLogger = ConsoleLogger(label: "keyvchan", console: console)
    return consoleLogger
}

var logger = Logger(label: "keyvchan")
logger.logLevel = .error

let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)

// TODO: Get all arguments from a specific file or command line.
// let API_Token: String = CommandLine.arguments[1]
let API_Token: String = ProcessInfo.processInfo.environment["SWIFT_SNAPSHOTS_BOT_API_TOKEN"]!
let ChatID: String = "-1001405329947"
let Action: String = "sendMessage"

let SwiftDownloadPageURL = "https://swift.org/download/"
let currentRegion = Region(calendar: Calendars.gregorian, zone: Zones.current, locale: Locales.current)

// FIXME: Figure out how to share a global variable between closures gracefully.
class Test { var lastReleaseDate: DateInRegion = "0000000".toDate(region: currentRegion)! }
var test: Test = Test()

// TODO: Customize the http headers to make everything clearly
var SwiftWebPage = try HTTPClient.Request(url: SwiftDownloadPageURL, method: .GET)
SwiftWebPage.headers.add(name: "User-Agent", value: "Swift HTTPClient")

// TODO: There is a uncleanShutdown occuring sometimes.
while true {
    // TODO:
    //      - Make code more readable, such as extracting code to smaller functions.
    //      - Make full use of swift-log. The log should be human readable.
    httpClient.execute(request: SwiftWebPage).whenComplete { result in
        switch result {
        case let .failure(error):
            logger.error("\(error)")
        case let .success(response):
            if var body = response.body {
                if let content = body.readString(length: body.readableBytes) {
                    do {
                        let html: String = content
                        let doc: Document = try SwiftSoup.parse(html)
                        let time: Element = try doc.select("body main #trunk-development-master+p+table tbody tr td time").first()!
                        let link: Element = try doc.select("body main #trunk-development-master+p+table tbody tr td span a").first()!

                        let linkOfLinux: Element = try doc.select("body main #trunk-development-master+p+table tbody tr+tr+tr+tr td span a").first()!

                        let date = try time.attr("datetime")
                        var downloadLink = try link.attr("href")
                        var downloadLinkOfLinux = try linkOfLinux.attr("href")
                        downloadLink = "https://swift.org\(downloadLink)"
                        downloadLinkOfLinux = "https://swift.org\(downloadLinkOfLinux)"
                        logger.info("Download link: \(link)")
                        logger.info("Download link: \(linkOfLinux)")

                        let currentRegion = Region(calendar: Calendars.gregorian, zone: Zones.current, locale: Locales.current)
                        logger.info("Latest release date: \(date.toISODate()!.convertTo(region: currentRegion).toString())")
                        logger.info("Most recently record date: \(test.lastReleaseDate)")

                        /// To send a message to channel, there is three requirments:
                        ///     1. The new date must later than last release date.
                        ///     2. In case the isLater and isEarlier in SwiftDate trate the same day as always true, we need to make sure the new date and the last release date is not the same.
                        ///     3. The program may be started after release a couple of version which is the usual case. We don't wanna got notification for all eariler release.
                        ///        So we just check the last release in recent time.
                        if date.toISODate()!.compareCloseTo(test.lastReleaseDate, precision: 1.hours.timeInterval) {
                            logger.warning("Comparing \(date.toISODate()!.toISO()) and \(test.lastReleaseDate.toISO())")
                        } else {
                            if date.toISODate(region: currentRegion)!.compare(.isLater(than: test.lastReleaseDate)) {
                                // We don't want notification for a not recently release, if date is today, we will get notification.
                                logger.info("Later than last release date")
                                // if date.toISODate(region: currentRegion)!.compare(.isToday) {
                                logger.info("Is today")
                                let TextBody: String = """
                                New Release: 

                                *macOS:* 
                                `\(downloadLink)`

                                *Ubuntu 20\\\\.04:* 
                                `\(downloadLinkOfLinux)`

                                """
                                /// macOS: [link](\(downloadLink))
                                let button1 = """
                                { 
                                    "text":"macOS", 
                                    "url": "\(downloadLink)" 
                                }
                                """
                                logger.debug("\(button1)")

                                let button2 = """
                                { 
                                    "text":"Ubuntu 20.04", 
                                    "url": "\(downloadLinkOfLinux)" 
                                }
                                """
                                logger.debug("\(button1)")

                                // let TGBotAPIURL = "https://api.telegram.org/bot\(API_Token)/\(Action)?chat_id=\(ChatID)&text=\(TextBody)"
                                let TGBotAPIURL = "https://api.telegram.org/bot\(API_Token)/\(Action)"
                                logger.info("\(TGBotAPIURL)")
                                // TODO: The header defination may be duplicated.
                                var request = try HTTPClient.Request(url: TGBotAPIURL, method: .POST)
                                request.headers.add(name: "User-Agent", value: "Swift HTTPClient")
                                request.headers.add(name: "Content-Type", value: " application/json")
                                request.body = .string("""
                                { 
                                    "chat_id": "\(ChatID)", 
                                    "text": "\(TextBody)", 
                                    "reply_markup": { 
                                        "inline_keyboard": [
                                            [
                                                \(button1),
                                                \(button2)
                                            ]
                                        ]
                                    },
                                    "parse_mode": "MarkdownV2"
                                }
                                """)

                                print(request.body.debugDescription)

                                // TODO: There are a lots of telegram bot features to explore.
                                httpClient.execute(request: request).whenComplete { result in
                                    switch result {
                                    case let .failure(error):
                                        logger.error("\(error)")
                                    case let .success(response):
                                        if var body = response.body {
                                            if let content = body.readString(length: body.readableBytes) {
                                                logger.info("The remote content: \(content)")
                                            }
                                        }
                                    }
                                }
                                // }
                            } else {
                                logger.warning("Eariler than last release day")
                            }
                        }
                        test.lastReleaseDate = date.toISODate(region: currentRegion)!
                    } catch let Exception.Error(_, message) {
                        logger.error("\(message)")
                    } catch {
                        logger.critical("error")
                    }
                }
            }
        }
    }
    sleep(10)
}
