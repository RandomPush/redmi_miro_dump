#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Inherit from miro device
$(call inherit-product, device/xiaomi/miro/device.mk)

PRODUCT_DEVICE := miro
PRODUCT_NAME := lineage_miro
PRODUCT_BRAND := Redmi
PRODUCT_MODEL := 24122RKC7C
PRODUCT_MANUFACTURER := xiaomi

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="missi-user 15 AQ3A.240829.003 OS2.0.11.0.VOMCNXM release-keys"

BUILD_FINGERPRINT := Redmi/miro/miro:15/AQ3A.240829.003/OS2.0.11.0.VOMCNXM:user/release-keys
