#
# Copyright (C) 2021 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# ==========================================
# Inherit common product configurations
# ==========================================
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)
$(call inherit-product-if-exists, vendor/realme/sm7125-common/sm7125-common-vendor.mk)
$(call inherit-product, frameworks/native/build/phone-xhdpi-6144-dalvik-heap.mk)
$(call inherit-product, hardware/qcom-caf/common/common.mk)

# ==========================================
# Platform Configuration
# ==========================================
PRODUCT_BOARD_PLATFORM := atoll
PRODUCT_USES_QCOM_HARDWARE := true
PRODUCT_USE_DYNAMIC_PARTITIONS := true
PRODUCT_SHIPPING_API_LEVEL := 29

# ==========================================
# System Properties
# ==========================================
PRODUCT_PROPERTY_OVERRIDES += \
    ro.soc.manufacturer=QTI \
    ro.soc.model=SM7125

# ==========================================
# Components
# ==========================================

## Audio
PRODUCT_PACKAGES += \
    audio.bluetooth.default \
    audio.r_submix.default \
    audio.usb.default \
    libaudio-resampler \
    libvolumelistener \
    libprocessgroup.vendor \
    android.hardware.audio@2.0-service \
    android.hardware.audio@6.0-impl \
    android.hardware.audio.effect@6.0-impl \
    android.hardware.soundtrigger@2.3-impl

PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/audio/odm/,$(TARGET_COPY_OUT_ODM)/etc) \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/audio/vendor/,$(TARGET_COPY_OUT_VENDOR)/etc) \
    frameworks/av/services/audiopolicy/config/a2dp_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/a2dp_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/bluetooth_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/usb_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usb_audio_policy_configuration.xml \
    frameworks/native/data/etc/android.hardware.audio.low_latency.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.low_latency.xml \
    frameworks/native/data/etc/android.hardware.audio.pro.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.pro.xml \
    frameworks/native/data/etc/android.software.midi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.midi.xml

## Bluetooth
PRODUCT_PACKAGES += \
    android.hardware.bluetooth.audio-impl \
    android.hardware.bluetooth@1.0.vendor \
    vendor.qti.hardware.btconfigstore@1.0.vendor \
    vendor.qti.hardware.btconfigstore@2.0.vendor

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml

## Camera
PRODUCT_PACKAGES += \
    android.hardware.camera.provider@2.4-impl \
    android.hardware.camera.provider@2.4-service_64 \
    libcamera_metadata_shim

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.camera.flash-autofocus.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.flash-autofocus.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.camera.full.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.full.xml \
    frameworks/native/data/etc/android.hardware.camera.raw.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.raw.xml

## Display
PRODUCT_PACKAGES += \
    disable_configstore \
    gralloc.qcom \
    hwcomposer.qcom \
    libdisplayconfig.qti \
    libgui_vendor \
    libqdMetaData \
    libsdmcore \
    libsdmutils \
    libvulkan \
    android.hardware.graphics.composer@2.4-service \
    android.hardware.graphics.mapper@3.0-impl-qti-display \
    android.hardware.graphics.mapper@4.0-impl-qti-display \
    vendor.qti.hardware.display.allocator-service \
    vendor.qti.hardware.memtrack-service \
    vendor.display.config@1.5 \
    vendor.display.config@1.11.vendor \
    vendor.display.config@2.0 \
    vendor.display.config@2.0.vendor

## DRM
PRODUCT_PACKAGES += \
    android.hardware.drm@1.0.vendor \
    android.hardware.drm@1.1.vendor \
    android.hardware.drm@1.2.vendor \
    android.hardware.drm@1.3.vendor \
    android.hardware.drm@1.4.vendor

## Fingerprint
PRODUCT_PACKAGES += \
    android.hardware.biometrics.fingerprint@2.3-service.realme_sm7125 \
    android.hardware.biometrics.fingerprint@2.1.vendor \
    android.hardware.biometrics.fingerprint@2.2.vendor \
    android.hardware.biometrics.fingerprint@2.3.vendor

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.fingerprint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.fingerprint.xml

## FM Radio
PRODUCT_PACKAGES += \
    FM2

## GPS
PRODUCT_PACKAGES += \
    libsensorndkbridge

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.location.gps.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.location.gps.xml

## Graphics
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.opengles.aep.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.opengles.aep.xml

