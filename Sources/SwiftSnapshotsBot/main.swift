// It just works.
// There are various bug need to solve.
import AsyncHTTPClient
import ConsoleKit
import Foundation
import Logging
import SwiftDate
import SwiftSoup

// TODO: Using logger to print nice log to console.
LoggingSystem.bootstrap { _ in
    let console = Terminal()
    let consoleLogger = ConsoleLogger(label: "keyvchan", console: console)
    return consoleLogger
}

let logger = Logger(label: "keyvchan")

let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)

// TODO: Get all arguments from a specific file or command line.
let API_Token: String = CommandLine.arguments[1]
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
    //      - Make full use of swift-log. The log should human readable.
    httpClient.execute(request: SwiftWebPage).whenComplete { result in
        switch result {
        case let .failure(error):
            print(error)
        case let .success(response):
            if var body = response.body {
                if let content = body.readString(length: body.readableBytes) {
                    do {
                        let html: String = content
                        let doc: Document = try SwiftSoup.parse(html)
                        let time: Element = try doc.select("body main #trunk-development-master+p+table tbody tr td time").first()!
                        let link: Element = try doc.select("body main #trunk-development-master+p+table tbody tr td span a").first()!

                        let date = try time.attr("datetime")
                        let downloadLink = try link.attr("href")
                        logger.info("Download link: \(link)")
                        logger.info("Newest release date: \(date)")

                        let currentRegion = Region(calendar: Calendars.gregorian, zone: Zones.current, locale: Locales.current)
                        logger.info("\(date.toISODate()!.convertTo(region: currentRegion).toString())")
                        logger.info("Most recently record date: \(test.lastReleaseDate)")

                        /// To send a message to channel, there is three requirments:
                        ///     1. The new date must later than last release date.
                        ///     2. In case the isLater and isEarlier in SwiftDate trate the same day as always true, we need to make sure the new date and the last release date is not the same.
                        ///     3. The program may be started after release a couple of version which is the usual case. We don't wanna got notification for all eariler release.
                        ///        So we just check the last release in recent time.
                        if date.toISODate(region: currentRegion)!.compare(.isSameDay(test.lastReleaseDate)) {
                            logger.warning("Today is the same day with last release date.")
                        } else {
                            if date.toISODate(region: currentRegion)!.compare(.isLater(than: test.lastReleaseDate)) {
                                // We don't want notification for a not recently release, if date is today, we will get notification.
                                if date.toISODate(region: currentRegion)!.compare(.isToday) {
                                    let TextBody: String = date + "https://swift.org" + downloadLink
                                    print(TextBody)
                                    let TGBotAPIURL = "https://api.telegram.org/bot\(API_Token)/\(Action)?chat_id=\(ChatID)&text=\(TextBody)"
                                    // TODO: The header defination may be duplicated.
                                    var request = try HTTPClient.Request(url: TGBotAPIURL, method: .GET)
                                    request.headers.add(name: "User-Agent", value: "Swift HTTPClient")

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
                                }
                            } else {
                                logger.warning("Eariler than last release day")
                            }
                        }
                        test.lastReleaseDate = date.toISODate(region: currentRegion)!
                    } catch let Exception.Error(_, message) {
                        print(message)
                    } catch {
                        print("error")
                    }
                }
            }
        }
    }
    sleep(10)
}
