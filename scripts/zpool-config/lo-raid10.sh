#!/bin/bash
#
# 4 Device Loopback Raid-0 Configuration
#

FILES_M1="/tmp/zpool-vdev0  \
          /tmp/zpool-vdev1"
FILES_M2="/tmp/zpool-vdev2  \
          /tmp/zpool-vdev3"
FILES="${FILES_M1} ${FILES_M2}"
DEVICES_M1=""
DEVICES_M2=""

zpool_create() {
	for FILE in ${FILES_M1}; do
		DEVICE=`unused_loop_device`
		msg "Creating ${FILE} using loopback device ${DEVICE}"
		rm -f ${FILE} || exit 1
		dd if=/dev/zero of=${FILE} bs=1024k count=256 &>/dev/null ||
			die "Error $? creating ${FILE}"
		${LOSETUP} ${DEVICE} ${FILE} ||
			die "Error $? creating ${FILE} -> ${DEVICE} loopback"
		DEVICES_M1="${DEVICES_M1} ${DEVICE}"
	done

	for FILE in ${FILES_M2}; do
		DEVICE=`unused_loop_device`
		msg "Creating ${FILE} using loopback device ${DEVICE}"
		rm -f ${FILE} || exit 1
		dd if=/dev/zero of=${FILE} bs=1024k count=256 &>/dev/null ||
			die "Error $? creating ${FILE}"
		${LOSETUP} ${DEVICE} ${FILE} ||
			die "Error $? creating ${FILE} -> ${DEVICE} loopback"
		DEVICES_M2="${DEVICES_M2} ${DEVICE}"
	done

	msg ${ZPOOL} create ${FORCE_FLAG} ${ZPOOL_NAME} \
		mirror ${DEVICES_M1} mirror ${DEVICES_M2}
	${ZPOOL} create ${FORCE_FLAG} ${ZPOOL_NAME} \
		mirror ${DEVICES_M1} mirror ${DEVICES_M2}
}

zpool_destroy() {
	msg ${ZPOOL} destroy ${ZPOOL_NAME}
	${ZPOOL} destroy ${ZPOOL_NAME}

	for FILE in ${FILES}; do
		DEVICE=`${LOSETUP} -a | grep ${FILE} | head -n1|cut -f1 -d:`
		msg "Removing ${FILE} using loopback device ${DEVICE}"
		${LOSETUP} -d ${DEVICE} ||
			die "Error $? destroying ${FILE} -> ${DEVICE} loopback"
		rm -f ${FILE} || exit 1
	done
}
