package org.kleinerbrauhelfer.app;

import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.webkit.MimeTypeMap;
import android.provider.OpenableColumns;
import android.provider.MediaStore;

// TODO: make it work...

public class PathUtil {

    public static String getFileName(Uri uri, Context context) {
        String fileName = getFileNameFromCursor(uri, context);
        if (fileName == null) {
            String fileExtension = getFileExtension(uri, context);
            fileName = "temp_file" + (fileExtension != null ? "." + fileExtension : "");
        } else {
            if (!fileName.contains(".")) {
                String fileExtension = getFileExtension(uri, context);
                fileName = fileName + "." + fileExtension;
            }
            return fileName;
        }
        return "";
    }

    private static String getFileExtension(Uri uri, Context context) {
        String fileType = context.getContentResolver().getType(uri);
        return MimeTypeMap.getSingleton().getExtensionFromMimeType(fileType);
    }

    private static String getFileNameFromCursor(Uri uri, Context context) {
        String fileName = null;
        Cursor cursor = context.getContentResolver().query(uri, new String[] {OpenableColumns.DISPLAY_NAME}, null, null, null);
        if (cursor != null) {
            cursor.moveToFirst();
            int nameIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME);
            if (nameIndex >= 0)
                fileName = cursor.getString(nameIndex);
            cursor.close();
        }
        return fileName;
    }
}
