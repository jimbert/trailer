
import WatchKit

final class CommandController: WKInterfaceController {

    @IBOutlet weak var feedbackLabel: WKInterfaceLabel!
	@IBOutlet weak var feedbackGroup: WKInterfaceGroup!

	var contextFromParent:[NSObject: AnyObject]?

    override func awakeWithContext(context: AnyObject?) {

        super.awakeWithContext(context)
		contextFromParent = context as? [NSObject: AnyObject];
    }

    func dismissAfterPause(pause: Double) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(pause * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { [weak self] in
            self!.dismissController()
        }
    }

    override func willActivate() {
        super.willActivate()


		atNextEvent() { [weak self] in
			if let cd = self?.contextFromParent {

				Settings.clearCache()

				let result = WKInterfaceController.openParentApplication(cd) { [weak self] result, error in
					if let e = error {
						self?.feedbackGroup.setBackgroundColor(UIColor.redColor())
						self?.feedbackLabel.setText("Error: \(e.localizedDescription)")
						self?.dismissAfterPause(2.0)
					} else {
						self?.feedbackLabel.setText(result["status"] as? String)
						if result["color"] as! String == "red" {
							self?.feedbackGroup.setBackgroundColor(UIColor.redColor())
							self?.dismissAfterPause(2.0)
						} else {
							self?.feedbackGroup.setBackgroundColor(UIColor.greenColor())
							self?.dismissAfterPause(0.2)
						}
					}
				}
				if !result {
					self?.feedbackLabel.setTextColor(UIColor.redColor())
					self?.feedbackLabel.setText("Could not send request to the parent app")
					self?.dismissAfterPause(2.0)
				}
			} else {
				self?.dismissController()
			}
		}
    }

    override func didDeactivate() {
        super.didDeactivate()
    }

}
