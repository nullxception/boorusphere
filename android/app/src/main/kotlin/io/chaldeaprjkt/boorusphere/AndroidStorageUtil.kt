package io.chaldeaprjkt.boorusphere

import StorageUtil
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import androidx.core.content.FileProvider
import java.io.File


class AndroidStorageUtil(private val context: Context) : StorageUtil {
    override fun getStoragePath(): String {
        val file = Environment.getExternalStorageDirectory()
        return file.absolutePath
    }

    override fun getDownloadPath(): String {
        val file = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        return file.absolutePath
    }

    override fun open(filePath: String) {
        val uri = uriOfPath(filePath)
        val intent = Intent(Intent.ACTION_VIEW)
            .setDataAndType(uri, context.contentResolver.getType(uri))
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        println(uri)
        context.startActivity(intent)
    }

    private fun uriOfPath(path: String): Uri {
        val file = File(path)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            return FileProvider.getUriForFile(
                context,
                context.applicationContext.packageName + ".flutter_downloader.provider",
                file
            )
        }

        return Uri.fromFile(file)
    }
}
