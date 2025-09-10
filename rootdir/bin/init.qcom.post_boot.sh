#! /vendor/bin/sh

# Copyright (c) 2012-2013, 2016-2020, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of The Linux Foundation nor
#       the names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior written
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#! /vendor/bin/sh
# ============================================
# init.qcom.post_boot.sh - Optimized by Amin
# Realme 6 Pro (SM7125 - Snapdragon 720G)
# CAF-style functions, cleaned + enhancements
# ============================================

# -------------------------
# Mode selection
# -------------------------
MODE="performance"   # options: "performance" or "battery"

# -------------------------
# CPU Governor Tuning
# -------------------------
configure_cpu_governor() {
    # LITTLE cluster (CPU0–CPU5 (6x Kryo 465 Silver))
    for cpu in 0 1 2 3 4 5; do
        echo schedutil > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor
        echo 200  > /sys/devices/system/cpu/cpu$cpu/cpufreq/schedutil/up_rate_limit_us
        echo 3000 > /sys/devices/system/cpu/cpu$cpu/cpufreq/schedutil/down_rate_limit_us
        echo 1248000 > /sys/devices/system/cpu/cpu$cpu/cpufreq/schedutil/hispeed_freq
        echo 80   > /sys/devices/system/cpu/cpu$cpu/cpufreq/schedutil/hispeed_load
        if [ "$MODE" = "performance" ]; then
            echo 1036800 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_min_freq
        else
            echo 576000 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_min_freq
        fi
    done

    # BIG cluster CPU6–CPU7 (2x Kryo 465 Gold)
    for cpu in 6 7; do
        echo schedutil > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor
        echo 200  > /sys/devices/system/cpu/cpu$cpu/cpufreq/schedutil/up_rate_limit_us
        echo 3000 > /sys/devices/system/cpu/cpu$cpu/cpufreq/schedutil/down_rate_limit_us
        echo 1612800 > /sys/devices/system/cpu/cpu$cpu/cpufreq/schedutil/hispeed_freq
        echo 70   > /sys/devices/system/cpu/cpu$cpu/cpufreq/schedutil/hispeed_load
        if [ "$MODE" = "performance" ]; then
            echo 1248000 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_min_freq
        else
            echo 652800 > /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_min_freq
        fi
    done

    # Input boost
    if [ "$MODE" = "performance" ]; then
        echo "0:1248000 6:1804800" > /sys/module/cpu_boost/parameters/input_boost_freq
        echo 200 > /sys/module/cpu_boost/parameters/input_boost_ms
        echo 1   > /sys/module/cpu_boost/parameters/sched_boost_on_input
    else
        echo "0:960000" > /sys/module/cpu_boost/parameters/input_boost_freq
        echo 100 > /sys/module/cpu_boost/parameters/input_boost_ms
        echo 0   > /sys/module/cpu_boost/parameters/sched_boost_on_input
    fi
}

# -------------------------
# GPU Tuning
# -------------------------
configure_gpu() {
    GPUF=/sys/class/kgsl/kgsl-3d0/devfreq
    if [ "$MODE" = "performance" ]; then
        echo msm-adreno-tz > $GPUF/governor
        echo 305000000  > $GPUF/min_freq
        echo 750000000  > $GPUF/max_freq
        echo 3          > /sys/class/kgsl/kgsl-3d0/default_pwrlevel   # ~490 MHz
        echo 1          > /sys/class/kgsl/kgsl-3d0/adrenoboost
    else
        echo msm-adreno-tz > $GPUF/governor
        echo 180000000  > $GPUF/min_freq
        echo 750000000  > $GPUF/max_freq
        echo 5          > /sys/class/kgsl/kgsl-3d0/default_pwrlevel
        echo 0          > /sys/class/kgsl/kgsl-3d0/adrenoboost
    fi
}

