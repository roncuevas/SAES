import UIKit
import EventKit
import EventKitUI
import SwiftUI

class AddEventController: UIViewController, EKEventEditViewDelegate {
    let eventStore = EKEventStore()
    let event: EKEvent?
    
    init(event: EKEvent?) {
        self.event = event
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
        parent?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventStore.requestAccess( to: EKEntityType.event, completion: { (granted, error) in
            DispatchQueue.main.async {
                if (granted) && (error == nil) {
                    let eventController = EKEventEditViewController()
                    if let event = self.event {
                        eventController.event = event
                    }
                    eventController.eventStore = self.eventStore
                    eventController.editViewDelegate = self
                    eventController.modalPresentationStyle = .overCurrentContext
                    eventController.modalTransitionStyle = .crossDissolve
                    
                    self.present(eventController, animated: true, completion: nil)
                }
            }
        }
        )
    }
}

struct AddEvent: UIViewControllerRepresentable {
    @Binding var event: EKEvent?
    
    func makeUIViewController(context: Context) -> AddEventController {
        return AddEventController(event: event)
    }
    
    func updateUIViewController(_ uiViewController: AddEventController, context: Context) {
        // We need this to follow the protocol, but don't have to implement it
        // Edit here to update the state of the view controller with information from SwiftUI
    }
}
