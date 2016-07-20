#!/bin/bash
###############################################################################
# Copyright (C) 2013-2016 Wataha.net
# All Rights Reserved
# LICENSE Creative Commons BY-NC-ND 4.0
# See LICENSE.TXT
#
# Main developer:
#
#	Andrzej (akasei) Adamczyk [e-mail: akasei from wataha.net]
###############################################################################

# zamontuj wirtualną partycję
if mount | grep /mnt > /dev/null; then
	# zasób zajęty, spróbuj odmontować
	echo -n "Something odd, /mnt already mounted. Lets try umount. "
	umount /mnt > /dev/null 2>&1

	# nie udało się, koniec pracy
	if [ $? -gt 0 ]; then
		echo "[FAIL]"
		exit 1
	fi

	# udało się
	echo "[OK]"
fi

# brak katalogu z plikami?
if [ ! -d files ]; then
	echo 'No "files" folder!'
	exit 1
fi

# zamontuj wirtualną partycję
cp partition_fat16_clean.raw partition_fat16.raw
mount -o loop partition_fat16.raw /mnt

# skopiuj pliki na partycję
cp -rvf files/* /mnt

# odmontuj wirtualną partycję
umount /mnt

echo "Files prepared."
