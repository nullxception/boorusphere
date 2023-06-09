package io.chaldeaprjkt.boorusphere

import StorageUtil
import android.os.Environment

class AndroidStorageUtil : StorageUtil {
    override fun getStoragePath(): String {
        val file = Environment.getExternalStorageDirectory()
        return file.absolutePath
    }

    override fun getDownloadPath(): String {
        val file = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        return file.absolutePath
    }
}