## Health
PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl-qti \
    android.hardware.health@2.1-service

## HIDL
PRODUCT_PACKAGES += \
    android.hidl.base@1.0 \
    android.hidl.base@1.0.vendor \
    android.hidl.manager@1.0 \
    android.hidl.manager@1.0.vendor \
    libhidltransport \
    libhidltransport.vendor \
    libhwbinder \
    libhwbinder.vendor

## Init
PRODUCT_PACKAGES += \
    fstab.default \
    ueventd.qcom.rc

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/fstab.default:$(TARGET_COPY_OUT_RAMDISK)/fstab.default \

# ODM init files
PRODUCT_PACKAGES += \
    init.oppo.debug.diag.rc \
    init.oppo.display.rc_odm

# Vendor init files
PRODUCT_PACKAGES += \
    init.oppo.display.rc_vendor \
    init.qcom.rc \
    init.qti.ufs.rc \
    init.target.rc \
    init.qcom.factory.rc \
    init.qcom.usb.rc \
    init.sm7125.rc

# Recovery init script
PRODUCT_PACKAGES += \
    init.recovery.qcom.sh

# Vendor shell scripts
PRODUCT_PACKAGES += \
    init.at.class_main.sh \
    init.qcom.sdio.sh \
    init.qti.dcvs.sh \
    init.at.post_boot.sh \
    init.qcom.coex.sh \
    init.qcom.sensors.sh \
    init.qti.qcv.sh \
    init.class_main.sh \
    init.qcom.early_boot.sh \
    init.qcom.sh \
    init.crda.sh \
    init.qcom.efs.sync.sh \
    init.qcom.usb.sh \
    init.mdm.sh \
    init.qcom.post_boot.sh \
    init.qti.chg_policy.sh

## IPACM
PRODUCT_PACKAGES += \
    ipacm \
    IPACM_cfg.xml

## Keylayout
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/keylayout/gpio-keys.kl:system/usr/keylayout/gpio-keys.kl

## Lights
PRODUCT_PACKAGES += \
    android.hardware.light@2.0-service.realme_sm7125

## Media
PRODUCT_PACKAGES += \
    libmm-omxcore \
    libOmxAacEnc \
    libOmxAmrEnc \
    libOmxCore \
    libOmxEvrcEnc \
    libOmxG711Enc \
    libOmxQcelp13Enc \
    libOmxVdec \
    libOmxVenc \
    libstagefrighthw

PRODUCT_PROPERTY_OVERRIDES += \
    debug.stagefright.c2inputsurface=-1 \
    debug.stagefright.ccodec=4

PRODUCT_COPY_FILES += \
    frameworks/av/media/libstagefright/data/media_codecs_google_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_audio.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_c2.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_c2.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_c2_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_c2_audio.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_c2_video.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_c2_video.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_telephony.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_telephony.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_video.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_video.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_video_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_video_le.xm \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/configs/media/vendor,$(TARGET_COPY_OUT_VENDOR)/etc) \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/configs/media/odm/,$(TARGET_COPY_OUT_ODM)/etc)

## Minijail
PRODUCT_PACKAGES += \
    libavservices_minijail \
    libavservices_minijail.vendor \
    libminijail

## Network
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.ipsec_tunnels.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.ipsec_tunnels.xml \
    frameworks/native/data/etc/android.software.ipsec_tunnel_migration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.ipsec_tunnel_migration.xml

## NFC
ifeq ($(BOARD_HAS_NFC),true)
PRODUCT_PACKAGES += \
    NfcNci \
    SecureElement \
    Tag \
    android.hardware.nfc@1.2-service \
    com.android.nfc_extras \
    android.hardware.secure_element@1.0-service-disabled
endif

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/nfc/libese-nxp.conf:$(TARGET_COPY_OUT_VENDOR)/etc/libese-nxp.conf \
    $(LOCAL_PATH)/configs/nfc/nfc_features.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/sku_nfc/nfc_features.xml

## Overlays
DEVICE_PACKAGE_OVERLAYS += \
    $(LOCAL_PATH)/overlay \
    $(LOCAL_PATH)/overlay-lineage

## Power
PRODUCT_PACKAGES += \
    android.hardware.power-service.lineage-libperfmgr \
    android.hardware.power@1.2.vendor \
    libqti-perfd-client

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/powerhint.json:$(TARGET_COPY_OUT_VENDOR)/etc/powerhint.json

