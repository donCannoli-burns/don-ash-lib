package dev.kolmafia.ash

internal object NativeBridge {
    init {
        System.loadLibrary("kolmafia_ash_android")
    }

    @JvmStatic
    external fun nativeCreate(
        baseUrl: String,
        pwd: String,
        allowNonLoopback: Boolean,
    ): Long

    @JvmStatic
    external fun nativeDestroy(handle: Long)

    @JvmStatic
    external fun nativeCallJson(
        handle: Long,
        ashName: String,
        argsJson: String,
    ): String

    @JvmStatic
    external fun nativeExecuteJson(
        handle: Long,
        requestJson: String,
    ): String
}
