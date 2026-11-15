package com.minttalk.app

/** What the ongoing-call notification and PiP actions show. Mirrors Dart's `OngoingCallInfo`. */
data class OngoingCallInfo(
    val displayName: String,
    val avatarUrl: String?,
    val isVideo: Boolean,
    val isMuted: Boolean,
    val isVideoMuted: Boolean,
    val statusText: String,
    /** Wall-clock ms the call went active; the notification counts up from here. */
    val chronometerBaseEpochMs: Long?,
) {
    companion object {
        fun fromMap(map: Map<*, *>): OngoingCallInfo = OngoingCallInfo(
            displayName = map["displayName"] as? String ?: "",
            avatarUrl = (map["avatarUrl"] as? String)?.takeIf { it.isNotBlank() },
            isVideo = map["isVideo"] as? Boolean ?: false,
            isMuted = map["isMuted"] as? Boolean ?: false,
            isVideoMuted = map["isVideoMuted"] as? Boolean ?: false,
            statusText = map["statusText"] as? String ?: "",
            chronometerBaseEpochMs = (map["chronometerBaseEpochMs"] as? Number)?.toLong(),
        )
    }
}