## RIL
PRODUCT_PACKAGES += \
    libjson \
    librmnetctl

## Sensors
PRODUCT_PACKAGES += \
    android.hardware.sensors@2.0-service.multihal_realme_sm7125

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.barometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.barometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.compass.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.compass.xml \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.gyroscope.xml \
    frameworks/native/data/etc/android.hardware.sensor.hifi_sensors.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.hifi_sensors.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.light.xml \
    frameworks/native/data/etc/android.hardware.sensor.proximity.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.proximity.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepcounter.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepcounter.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepdetector.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepdetector.xml

## Telephony
PRODUCT_PACKAGES += \
    extphonelib \
    extphonelib-product \
    extphonelib.xml \
    extphonelib_product.xml \
    ims-ext-common \
    ims_ext_common.xml \
    qti-telephony-hidl-wrapper \
    qti-telephony-hidl-wrapper-prd \
    qti_telephony_hidl_wrapper.xml \
    qti_telephony_hidl_wrapper_prd.xml \
    qti-telephony-utils \
    qti-telephony-utils-prd \
    qti_telephony_utils.xml \
    qti_telephony_utils_prd.xml \
    telephony-ext

PRODUCT_BOOT_JARS += \
    telephony-ext

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.telephony.cdma.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.cdma.xml \
    frameworks/native/data/etc/android.hardware.telephony.gsm.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.gsm.xml \
    frameworks/native/data/etc/android.hardware.telephony.ims.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.ims.xml \
    frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.sip.voip.xml

# Thermal
PRODUCT_PACKAGES += \
    android.hardware.thermal-service.qti

## Touchscreen
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml

# UFFD GC
OVERRIDE_ENABLE_UFFD_GC := false

## USB
PRODUCT_PACKAGES += \
    android.hardware.usb@1.3-service.dual_role_usb

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml

## Vibrator
PRODUCT_PACKAGES += \
    vendor.qti.hardware.vibrator.service

## WiFi
PRODUCT_PACKAGES += \
    android.hardware.wifi-service \
    hostapd \
    libwifi-hal-qcom \
    libwpa_client \
    wpa_cli \
    wpa_supplicant \
    wpa_supplicant.conf \
    WifiOverlay

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/wifi/p2p_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/p2p_supplicant_overlay.conf \
    $(LOCAL_PATH)/wifi/wpa_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant_overlay.conf \
    $(LOCAL_PATH)/wifi/WCNSS_qcom_cfg.ini:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/WCNSS_qcom_cfg.ini \
    frameworks/native/data/etc/android.hardware.wifi.aware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.aware.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.hardware.wifi.passpoint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.passpoint.xml \
    frameworks/native/data/etc/android.hardware.wifi.rtt.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.rtt.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml

# ==========================================
# Additional Packages
# ==========================================

## AID/fs configs
PRODUCT_PACKAGES += \
    fs_config_files

## Fastbootd
PRODUCT_PACKAGES += \
    fastbootd

## Partition
PRODUCT_PACKAGES += \
     vendor_bt_firmware_mountpoint \
     vendor_dsp_mountpoint \
     vendor_firmware_mnt_mountpoint

## Protobuf
PRODUCT_PACKAGES += \
    libprotobuf-cpp-full-3.9.1-vendorcompat \
    libprotobuf-cpp-lite-3.9.1

## QTI FWK Detect
PRODUCT_PACKAGES += \
    libqti_vndfwk_detect.vendor \
    libvndfwk_detect_jni.qti.vendor

## Servicetracker
PRODUCT_PACKAGES += \
    vendor.qti.hardware.servicetracker@1.0.vendor \
    vendor.qti.hardware.servicetracker@1.1.vendor \
    vendor.qti.hardware.servicetracker@1.2.vendor

## Vendor service manager
PRODUCT_PACKAGES += \
    vndservicemanager

## VNDK
PRODUCT_PACKAGES += \
    vndk_package

PRODUCT_COPY_FILES += \
    prebuilts/vndk/v30/arm64/arch-arm64-armv8-a/shared/vndk-core/libgui.so:$(TARGET_COPY_OUT_SYSTEM)/lib64/libxxx.so \
    prebuilts/vndk/v30/arm64/arch-arm-armv8-a/shared/vndk-core/libgui.so:$(TARGET_COPY_OUT_SYSTEM)/lib/libxxx.so

