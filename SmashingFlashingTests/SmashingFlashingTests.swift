//
//  SmashingFlashingTests.swift
//  SmashingFlashingTests
//
//  Created by Михаил Нечаев on 17.12.17.
//  Copyright © 2017 Михаил Нечаев. All rights reserved.
//

import XCTest
import AVFoundation
import Photos
@testable import SmashingFlashing

class SmashingFlashingTests: XCTestCase {
    let merger = TrueMerger(audio: URL(string: "file:/Users/Nechaev/Documents/TestSmashingFlashing/sec.m4a")!, video: URL(string: "file:/Users/Nechaev/Documents/TestSmashingFlashing/IMG_0006.MOV")!)
    var reducedAudioUrl: URL!
    var mergedVideoUrl: URL!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        //guard let url = merger.audioTrackReduction() else {return}
        //mergedUrl = url
        //mergedUrl = merger.mergeMutableVideoWithAudio()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        reducedAudioUrl = nil
        mergedVideoUrl = nil
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testMergerInit() {
        XCTAssertEqual(merger.audioUrl, URL(string: "file:/Users/Nechaev/Documents/TestSmashingFlashing/sec.m4a"))
        XCTAssertEqual(merger.videoUrl, URL(string: "file:/Users/Nechaev/Documents/TestSmashingFlashing/IMG_0006.MOV"))
    }

    func testMergerAudioTrackReduction() {
        let expectation = XCTestExpectation.init(description: "Audio")
        
        reducedAudioUrl = merger.audioTrackReduction {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 50)

        let gottenAsset = AVURLAsset.init(url: reducedAudioUrl)
        let expectedAsset = AVURLAsset.init(url:URL(string: "file:/Users/Nechaev/Documents/TestSmashingFlashing/merged672.m4a")!)
        
        XCTAssertEqual(gottenAsset.track(withTrackID: 1)?.timeRange.duration, expectedAsset.track(withTrackID: 1)?.timeRange.duration)
        //CHECK INSERTIONDATA_TO_LOCAL_STORAGE- проверить, если файл с таким именем, и сравнить свойства
    }
    
    func testMergerVideoAudio() {
        let expectation = XCTestExpectation.init(description: "Video")

        mergedVideoUrl = merger.mergeMutableVideoWithAudio {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 50)
        
        let gottenAsset = AVURLAsset.init(url: mergedVideoUrl!)
        let expectedAsset = AVURLAsset.init(url:URL(string: "file:/Users/Nechaev/Documents/TestSmashingFlashing/IMG_TEST.mov")!)

        XCTAssertEqual(gottenAsset.track(withTrackID: 1)?.timeRange.duration, expectedAsset.track(withTrackID: 1)?.timeRange.duration)
        
        //все вложенки я должен протестировать здесь же? - нет, потому что вложенка уже вложена
        //могу только добавить проверок на всякие там треки и тд - но мне кажется это лишнее
        XCTAssertEqual(gottenAsset.tracks.count, 2)
    }
    
    func testAssetByTrimming() {
        //проверка - режется ли ассет до нужного времени
        let expectedTime: Double = 10
        let asset = AVURLAsset.init(url:URL(string: "file:/Users/Nechaev/Documents/TestSmashingFlashing/merged672.m4a")!)
        let trimmedAsset = try! merger.assetByTrimming(timeOffStart: expectedTime, track: asset.tracks(withMediaType: AVMediaType.audio).first!)
        
        XCTAssertEqual(Double(CMTimeGetSeconds(trimmedAsset.duration)), expectedTime)
    }
    
    
    func testAssetByTrimmingThrowing() {
        let expectedTime: Double = 10
        let asset = AVURLAsset.init(url:URL(string: "file:/Users/Nechaev/Documents/TestSmashingFlashing/merged672.m4a")!)
        let track = asset.tracks(withMediaType: AVMediaType.audio).first!
        
        XCTAssertThrowsError(try merger.assetByTrimming(timeOffStart: expectedTime, track: track))
    }
    
    
    func testExportToPhotoLibrary() {

        let options = PHFetchOptions()
        options.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: false) ]
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        //options
        let videos = PHAsset.fetchAssets(with: options)
        let countFirst = videos.countOfAssets(with: PHAssetMediaType.video)

        let expectation = XCTestExpectation.init(description: "Export")

        let urFl = URL(string: "/Users/Nechaev/Pictures/IMG_1814.MOV")!
        merger.exportToPhotoLibrary(url: urFl) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 50)
        
        let newVideos = PHAsset.fetchAssets(with: options)
        let countSecond = newVideos.countOfAssets(with: PHAssetMediaType.video)

        XCTAssertEqual(countFirst + 1, countSecond)
    }
    
    func testRemoveFileAtURLIfExists() {
        let string = "/Users/Nechaev/Documents/TestSmashingFlashing/merged156.m4a"
        let fileManager = FileManager.default
        
        XCTAssertTrue(fileManager.fileExists(atPath: string))
        
        let url = URL(string: string)!
        Helper().removeFileAtURLIfExists(url: url)
        
        XCTAssertFalse(fileManager.fileExists(atPath: string))
    }
}










