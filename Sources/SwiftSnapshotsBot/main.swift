import AsyncHTTPClient
import Foundation
import Logging
import SwiftSoup

let logger = Logger(label: "keyvchan")
let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)

let SwiftDownloadPageURL = "https://swift.org/download/"

// TODO: uncleanShutdown
for _ in stride(from: 0, to: 60, by: 5) {
    var SwiftWebPage = try HTTPClient.Request(url: SwiftDownloadPageURL, method: .GET)
    SwiftWebPage.headers.add(name: "User-Agent", value: "Swift HTTPClient")

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

                        let API_Token: String = CommandLine.arguments[1]
                        let ChatID: String = "-1001405329947"
                        let Action: String = "sendMessage"
                        let TextBody: String = date + "https://swift.org" + downloadLink
                        print(TextBody)

                        let TGBotAPIURL = "https://api.telegram.org/bot\(API_Token)/\(Action)?chat_id=\(ChatID)&text=\(TextBody)"

                        var request = try HTTPClient.Request(url: TGBotAPIURL, method: .GET)
                        request.headers.add(name: "User-Agent", value: "Swift HTTPClient")

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
