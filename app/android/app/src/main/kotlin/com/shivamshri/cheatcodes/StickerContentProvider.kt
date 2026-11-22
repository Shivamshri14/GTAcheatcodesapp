package com.shivamshri.cheatcodes

import android.content.ContentProvider
import android.content.ContentValues
import android.content.UriMatcher
import android.content.res.AssetFileDescriptor
import android.database.Cursor
import android.database.MatrixCursor
import android.net.Uri
import org.json.JSONObject

/**
 * Serves the bundled sticker pack (assets/stickers/contents.json + assets/stickers/1/...)
 * to WhatsApp, following WhatsApp's public sticker-pack content provider contract.
 */
class StickerContentProvider : ContentProvider() {
    companion object {
        private const val METADATA = "metadata"
        private const val STICKERS = "stickers"
        private const val STICKERS_ASSET = "stickers_asset"
        private const val M_ALL = 1
        private const val M_ONE = 2
        private const val M_STICKERS = 3
        private const val M_FILE = 4
    }

    private val matcher = UriMatcher(UriMatcher.NO_MATCH)
    private var packs: List<JSONObject>? = null

    override fun onCreate(): Boolean {
        val authority = context!!.packageName + ".stickercontentprovider"
        matcher.addURI(authority, METADATA, M_ALL)
        matcher.addURI(authority, "$METADATA/*", M_ONE)
        matcher.addURI(authority, "$STICKERS/*", M_STICKERS)
        matcher.addURI(authority, "$STICKERS_ASSET/*/*", M_FILE)
        return true
    }

    private fun packs(): List<JSONObject> {
        packs?.let { return it }
        val text = context!!.assets.open("stickers/contents.json").bufferedReader().use { it.readText() }
        val arr = JSONObject(text).getJSONArray("sticker_packs")
        val list = (0 until arr.length()).map { arr.getJSONObject(it) }
        packs = list
        return list
    }

    private fun pack(id: String?): JSONObject? = packs().firstOrNull { it.getString("identifier") == id }

    private fun metadataCursor(uri: Uri, only: List<JSONObject>): Cursor {
        val c = MatrixCursor(arrayOf(
            "sticker_pack_identifier", "sticker_pack_name", "sticker_pack_publisher",
            "sticker_pack_icon", "android_play_store_link", "ios_app_download_link",
            "sticker_pack_publisher_email", "sticker_pack_publisher_website",
            "sticker_pack_privacy_policy_website", "sticker_pack_license_agreement_website",
            "image_data_version", "whatsapp_will_not_cache_stickers", "animated_sticker_pack",
        ))
        for (p in only) c.addRow(arrayOf<Any>(
            p.getString("identifier"), p.getString("name"), p.getString("publisher"),
            p.getString("tray_image_file"), "", "",
            p.optString("publisher_email"), p.optString("publisher_website"),
            p.optString("privacy_policy_website"), p.optString("license_agreement_website"),
            p.optString("image_data_version", "1"), if (p.optBoolean("avoid_cache")) 1 else 0,
            if (p.optBoolean("animated_sticker_pack")) 1 else 0,
        ))
        c.setNotificationUri(context!!.contentResolver, uri)
        return c
    }

    private fun stickersCursor(uri: Uri, p: JSONObject): Cursor {
        val arr = p.getJSONArray("stickers")
        val c = MatrixCursor(arrayOf("sticker_file_name", "sticker_emoji", "sticker_accessibility_text"))
        for (i in 0 until arr.length()) {
            val s = arr.getJSONObject(i)
            val emojis = s.getJSONArray("emojis")
            val list = (0 until emojis.length()).joinToString(",") { emojis.getString(it) }
            c.addRow(arrayOf<Any>(s.getString("image_file"), list, ""))
        }
        c.setNotificationUri(context!!.contentResolver, uri)
        return c
    }

    override fun query(uri: Uri, projection: Array<String>?, selection: String?,
                       selectionArgs: Array<String>?, sortOrder: String?): Cursor? =
        when (matcher.match(uri)) {
            M_ALL -> metadataCursor(uri, packs())
            M_ONE -> pack(uri.lastPathSegment)?.let { metadataCursor(uri, listOf(it)) }
            M_STICKERS -> pack(uri.lastPathSegment)?.let { stickersCursor(uri, it) }
            else -> throw IllegalArgumentException("Unknown URI: $uri")
        }

    override fun openAssetFile(uri: Uri, mode: String): AssetFileDescriptor? {
        if (matcher.match(uri) != M_FILE) return null
        val seg = uri.pathSegments
        if (seg.size != 3 || pack(seg[1]) == null) return null
        val name = seg[2]
        if (name.contains("/") || name.contains("..")) return null
        return context!!.assets.openFd("stickers/${seg[1]}/$name")
    }

    override fun getType(uri: Uri): String? {
        val auth = context!!.packageName + ".stickercontentprovider"
        return when (matcher.match(uri)) {
            M_ALL -> "vnd.android.cursor.dir/vnd.$auth.$METADATA"
            M_ONE -> "vnd.android.cursor.item/vnd.$auth.$METADATA"
            M_STICKERS -> "vnd.android.cursor.dir/vnd.$auth.$STICKERS"
            M_FILE -> if (uri.lastPathSegment!!.endsWith(".png")) "image/png" else "image/webp"
            else -> null
        }
    }

    override fun insert(uri: Uri, values: ContentValues?): Uri? = throw UnsupportedOperationException()
    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<String>?): Int =
        throw UnsupportedOperationException()
    override fun update(uri: Uri, values: ContentValues?, selection: String?,
                        selectionArgs: Array<String>?): Int = throw UnsupportedOperationException()
}
