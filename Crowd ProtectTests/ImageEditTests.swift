//
//  ImageEditTests.swift
//  Crowd ProtectTests
//
//  Created by Pim Coumans on 05/06/2020.
//  Copyright © 2020 Grow Pixel. All rights reserved.
//

import XCTest
@testable import Crowd_Protect

class ImageEditTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testEdits() throws {
        let bundle = Bundle(for: ImageEditTests.self)
        guard let image = UIImage(named: "testA", in: bundle, with: nil) else {
            XCTFail("Image 'TestA' unavailable")
            return
        }
        
        let edits = ImageEdits(image)
        edits.edits.append(FaceBlurEdit(frame: CGRect(x: 10, y: 10, width: 20, height: 40)))
        XCTAssert(edits.edits.count > 0)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
