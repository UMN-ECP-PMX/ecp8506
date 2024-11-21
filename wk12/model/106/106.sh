#!/bin/bash

#$ -wd /panfs/jay/groups/35/cheng423/cheng423/learning/project-abc/model/106

/common/software/install/manual/nonmem/750/run/nmfe75 106.mod  106.lst  -parafile=106.pnm -maxlim=2
