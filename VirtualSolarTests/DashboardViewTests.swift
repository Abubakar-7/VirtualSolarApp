import XCTest
import ViewInspector
@testable import virtual_solar_UI

final class DashboardViewTests: XCTestCase {

    func testViewContainsHeaderLogo() throws {
        let view = DashboardView()
        let inspected = try view.inspect()

        // Check if the first image is the logo
        let image = try inspected
            .vStack()                 // Outer VStack
            .hStack(0)               // First element in VStack is HStack with logo
            .image(0)                // First image in HStack

        XCTAssertEqual(try image.actualImage().name(), "SolarCloudLogo")
    }

    func testHasNavigationButton() throws {
        let view = DashboardView()
        let inspected = try view.inspect()

        // Check if the view contains a NavigationLink somewhere
        XCTAssertNoThrow(try inspected.find(ViewType.NavigationLink.self))
    }

    func testContainsCorrectSectionTitles() throws {
        let view = DashboardView()
        let inspected = try view.inspect()

        // Assuming the title text is directly in VStack
        let text = try inspected
            .vStack()
            .text(1) // Adjust index as needed based on your actual hierarchy

        XCTAssertEqual(try text.string(), "Dashboard")
    }
}
