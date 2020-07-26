#ChamoOS


if test "`whoami`" != "root" ; then
	echo "You must be logged in as root to build (for loopback mounting)"
	echo "Enter 'su' or 'sudo bash' to switch to root"
	exit
fi


if [ ! -e disk_images/chamoOS.flp ]
then

	mkdosfs -C disk_images/chamoOS.flp 1440 || exit
fi



cd source/bootload
nasm -O0 -w+orphan-labels -f bin -o bootload.bin bootload.asm || exit



cd ..
nasm -O0 -w+orphan-labels -f bin -o kernel.bin kernel.asm || exit
cd ..




dd status=noxfer conv=notrunc if=source/bootload/bootload.bin of=disk_images/chamoOS.flp || exit



rm -rf tmp-loop

mkdir tmp-loop && mount -o loop -t vfat disk_images/chamoOS.flp tmp-loop && cp source/kernel.bin tmp-loop/



sleep 0.2



umount tmp-loop || exit

rm -rf tmp-loop





rm -f disk_images/chamoOS.iso
mkisofs -quiet -V 'P-OS' -input-charset iso8859-1 -o disk_images/chamoOS.iso -b chamoOS.flp disk_images/ || exit

qemu-system-x86_64 -cdrom disk_images/chamoOS.iso
echo '>>> Done sucessfully'


