#where the script resides (passed as argument by the upper script)
	SDIR="$1"
#the mountpoint to the tmpfs tree
	TMPFS="$SDIR/support/jdsp4rp5_tmpfs"
#G2 profile: fixed soundfx directory and config targets
		SOUNDFX_DIR=/vendor/lib64/soundfx
		AUDIO_POLICY_TARGET=/vendor/etc/audio/sku_cliffs_qssi/audio_policy_configuration.xml
		AUDIO_EFFECTS_TARGET=/vendor/etc/audio/sku_cliffs/audio_effects.xml

#cleanup
	[ -f "$AUDIO_POLICY_TARGET" ] && umount "$AUDIO_POLICY_TARGET"
	for m in $(mount |grep tmpfs | grep $(basename $TMPFS)| awk -F' on ' '{print $2}' | awk -F' type ' '{print $1}') ; do
		umount -l "$m"
	done

	for m in $(mount |grep tmpfs | grep "$SOUNDFX_DIR"| awk -F' on ' '{print $2}' | awk -F' type ' '{print $1}') ; do
		umount -l "$m"
	done
	
	[ -f "$AUDIO_EFFECTS_TARGET" ] && umount "$AUDIO_EFFECTS_TARGET"

	umount /vendor/etc/acdbdata/MTP

  umount /vendor/etc/audio_policy_volumes.xml
  umount /vendor/etc/default_volume_tables.xml
  umount /vendor/etc/mixer_paths_qrd.xml

#restart audio system
	killall -q audioserver
	killall -q mediaserver

#Close global effect control session for manager consistency.
am broadcast --user 0 -a android.media.action.CLOSE_AUDIO_EFFECT_CONTROL_SESSION \
	--ei android.media.extra.AUDIO_SESSION 0 \
	--es android.media.extra.PACKAGE_NAME james.dsp
