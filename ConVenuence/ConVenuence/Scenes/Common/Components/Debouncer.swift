import Foundation

class Debouncer {
    private let delay: TimeInterval
    private var workItem: DispatchWorkItem?
    private let queue: DispatchQueue

    init(delay: TimeInterval, queue: DispatchQueue = .main) {
        self.delay = delay
        self.queue = queue
    }

    func run(action: @escaping () -> Void) {
        print("Debouncer: Scheduling new work item")

        // Cancel the previous work item
        workItem?.cancel()

        // Create a new work item
        let newWorkItem = DispatchWorkItem(block: action)
        workItem = newWorkItem

        // Dispatch the new work item after the delay
        queue.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self, self.workItem === newWorkItem else {
                print("Debouncer: Work item was canceled or replaced.")
                return
            }
            print("Debouncer: Dispatching work item")
            newWorkItem.perform()
        }
    }
}
