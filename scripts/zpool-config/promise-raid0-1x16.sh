#!/bin/bash
#
# Flash (White Box) Raid-0 Configuration (1x16)
#

RANKS=8
CHANNELS=2

zpool_create() {
	udev_setup ${UDEVDIR}/99-zpool.rules.promise
	udev_raid0_setup ${RANKS} ${CHANNELS}

	msg ${ZPOOL} create ${FORCE_FLAG} ${ZPOOL_NAME} ${RAID0S[*]}
	${ZPOOL} create ${FORCE_FLAG} ${ZPOOL_NAME} ${RAID0S[*]} || exit 1
}

zpool_destroy() {
	msg ${ZPOOL} destroy ${ZPOOL_NAME}
	${ZPOOL} destroy ${ZPOOL_NAME}
}
