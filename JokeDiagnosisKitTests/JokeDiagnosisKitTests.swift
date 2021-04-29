//
// Copyright (c) 2021 shibafu
//

import XCTest
@testable import JokeDiagnosisKit

class JokeDiagnosisKitTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPrepareDiagnose() throws {
        let exp = expectation(description: "testPrepareDiagnose")
        let session = URLSession(configuration: .ephemeral)
        let d = Diagnosis.open(438894)
        d.prepareDiagnose(session: session).done { context in
            XCTAssertFalse(context.token.isEmpty)
        }.catch { error in
            XCTFail(error.localizedDescription)
        }.finally {
            exp.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testDiagnose() throws {
        let exp = expectation(description: "testDiagnose")
        let d = Diagnosis.open(258437)
        d.diagnose(name: "名前name").done { result in
            XCTAssertEqual("名前name.\n#shindanmaker", result.displayText)
            XCTAssertEqual("名前name.\n#shindanmaker\nhttps://shindanmaker.com/258437", result.shortText)
            XCTAssertNil(result.fullText)
        }.catch { error in
            XCTFail(error.localizedDescription)
        }.finally {
            exp.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
}
