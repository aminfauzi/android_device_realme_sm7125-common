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

#pragma once

#include <aidl/android/hardware/light/BnLights.h>

#include <array>
#include <mutex>
#include <vector>

namespace aidl {
namespace android {
namespace hardware {
namespace light {

class Light : public BnLights {
  public:
    Light();

    ndk::ScopedAStatus setLightState(int32_t id, const HwLightState& state) override;
    ndk::ScopedAStatus getLights(std::vector<HwLight>* lights) override;
    ndk::ScopedAStatus setLightEffects(const std::vector<HwLightEffect>& effects) override;

  private:
    void handleBacklight(const HwLightState& state);
    void handleNotification(const HwLightState& state, size_t index);

    std::mutex mLock;
    std::vector<HwLight> mLights;
    std::array<HwLightState, 3> mLightStates;
};

}  // namespace light
}  // namespace hardware
}  // namespace android
}  // namespace aidl
