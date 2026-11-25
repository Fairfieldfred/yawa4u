package com.fredblair.yawa4u

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Bundle

/**
 * Shown when the user taps the privacy-policy link on Health Connect's
 * permission screen (ACTION_SHOW_PERMISSIONS_RATIONALE, and
 * VIEW_PERMISSION_USAGE on Android 14+). Google Play requires this entry point
 * to display the app's privacy policy, so it opens the policy page in the
 * browser and closes itself.
 */
class HealthPermissionsRationaleActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        try {
            startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(PRIVACY_POLICY_URL)))
        } catch (_: ActivityNotFoundException) {
            // No browser installed — nothing else we can show.
        }
        finish()
    }

    private companion object {
        // Keep in sync with AppConstants.privacyPolicyUrl.
        const val PRIVACY_POLICY_URL = "https://www.blairhouseapps.com/yawa4u/privacy_policy.html"
    }
}
