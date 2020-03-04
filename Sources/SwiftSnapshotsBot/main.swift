// It just works.
// There are various bug need to solve.
import AsyncHTTPClient
import Foundation
import Logging
import SwiftDate
import SwiftSoup

// TODO: Using logger to print nice log to console.
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
                        print(link)
                        print(date)

                        let currentRegion = Region(calendar: Calendars.gregorian, zone: Zones.current, locale: Locales.current)
                        print(date.toISODate()!.convertTo(region: currentRegion).toString())
                        print("lastReleaseDate: ", test.lastReleaseDate)

                        /// To send a message to channel, there is three requirments:
                        ///     1. The new date must later than last release date.
                        ///     2. In case the isLater and isEarlier in SwiftDate trate the same day as always true, we need to make sure the new date and the last release date is not the same.
                        ///     3. The program may be started after release a couple of version which is the usual case. We don't wanna got notification for all early release.
                        ///        So we just check the last release in recent time.
                        print("later than last release date? ", date.toISODate(region: currentRegion)!.compare(.isLater(than: test.lastReleaseDate)))
                        print("Is the same day with last release date? ", date.toISODate(region: currentRegion)!.compare(.isSameDay(test.lastReleaseDate)))
                        print("Is today? ", date.toISODate(region: currentRegion)!.compare(.isToday))

                        // FIXME: Simplify the if condation.
                        if date.toISODate(region: currentRegion)!.compare(.isLater(than: test.lastReleaseDate)),
                            date.toISODate(region: currentRegion)!.compare(.isToday),
                            !date.toISODate(region: currentRegion)!.compare(.isSameDay(test.lastReleaseDate)) {
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
                                    print(error)
                                case let .success(response):
                                    if var body = response.body {
                                        if let content = body.readString(length: body.readableBytes) {
                                            print(content)
                                        }
                                    }
                                }
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
