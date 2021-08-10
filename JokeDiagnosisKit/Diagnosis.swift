//
// Copyright (c) 2021 shibafu
//

import Foundation
import PromiseKit
import Fuzi

let URLPrefix = "https://shindanmaker.com/"
let DefaultUserAgent = "JokeDiagnosisKit/1.0"

/// 診断メーカーに投稿されている診断のページ情報
@objc(JDKDiagnosis)
public class Diagnosis: NSObject {
    let url: URL

    init(url: URL) {
        self.url = url
    }

    public override var description: String {
        get {
            "\(super.description) { URL = \(url) }"
        }
    }

    /// 診断を実行する。
    ///
    /// - Parameter name: 診断したい名前。1〜100文字。
    public func diagnose(name: String) -> Promise<DiagnosisResult> {
        if name.isEmpty || name.count > 100 {
            return Promise(error: DiagnoseError.invalidName)
        }
        let session = URLSession(configuration: .ephemeral)
        return firstly {
            prepareDiagnose(session: session)
        }.then { context -> Promise<(data: Data, response: URLResponse)> in
            var req = URLRequest(url: self.url, cachePolicy: .reloadIgnoringLocalCacheData)
            req.httpMethod = "POST"
            let body = "shindanName=\(name)&_token=\(context.token)".data(using: .utf8)!
            req.httpBody = body
            req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            req.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
            req.setValue(DefaultUserAgent, forHTTPHeaderField: "User-Agent")
            return session.dataTask(.promise, with: req)
        }.map { data, res in
            let doc = try HTMLDocument(data: data)
            let textAll = doc.firstChild(xpath: "//textarea[@id=\"copy-textarea-all\"]")
            guard let text140 = doc.firstChild(xpath: "//textarea[@id=\"copy-textarea-140\"]") else {
                throw DiagnoseError.invalidResponse
            }

            let fullText: String? = {
                guard let node = $0 else {
                    return nil
                }
                return node.stringValue.isEmpty ? nil : node.stringValue
            }(textAll)

            return DiagnosisResult(name: name, shortText: text140.stringValue, fullText: fullText)
        }.ensure {
            session.finishTasksAndInvalidate()
        }
    }

    /// 診断を実行する。
    ///
    /// - Parameter name: 診断したい名前。1〜100文字。
    @objc
    public func diagnose(withName name: String) -> AnyPromise {
        AnyPromise(diagnose(name: name))
    }

    func prepareDiagnose(session: URLSession) -> Promise<Context> {
        let req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        return session.dataTask(.promise, with: req).map { data, res in
            let doc = try HTMLDocument(data: data)
            guard let element = doc.firstChild(xpath: "//*[@id=\"shindanForm\"]/input[@name=\"_token\"]") else {
                throw DiagnoseError.tokenNotFound
            }
            guard let token = element.attr("value"), !token.isEmpty else {
                throw DiagnoseError.tokenNotFound
            }

            return Context(token: token)
        }
    }

    /// 診断ページのIDからインスタンスを生成する。
    /// このメソッドはページ内容の解析を行わないため、返されたインスタンスからタイトルなどを得ることはできない。
    @objc
    public class func open(_ id: Int) -> Diagnosis {
        Diagnosis(url: URL(string: "\(URLPrefix)\(id)")!)
    }

    /// 指定したIDの診断ページをダウンロードして解析し、インスタンス化する。
    public class func parse(_ id: Int) -> Promise<Diagnosis> {
        // TODO: やる気が出たら作る
        abort()
    }
}

/// 診断メーカーから得られた診断結果
@objc(JDKDiagnosisResult)
@objcMembers
public class DiagnosisResult: NSObject {
    /// 診断時に使用した名前
    public let name: String

    /// SNS共有向けの、140文字程度に切り詰められた診断結果
    public let shortText: String

    /// 切り詰め処理を行っていない、診断結果の全文
    ///
    /// `shortText` が140文字以内に収まっている場合は `nil` となる。表示用の診断結果を安全に取得するには `displayText` を参照する。
    public let fullText: String?

    /// 表示用に診断URLを取り除いた、診断結果の全文
    public let displayText: String

    /// `fullText` が存在すればそちらを、無い場合は `shortText` を返す
    public var fullShareText: String {
        get {
            fullText ?? shortText
        }
    }

    init(name: String, shortText: String, fullText: String?) {
        self.name = name
        self.shortText = shortText
        self.fullText = fullText

        let longestText = fullText ?? shortText
        if let lastLineBreak = longestText.lastIndex(of: "\n") {
            self.displayText = String(longestText[longestText.startIndex..<lastLineBreak])
        } else {
            self.displayText = longestText
        }
    }
}

/// 診断処理中に発生するエラー
@objc(JDKDiagnoseError)
public enum DiagnoseError: Int, Error {
    /// どうしようもない内部エラー
    case internalError = 1
    /// CSRF Tokenが発見できず、診断できない
    case tokenNotFound = 2
    /// 渡された名前が使用できない
    case invalidName = 3
    /// 診断のPOSTレスポンスがおかしい
    case invalidResponse = 4
}

/// POST時に必要な雑多なデータ
struct Context {
    let token: String
}
