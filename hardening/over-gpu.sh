#!/bin/bash

LOG="/var/log/overclock-nvidia.log"
XORG=0
if ! pgrep Xorg ;then
	nohup Xorg &
	sleep 2s
    if ! pgrep Xorg ;then
		echo "$(date): Xorg Echec chargement, Sortie" | tee -a "$LOG"
		exit 1
	fi
	echo "$(date): Xorg chargement OK" | tee -a "$LOG"
else
	echo "$(date): Xorg running" | tee -a "$LOG"
fi

nvidia-smi > "$LOG" 2>&1
if [[ $? -ne 0 ]];then
	cat "$LOG"
	exit 1
fi

declare -a PW_CAP
declare -a MEM_OFFSET
declare -a CK_OFFSET
declare -a I_OFFSET

for smi in $(nvidia-smi --query-gpu=index,name --format=csv,noheader,nounits | awk -F", " 'BEGIN{OFS=""}{print $1";"$2}')
do
	index=$(echo $smi | cut -d";" -f1)
	tgpu=$(echo $smi | cut -d";" -f2)
	case $tgpu in 
		P102-100)	
				PW_CAP[$index]=152
				MEM_OFFSET[$index]=0
				CK_OFFSET[$index]=0
				I_OFFSET[$index]=1
				;;
		*)
				PW_CAP[$index]=107
				MEM_OFFSET[$index]=1400
				CK_OFFSET[$index]=-200
				I_OFFSET[$index]=3
				;;
	esac
done

cards="$(nvidia-smi --query-gpu=count --format=csv,noheader,nounits | tail -1)"
START=0
END=$cards
screens=$(DISPLAY=:0 nvidia-settings --query screens | grep Screens | cut -d " " -f1)

if [[ $screens -ne $cards ]];then
	echo "Screens != Cards: $screens vs $cards - Review the Xorg configuration! - Exiting" | tee -a "$LOG"
	exit 2
fi
for (( i=$START; i<$END; i++ ))
do
	nvidia-smi -i $i -pm ENABLED
	nvidia-smi -i $i -pl ${PW_CAP[$i]}
	if [[ $? -ne 0 ]]; then
		echo "$(date): Error setting PW capping on GPU $i" | tee -a "$LOG"
		exit 3
	fi
	DISPLAY=:0.$i nvidia-settings -a "[gpu:$i]/GPUMemoryTransferRateOffset[${I_OFFSET[$i]}]=${MEM_OFFSET[$i]}" -a "[gpu:$i]/GPUGraphicsClockOffset[${I_OFFSET[$i]}]=${CK_OFFSET[$i]}" &
	sleep 1
done

