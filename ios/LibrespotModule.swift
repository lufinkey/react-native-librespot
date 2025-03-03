
@objc(LibrespotModule)
public class LibrespotModule: NSObject {
  
  private var core: SpeckCore
  
  public override init() {
    self.core = SpeckCore()
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
