#!/vendor/bin/sh

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

# ============================================
# init.qcom.post_boot.sh
# Realme 6 Pro (RMX2061 / SM7125 / Snapdragon 720G)
# Balanced profile: smooth UI, sane battery life.
#
# Debug: logcat -s post_boot
# Missing / denied nodes are logged, never fatal.
# ============================================

TAG=post_boot

# --------------------------------------------
# Helpers
# --------------------------------------------

# w <value> <file> : write only if the node exists, log on failure.
w() {
    if [ ! -e "$2" ]; then
        log -t $TAG "missing: $2"
        return 1
    fi
    { echo "$1" > "$2"; } 2>/dev/null || {
        log -t $TAG "write failed: $2"
        return 1
    }
}

# pick_freq <first_cpu_of_cluster> <target_khz>
# Prints the lowest available frequency >= target (falls back to target).
pick_freq() {
    pf_best=""
    for pf_f in $(cat /sys/devices/system/cpu/cpu$1/cpufreq/scaling_available_frequencies 2>/dev/null); do
        if [ "$pf_f" -ge "$2" ]; then
            if [ -z "$pf_best" ] || [ "$pf_f" -lt "$pf_best" ]; then
                pf_best=$pf_f
            fi
        fi
    done
    echo "${pf_best:-$2}"
}

# --------------------------------------------
# CPU governor (schedutil, per cluster)
# --------------------------------------------

# tune_cluster <first_cpu> <up_rate_us> <down_rate_us> <hispeed_freq_khz> <hispeed_load>
tune_cluster() {
    tc_p=/sys/devices/system/cpu/cpu$1/cpufreq
    if [ ! -d "$tc_p" ]; then
        log -t $TAG "cpu$1 cpufreq missing"
        return
    fi

    w schedutil "$tc_p/scaling_governor"
    # Make sure nothing keeps a high frequency floor
    w "$(cat $tc_p/cpuinfo_min_freq)" "$tc_p/scaling_min_freq"

    w "$2" "$tc_p/schedutil/up_rate_limit_us"
    w "$3" "$tc_p/schedutil/down_rate_limit_us"
    w "$(pick_freq $1 $4)" "$tc_p/schedutil/hispeed_freq"
    w "$5" "$tc_p/schedutil/hispeed_load"
}

configure_cpu_governor() {
    # LITTLE: CPU0-5 (6x Kryo 465 Silver)
    tune_cluster 0 500 10000 1248000 85
    # BIG: CPU6-7 (2x Kryo 465 Gold)
    tune_cluster 6 500 5000 1612800 80

    # Short, light input boost (only if cpu_boost exists in this kernel)
    cb=/sys/module/cpu_boost/parameters
    if [ -d "$cb" ]; then
        w "0:$(pick_freq 0 1209600) 6:$(pick_freq 6 1152000)" "$cb/input_boost_freq"
        w 150 "$cb/input_boost_ms"
        w 0   "$cb/sched_boost_on_input"
    else
        log -t $TAG "cpu_boost not present, skipping input boost"
    fi
}

# --------------------------------------------
# GPU
# --------------------------------------------
configure_gpu() {
    g=/sys/class/kgsl/kgsl-3d0
    w msm-adreno-tz "$g/devfreq/governor"
    w 1 "$g/adrenoboost"
}

# --------------------------------------------
# Scheduler (WALT) & SchedTune
# --------------------------------------------
configure_scheduler() {
    # SchedTune groups
    w 10 /dev/stune/top-app/schedtune.boost
    w 1  /dev/stune/top-app/schedtune.prefer_idle
    w 0  /dev/stune/foreground/schedtune.boost
    w 0  /dev/stune/background/schedtune.boost
    w 0  /dev/stune/system-background/schedtune.boost

    # WALT migration thresholds (less eager to use the big cores)
    w 80 /proc/sys/kernel/sched_upmigrate
    w 60 /proc/sys/kernel/sched_downmigrate
    w 90 /proc/sys/kernel/sched_group_upmigrate
    w 70 /proc/sys/kernel/sched_group_downmigrate

    w 500000  /proc/sys/kernel/sched_migration_cost_ns
    w 1000000 /proc/sys/kernel/sched_wakeup_granularity_ns
    w 30 /proc/sys/kernel/sched_min_task_util_for_boost
    w 25 /proc/sys/kernel/sched_min_task_util_for_colocation
    w 1  /proc/sys/kernel/sched_sync_hint_enable
    w 1  /proc/sys/kernel/sched_walt_rotate_big_tasks
}

# --------------------------------------------
# I/O (UFS)
# --------------------------------------------
configure_io() {
    for dev in sda sdb sdc sdd sde sdf; do
        q=/sys/block/$dev/queue
        [ -d "$q" ] || continue

        if grep -q noop "$q/scheduler" 2>/dev/null; then
            w noop "$q/scheduler"
        elif grep -q none "$q/scheduler" 2>/dev/null; then
            w none "$q/scheduler"
        fi
        w 128 "$q/read_ahead_kb"
        w 0   "$q/iostats"
        w 0   "$q/add_random"
        w 2   "$q/rq_affinity"
    done
}

# --------------------------------------------
# ZRAM (4 GB, lz4)
# fstab.default has no zram entry, so it is set up here.
# Skips everything if zram0 is already active (e.g. set up
# by fstab/init), so no swapoff/reset race.
# --------------------------------------------
configure_zram() {
    z=/sys/block/zram0
    if [ ! -e $z/disksize ]; then
        log -t $TAG "no zram0 device"
        return
    fi
    if grep -q zram0 /proc/swaps; then
        log -t $TAG "zram0 already active"
        return
    fi
    w 1 $z/reset
    w lz4 $z/comp_algorithm
    w 8 $z/max_comp_streams
    w 4294967296 $z/disksize
    mkswap /dev/block/zram0 >/dev/null 2>&1
    swapon /dev/block/zram0 -p 32758
}

# --------------------------------------------
# Memory & VM
# --------------------------------------------
configure_memory() {
    w 300   /proc/sys/vm/dirty_writeback_centisecs
    w 1500  /proc/sys/vm/dirty_expire_centisecs
    w 32768 /proc/sys/vm/min_free_kbytes
    w 16384 /proc/sys/vm/extra_free_kbytes
    w 60    /proc/sys/vm/vfs_cache_pressure
    w 100   /proc/sys/vm/swappiness
    w 0     /proc/sys/vm/page-cluster
}

# ============================================
# Main
# ============================================
log -t $TAG "start"

configure_cpu_governor
configure_gpu
configure_scheduler
configure_io
configure_zram
configure_memory

# Stock CAF scripts signal completion this way; some init rc files may wait on it.
setprop vendor.post_boot.parsed 1

log -t $TAG "done"
