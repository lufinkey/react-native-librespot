
@objc(LibrespotModule)
public class LibrespotModule: NSObject {
  
  private var core: LibrespotCore
  
  public override init() {
    self.core = LibrespotCore()
    super.init()
  }

	@objc(doAThing)
	public func doAThing() -> Void {
		NSLog("We're calling a swift function!!!!");
	}

	@objc
	public func constantsToExport() -> [String: Any]! {
		return [
			"someKey": "someValue"
		];
	}
}
