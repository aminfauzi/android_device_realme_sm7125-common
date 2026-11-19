/*
 * Copyright (C) 2018 The LineageOS Project
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

#define LOG_TAG "LightsService"

#include "Light.h"

#include <android-base/logging.h>
#include <fstream>
#include <string>

namespace aidl {
namespace android {
namespace hardware {
namespace light {

/*
 * Write value to path and close file.
 */
template <typename T>
static void set(const std::string& path, const T& value) {
    std::ofstream file(path);
    file << value;
}

/*
 * Read from path and close file.
 * Return def in case of any failure.
 */
template <typename T>
static T get(const std::string& path, const T& def) {
    std::ifstream file(path);
    T result;

    file >> result;
    return file.fail() ? def : result;
}

static constexpr int kDefaultMaxBrightness = 255;
static constexpr int kRampSteps = 50;
static constexpr int kRampMaxStepDurationMs = 5;

// Light ids exposed through getLights()
enum LightId : int32_t {
    ID_BACKLIGHT = 0,
    ID_NOTIFICATIONS = 1,
    ID_BATTERY = 2,
    ID_ATTENTION = 3,
};

static uint32_t getBrightness(const HwLightState& state) {
    uint32_t color = static_cast<uint32_t>(state.color);
    uint32_t alpha, red, green, blue;

    // Extract brightness from AARRGGBB
    alpha = (color >> 24) & 0xff;

    // Retrieve each of the RGB colors
    red = (color >> 16) & 0xff;
    green = (color >> 8) & 0xff;
    blue = color & 0xff;

    // Scale RGB colors if a brightness has been applied by the user
    if (alpha != 0xff) {
        red = red * alpha / 0xff;
        green = green * alpha / 0xff;
        blue = blue * alpha / 0xff;
    }

    return (77 * red + 150 * green + 29 * blue) >> 8;
}

static uint32_t rgbToBrightness(const HwLightState& state) {
    uint32_t color = static_cast<uint32_t>(state.color) & 0x00ffffff;
    return ((77 * ((color >> 16) & 0xff)) + (150 * ((color >> 8) & 0xff)) +
            (29 * (color & 0xff))) >> 8;
}

Light::Light() {
    mLights.push_back({ID_BACKLIGHT, 0, LightType::BACKLIGHT});
    mLights.push_back({ID_NOTIFICATIONS, 0, LightType::NOTIFICATIONS});
    mLights.push_back({ID_BATTERY, 0, LightType::BATTERY});
    mLights.push_back({ID_ATTENTION, 0, LightType::ATTENTION});
}

void Light::handleBacklight(const HwLightState& state) {
    int maxBrightness = get("/sys/class/backlight/panel0-backlight/max_brightness", -1);
    if (maxBrightness < 0) {
        maxBrightness = kDefaultMaxBrightness;
    }
    uint32_t sentBrightness = rgbToBrightness(state);
    uint32_t brightness = sentBrightness * maxBrightness / kDefaultMaxBrightness;
    LOG(DEBUG) << "Writing backlight brightness " << brightness << " (orig " << sentBrightness
               << ")";
    set("/sys/class/backlight/panel0-backlight/brightness", brightness);
}

void Light::handleNotification(const HwLightState& state, size_t index) {
    mLightStates.at(index) = state;

    HwLightState stateToUse = mLightStates.front();
    for (const auto& lightState : mLightStates) {
        if (lightState.color & 0xffffff) {
            stateToUse = lightState;
            break;
        }
    }

    uint32_t whiteBrightness = getBrightness(stateToUse);

    uint32_t onMs = stateToUse.flashMode == FlashMode::TIMED ? stateToUse.flashOnMs : 0;
    uint32_t offMs = stateToUse.flashMode == FlashMode::TIMED ? stateToUse.flashOffMs : 0;

    auto getScaledDutyPercent = [](int brightness) -> std::string {
        std::string output;
        for (int i = 0; i <= kRampSteps; i++) {
            if (i != 0) {
                output += ",";
            }
            output += std::to_string(i * 100 * brightness / (kDefaultMaxBrightness * kRampSteps));
        }
        return output;
    };

    // Disable blinking to start
    set("/sys/class/leds/white/blink", 0);

    if (onMs > 0 && offMs > 0) {
        uint32_t pauseLo, pauseHi, stepDuration;
        if (kRampMaxStepDurationMs * kRampSteps > onMs) {
            stepDuration = onMs / kRampSteps;
            pauseHi = 0;
            pauseLo = offMs;  // was left uninitialized in the old code
        } else {
            stepDuration = kRampMaxStepDurationMs;
            pauseHi = onMs - kRampSteps * stepDuration;
            pauseLo = offMs - kRampSteps * stepDuration;
        }

        set("/sys/class/leds/white/start_idx", 0);
        set("/sys/class/leds/white/duty_pcts", getScaledDutyPercent(whiteBrightness));
        set("/sys/class/leds/white/pause_lo", pauseLo);
        set("/sys/class/leds/white/pause_hi", pauseHi);
        set("/sys/class/leds/white/ramp_step_ms", stepDuration);

        // Start blinking
        set("/sys/class/leds/white/blink", 1);
    } else {
        set("/sys/class/leds/white/brightness", whiteBrightness);
    }
}

ndk::ScopedAStatus Light::setLightState(int32_t id, const HwLightState& state) {
    // Lock global mutex until light state is updated.
    std::lock_guard<std::mutex> lock(mLock);

    switch (id) {
        case ID_BACKLIGHT:
            handleBacklight(state);
            break;
        case ID_ATTENTION:
            handleNotification(state, 0);
            break;
        case ID_BATTERY:
            handleNotification(state, 1);
            break;
        case ID_NOTIFICATIONS:
            handleNotification(state, 2);
            break;
        default:
            return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
    }

    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus Light::getLights(std::vector<HwLight>* lights) {
    for (const auto& light : mLights) {
        lights->push_back(light);
    }
    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus Light::setLightEffects(const std::vector<HwLightEffect>& /* effects */) {
    return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
}

}  // namespace light
}  // namespace hardware
}  // namespace android
}  // namespace aidl