## Vulkan
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.vulkan.compute-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.compute.xml \
    frameworks/native/data/etc/android.hardware.vulkan.level-1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.level.xml \
    frameworks/native/data/etc/android.hardware.vulkan.version-1_1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.version.xml \
    frameworks/native/data/etc/android.software.vulkan.deqp.level-2020-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.vulkan.deqp.level.xml

## WiFi Display
PRODUCT_PACKAGES += \
    libnl \
    libwfdaac_vendor

## WiFi Firmware Symlinks
 PRODUCT_PACKAGES += \
     firmware_wlan_mac.bin_symlink \
     firmware_WCNSS_qcom_cfg.ini_symlink

# ==========================================
# Device-specific Packages
# ==========================================

## Blur
TARGET_ENABLE_BLUR := true

# Dolby Atmos
$(call inherit-product, hardware/dolby/dolby.mk)

## Lawnchair
$(call inherit-product-if-exists, vendor/lawnchair/lawnchair.mk)

## NotchBar Killer
PRODUCT_PACKAGES += \
    NotchBarKiller \
    NoCutoutOverlay

## RealmeParts
PRODUCT_PACKAGES += \
    RealmeParts

## Tethering
PRODUCT_PACKAGES += \
    TetheringConfigOverlay

# ==========================================
# Performance Optimization
# ==========================================

## Enable whole-program R8 Java optimizations
SYSTEM_OPTIMIZE_JAVA := true
SYSTEMUI_OPTIMIZE_JAVA := true

## Speed profile services
PRODUCT_SYSTEM_SERVER_COMPILER_FILTER := speed-profile
PRODUCT_ALWAYS_PREOPT_EXTRACTED_APK := true
PRODUCT_USE_PROFILE_FOR_BOOT_IMAGE := true
PRODUCT_DEX_PREOPT_BOOT_IMAGE_PROFILE_LOCATION := frameworks/base/boot/boot-image-profile.txt

## Performance critical applications
PRODUCT_DEXPREOPT_SPEED_APPS += \
    Settings \
    SystemUI

# ==========================================
# Soong namespaces
# ==========================================
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH) \
    hardware/google/interfaces \
    hardware/google/pixel \
    hardware/lineage/interfaces/power-libperfmgr \
    hardware/oplus \
    hardware/qcom-caf/common/libqti-perfd-client \
    kernel/realme/sm7125

$(call soong_config_set,surfaceflinger,udfps_lib,//$(LOCAL_PATH):libudfps_extension.realme_sm7125)
$(call soong_config_set,libinit,vendor_init_lib,//$(LOCAL_PATH):libinit_realme_sm7125)

# ==========================================
# VNDK Libraries
# ==========================================
PRODUCT_PACKAGES += \
    android.frameworks.automotive.display@1.0.vendor \
    android.frameworks.cameraservice.common@2.0.vendor \
    android.frameworks.cameraservice.service@2.1.vendor \
    android.frameworks.displayservice@1.0.vendor \
    android.frameworks.schedulerservice@1.0.vendor \
    android.frameworks.sensorservice@1.0.vendor \
    android.frameworks.stats@1.0.vendor \
    android.hardware.atrace@1.0.vendor \
    android.hardware.audio.common@6.0.vendor \
    android.hardware.audio.effect@6.0.vendor \
    android.hardware.audio@6.0.vendor \
    android.hardware.automotive.vehicle@2.0.vendor \
    android.hardware.biometrics.fingerprint@2.3.vendor \
    android.hardware.bluetooth.audio@2.0.vendor \
    android.hardware.bluetooth@1.1.vendor \
    android.hardware.camera.device@3.6.vendor \
    android.hardware.camera.provider@2.6.vendor \
    android.hardware.drm@1.4.vendor \
    android.hardware.health@2.1.vendor \
    android.hardware.neuralnetworks@1.3.vendor \
    android.hardware.radio@1.5.vendor \
    android.hardware.secure_element@1.2.vendor \
    android.hardware.vibrator@1.3.vendor \
    android.hardware.wifi@1.4.vendor \
    libstdc++_vendor

## Missing Libs
PRODUCT_PACKAGES += \
    libpng.vendor \
    libsqlite.vendor

# ==========================================
# Certified Properties
# ==========================================
$(call inherit-product-if-exists, vendor/certprops/Android.mk)