# -------------------------
# Scheduler & SchedTune
# -------------------------
configure_scheduler() {
    # SchedTune groups
    echo 15 > /dev/stune/top-app/schedtune.boost
    echo 1  > /dev/stune/top-app/schedtune.prefer_idle
    echo 5  > /dev/stune/foreground/schedtune.boost
    echo 0  > /dev/stune/background/schedtune.boost
    echo 0  > /dev/stune/system-background/schedtune.boost
    echo 10 > /dev/stune/rt/schedtune.boost

    # Scheduler sysctls
    echo 60  > /proc/sys/kernel/sched_upmigrate
    echo 40  > /proc/sys/kernel/sched_downmigrate
    echo 90  > /proc/sys/kernel/sched_group_upmigrate
    echo 70  > /proc/sys/kernel/sched_group_downmigrate
    echo 500000   > /proc/sys/kernel/sched_migration_cost_ns
    echo 1000000  > /proc/sys/kernel/sched_wakeup_granularity_ns
    echo 30  > /proc/sys/kernel/sched_min_task_util_for_boost
    echo 25  > /proc/sys/kernel/sched_min_task_util_for_colocation
    echo 1   > /proc/sys/kernel/sched_sync_hint_enable
    echo 1   > /proc/sys/kernel/sched_walt_rotate_big_tasks
}

# -------------------------
# I/O Tuning
# -------------------------
configure_io() {
    echo noop  > /sys/block/sda/queue/scheduler
    echo 256   > /sys/block/sda/queue/read_ahead_kb
    echo 0     > /sys/block/sda/queue/iostats
}

# -------------------------
# Memory & VM Tuning
# -------------------------
configure_memory() {
    echo 300  > /proc/sys/vm/dirty_writeback_centisecs
    echo 1500 > /proc/sys/vm/dirty_expire_centisecs
    echo 65536  > /proc/sys/vm/min_free_kbytes
    echo 32768  > /proc/sys/vm/extra_free_kbytes
    echo 0    > /proc/sys/vm/oom_kill_allocating_task
    echo 60   > /proc/sys/vm/overcommit_ratio
    echo 0    > /proc/sys/vm/laptop_mode
    echo 50   > /proc/sys/vm/vfs_cache_pressure
    echo 60   > /proc/sys/vm/swappiness

    # Force ZRAM setup (4 GB, lz4) for digital RAM
    swapoff /dev/block/zram0 2>/dev/null
    echo 1   > /sys/block/zram0/reset
    echo lz4 > /sys/block/zram0/comp_algorithm
    echo 4294967296 > /sys/block/zram0/disksize   # 4 GB swap (3096 MB)
    mkswap /dev/block/zram0
    swapon /dev/block/zram0 -p 32758
}

# -------------------------
# Thermal Tuning
# -------------------------
configure_thermal() {
    for zone in /sys/class/thermal/thermal_zone*; do
        echo 95 > $zone/trip_point_0_temp 2>/dev/null
        echo 105 > $zone/trip_point_1_temp 2>/dev/null
    done
    echo 1 > /sys/class/kgsl/kgsl-3d0/throttling
    echo 0 > /sys/class/kgsl/kgsl-3d0/thermal_pwrlevel
}

# -------------------------
# Network & WiFi Tuning
# -------------------------
configure_network() {
    # Stronger WiFi connectivity
    echo 1 > /sys/module/wlan/parameters/iw_power_save_disable 2>/dev/null

    # TCP performance tweaks
    echo 1 > /proc/sys/net/ipv4/tcp_low_latency
    echo 0 > /proc/sys/net/ipv4/tcp_timestamps
    echo 1 > /proc/sys/net/ipv4/tcp_sack
    echo 1 > /proc/sys/net/ipv4/tcp_window_scaling
    echo 1 > /proc/sys/net/ipv4/tcp_tw_reuse
}

# -------------------------
# Boot Speed Optimizations
# -------------------------
configure_bootspeed() {
    echo 0 > /sys/module/printk/parameters/console_suspend
    echo N > /sys/module/rcupdate/parameters/rcu_expedited
    echo N > /sys/module/rcupdate/parameters/rcu_normal_after_boot
    echo 0 > /proc/sys/kernel/printk
}

# ============================================
# Main Execution
# ============================================
configure_cpu_governor
configure_gpu
configure_scheduler
configure_io
configure_memory
configure_thermal
configure_network
configure_bootspeed

# End of custom post-boot config
