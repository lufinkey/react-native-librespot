package com.librespot

import com.facebook.react.BaseReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.model.ReactModuleInfo
import com.facebook.react.module.model.ReactModuleInfoProvider
import java.util.HashMap

class LibrespotPackage : BaseReactPackage() {
	override fun getModule(name: String, reactContext: ReactApplicationContext): NativeModule? {
		return if (name == LibrespotModule.NAME) {
			LibrespotModule(reactContext)
		} else {
			null
		}
	}

	override fun getReactModuleInfoProvider(): ReactModuleInfoProvider {
		return ReactModuleInfoProvider {
			val moduleInfos: MutableMap<String, ReactModuleInfo> = HashMap()
			moduleInfos[LibrespotModule.NAME] = ReactModuleInfo(
				LibrespotModule.NAME,
				LibrespotModule.NAME,
				false,  // canOverrideExistingModule
				false,  // needsEagerInit
				false,  // isCxxModule
				true // isTurboModule
			)
			moduleInfos
		}
	}
}
