package org.kleinerbrauhelfer.app;

import android.content.Context;
import android.net.Uri;
import android.provider.DocumentsContract;
import android.os.Environment;

public class PathUtil {

    public static String getPath(final Context context, final Uri uri) {
        if (isExternalStorageDocument(uri)) {
            final String[] uriParts = uri.toString().split(":");
            final String[] docIdParts = DocumentsContract.getDocumentId(uri).split(":");
            if (isPrimaryStorage(docIdParts[0])) {
                return Environment.getExternalStorageDirectory() + "/" + uriParts[uriParts.length-1];
            } else {
                return "/storage/" + docIdParts[0] + "/" + uriParts[uriParts.length-1];
            }
        }
        return uri.toString();
    }

    private static boolean isExternalStorageDocument(final Uri uri) {
        return "com.android.externalstorage.documents".equals(uri.getAuthority());
    }

    private static boolean isPrimaryStorage(final String id) {
        return "primary".equalsIgnoreCase(id);
    }
}
