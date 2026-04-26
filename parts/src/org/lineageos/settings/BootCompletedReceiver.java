/*
 * Copyright (C) 2015 The CyanogenMod Project
 *               2017-2019 The LineageOS Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.lineageos.settings;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

public class BootCompletedReceiver extends BroadcastReceiver {
    private static final String TAG = "Parts";

    @Override
    public void onReceive(final Context context, Intent intent) {
        String action = intent.getAction();
        Log.i(TAG, "Received action: " + action);

        if (Intent.ACTION_LOCKED_BOOT_COMPLETED.equals(action)) {
            // Logic for before user unlocks (Direct Boot)
        } else if (Intent.ACTION_BOOT_COMPLETED.equals(action)) {
            // Logic for after user unlocks
        }
    }
}
