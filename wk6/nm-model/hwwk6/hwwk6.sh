#!/bin/bash

#$ -wd /users/1/cheng423/ecp8506/wk6/nm-model/hwwk6

/common/software/install/manual/nonmem/750/run/nmfe75 hwwk6.mod  hwwk6.lst  -parafile=hwwk6.pnm -maxlim=2
