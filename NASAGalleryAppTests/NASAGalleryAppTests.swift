import XCTest
import Combine

final class NASAGalleryAppTests: XCTestCase {
    
    var cancellables = Set<AnyCancellable>()
    
    func test_ImageAPIViewModel_fetchData_shouldReturnItems() async {
        
        // Given
        let vm = ImageAPIViewModel()
        
        // When
        let expectation = XCTestExpectation(description: "Should return items after 2 seconds")
        
        vm.$images
            .dropFirst()
            .sink { returnedItems in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        await vm.fetchData()
        
        //Then
        wait(for: [expectation] , timeout: 5)
        XCTAssertGreaterThan(vm.images.count, 0)
    }
    
}
