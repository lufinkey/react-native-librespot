package com.librespot

import com.facebook.react.bridge.Dynamic
import com.facebook.react.bridge.ReadableMap
import org.json.JSONException
import org.json.JSONObject


object LibrespotUtils {
	fun getOption(option: String, options: ReadableMap, fallback: ReadableMap? = null): Dynamic? {
		if (options.hasKey(option)) {
			val obj = options.getDynamic(option)
			if (!obj.isNull) {
				return obj
			}
		}
		if (fallback != null && fallback.hasKey(option)) {
			val obj = fallback.getDynamic(option)
			if (!obj.isNull) {
				return obj
			}
		}
		return null
	}

	fun getObject(key: String, obj: JSONObject): Any? {
		return try {
			obj[key]
		} catch (e: JSONException) {
			null
		}
	}
}
