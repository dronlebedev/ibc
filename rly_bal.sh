#/bin/bash
k1=$(rly keys show $CHAIN_ID_KICHAIN)
k2=$(rly q bal $CHAIN_ID_KICHAIN)
l1=$(rly keys show $CHAIN_ID_LUCINA)
l2=$(rly q bal $CHAIN_ID_LUCINA)
printf "KICHAIN: \n   > %s\n   > %s\nLUCINA: \n   > %s\n   > %s\n" $k1 $k2 $l1 $l2
