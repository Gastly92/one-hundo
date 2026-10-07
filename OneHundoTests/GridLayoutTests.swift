@testable import OneHundo
import SwiftUI
import XCTest

final class GridLayoutTests: XCTestCase {
  func testTwoColumnsAtNormalSizes() {
    let sizes: [DynamicTypeSize] = [
      .xSmall, .large, .xxxLarge,
    ]
    for size in sizes {
      XCTAssertEqual(
        GridLayout.columns(for: size), 2
      )
    }
  }

  func testOneColumnAtAccessibilitySizes() {
    let sizes: [DynamicTypeSize] = [
      .accessibility1, .accessibility5,
    ]
    for size in sizes {
      XCTAssertEqual(
        GridLayout.columns(for: size), 1
      )
    }
  }

  func testRows() {
    let items = [1, 2, 3]
    XCTAssertEqual(
      GridLayout.rows(items, columns: 2),
      [[1, 2], [3]]
    )
    XCTAssertEqual(
      GridLayout.rows(items, columns: 1),
      [[1], [2], [3]]
    )
    XCTAssertEqual(
      GridLayout.rows([Int](), columns: 2),
      []
    )
  }
}
