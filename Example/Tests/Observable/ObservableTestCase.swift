//
//  ObservableTestCase.swift
//  LightweightObservable_Tests
//
//  Created by Felix Mau on 11/02/19.
//  Copyright © 2019 Felix Mau. All rights reserved.
//

import XCTest
import LightweightObservable

class ObservableTestCase: XCTestCase {
    // MARK: - Private properties

    var disposeBag: DisposeBag!

    var oldValue: Int?
    var newValue: Int?

    // MARK: - Public methods

    override func setUp() {
        super.setUp()

        disposeBag = DisposeBag()

        oldValue = nil
        newValue = nil
    }

    override func tearDown() {
        disposeBag = nil

        super.tearDown()
    }

    // MARK: - Test method `observe(:)`

    func testObservableShouldInformSubscriberWithCorrectValues() {
        // Given
        let variable = Variable(0)

        // When
        variable.asObservable.subscribe { newValue, oldValue in
            self.newValue = newValue
            self.oldValue = oldValue
        }.disposed(by: &disposeBag)

        // Then
        XCTAssertEqual(newValue, 0)
        XCTAssertNil(oldValue)
    }

    func testObservableShouldUpdateSubscriberWithCorrectValues() {
        // Given
        let variable = Variable(0)

        variable.asObservable.subscribe { newValue, oldValue in
            self.newValue = newValue
            self.oldValue = oldValue
        }.disposed(by: &disposeBag)

        // When
        for value in 1 ..< 10 {
            variable.value = value

            // Then
            XCTAssertEqual(newValue, value)
            XCTAssertEqual(oldValue, value - 1)
        }
    }

    // MARK: - Test deallocated disposable

    func testObservableShouldNotInformSubscriberAfterDeallocatedDisposable() {
        // Given
        let variable = Variable(0)

        var disposable: Disposable? = variable.asObservable.subscribe { newValue, oldValue in
            self.newValue = newValue
            self.oldValue = oldValue
        }

        // Workaround to fix warning `Variable 'disposable' was written to, but never read`
        XCTAssertNotNil(disposable, "Precondition failed - Expected to have a valid instance at this point.")

        // When
        disposable = nil
        variable.value = 1

        // Then
        XCTAssertEqual(newValue, 0, "As we've deallocated our disposable the observer should not be updated.")
        XCTAssertNil(oldValue)
    }

    func testObservableShouldNotInformSubscriberAfterDeallocatedDisposeBag() {
        // Given
        let variable = Variable(0)

        variable.asObservable.subscribe { newValue, oldValue in
            self.newValue = newValue
            self.oldValue = oldValue
        }.disposed(by: &disposeBag)

        // When
        disposeBag = nil
        variable.value = 1

        // Then
        XCTAssertEqual(newValue, 0, "As we've deallocated our disposable the observer should not be updated.")
        XCTAssertNil(oldValue)
    }
}
