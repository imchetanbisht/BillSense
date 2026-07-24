import UIKit
import SwiftUI
import Flutter

/// UIHostingController bridge to present native SwiftUI BillSense redesign
public class SwiftUIHostingController: UIHostingController<MainTabView> {
    public init() {
        super.init(rootView: MainTabView())
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: MainTabView())
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 0.043, green: 0.071, blue: 0.125, alpha: 1.0)
    }
}
