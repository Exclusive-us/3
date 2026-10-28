package com.adspro.app.utils
import android.content.Context
import android.net.Uri
import java.io.*
object FileUtils {
    fun getFileFromUri(c: Context, u: Uri): File? {
        return try {
            val input = c.contentResolver.openInputStream(u) ?: return null
            val file = File.createTempFile("upload_", ".tmp", c.cacheDir)
            val output = FileOutputStream(file)
            input.copyTo(output); input.close(); output.close()
            file
        } catch(e: Exception) { null }
    }
}
