package io.chaldeaprjkt.boorusphere

import AppEnv
import Env
import android.os.Build
import io.chaldeaprjkt.boorusphere.BuildConfig as BuildInfo // make sure that we use proper BuildConfig

class AndroidAppEnv : AppEnv {
    override fun get(): Env {
        return Env(
            versionName = BuildInfo.VERSION_NAME,
            versionCode = BuildInfo.VERSION_CODE.toLong(),
            sdkVersion = Build.VERSION.SDK_INT.toLong()
        )
    }
}
