#!/bin/bash
set -e
pegasus_lite_version_major="4"
pegasus_lite_version_minor="9"
pegasus_lite_version_patch="2dev"
pegasus_lite_enforce_strict_wp_check="true"
pegasus_lite_version_allow_wp_auto_download="true"

. pegasus-lite-common.sh

pegasus_lite_init

# cleanup in case of failures
trap pegasus_lite_signal_int INT
trap pegasus_lite_signal_term TERM
trap pegasus_lite_unexpected_exit EXIT

echo -e "\n########################[Pegasus Lite] Setting up workdir ########################"  1>&2
# work dir
pegasus_lite_setup_work_dir

echo -e "\n##############[Pegasus Lite] Figuring out the worker package to use ##############"  1>&2
# figure out the worker package to use
pegasus_lite_worker_package

set -e

echo -e "\n########[Pegasus Lite] Writing out script to launch user task in container ########"  1>&2

cat <<EOF > namd2_ID0000004-cont.sh
#!/bin/bash
echo -e "\n#################[Container] Now in pegasus lite container script #################"  1>&2
set -e
# setting environment variables for job
EOF
container_env /scratch >> namd2_ID0000004-cont.sh
cat <<EOF2 >> namd2_ID0000004-cont.sh
pegasus_lite_version_major=$pegasus_lite_version_major
pegasus_lite_version_minor=$pegasus_lite_version_minor
pegasus_lite_version_patch=$pegasus_lite_version_patch
pegasus_lite_enforce_strict_wp_check=false
pegasus_lite_version_allow_wp_auto_download=$pegasus_lite_version_allow_wp_auto_download
pegasus_lite_work_dir=/scratch
echo \$PWD  1>&2
. pegasus-lite-common.sh
pegasus_lite_init


echo -e "\n##############[Container] Figuring out Pegasus worker package to use ##############"  1>&2
# figure out the worker package to use
pegasus_lite_worker_package
echo "PATH in container is set to is set to \$PATH"  1>&2

echo -e "\n###################### Staging in input data and executables ######################"  1>&2
# stage in data and executables
$PEGASUS_HOME/bin/pegasus-transfer --threads 1  --symlink  1>&2 << 'eof'
[
 { "type": "transfer",
   "linkage": "input",
   "lfn": "par_all27_prot_lipid.inp",
   "id": 1,
   "src_urls": [
     { "site_label": "cori", "url": "file:///global/cscratch1/sd/papajim/georgpap/pegasus/namd_wf/run0001/./par_all27_prot_lipid.inp", "checkpoint": "false" }
   ],
   "dest_urls": [
     { "site_label": "cori", "url": "file:///scratch/par_all27_prot_lipid.inp" }
   ] }
 ,
 { "type": "transfer",
   "linkage": "input",
   "lfn": "crd.md18_vmd_autopsf.pdb",
   "id": 2,
   "src_urls": [
     { "site_label": "cori", "url": "file:///global/cscratch1/sd/papajim/georgpap/pegasus/namd_wf/run0001/./crd.md18_vmd_autopsf.pdb", "checkpoint": "false" }
   ],
   "dest_urls": [
     { "site_label": "cori", "url": "file:///scratch/crd.md18_vmd_autopsf.pdb" }
   ] }
 ,
 { "type": "transfer",
   "linkage": "input",
   "lfn": "equilibrate_250.restart.xsc",
   "id": 3,
   "src_urls": [
     { "site_label": "cori", "url": "file:///global/cscratch1/sd/papajim/georgpap/pegasus/namd_wf/run0001/./equilibrate_250.restart.xsc", "checkpoint": "false" }
   ],
   "dest_urls": [
     { "site_label": "cori", "url": "file:///scratch/equilibrate_250.restart.xsc" }
   ] }
 ,
 { "type": "transfer",
   "linkage": "input",
   "lfn": "production_250.conf",
   "id": 4,
   "src_urls": [
     { "site_label": "cori", "url": "file:///global/cscratch1/sd/papajim/georgpap/pegasus/namd_wf/run0001/./production_250.conf", "checkpoint": "false" }
   ],
   "dest_urls": [
     { "site_label": "cori", "url": "file:///scratch/production_250.conf" }
   ] }
 ,
 { "type": "transfer",
   "linkage": "input",
   "lfn": "equilibrate_250.restart.coor",
   "id": 5,
   "src_urls": [
     { "site_label": "cori", "url": "file:///global/cscratch1/sd/papajim/georgpap/pegasus/namd_wf/run0001/./equilibrate_250.restart.coor", "checkpoint": "false" }
   ],
   "dest_urls": [
     { "site_label": "cori", "url": "file:///scratch/equilibrate_250.restart.coor" }
   ] }
 ,
 { "type": "transfer",
   "linkage": "input",
   "lfn": "equilibrate_250.restart.vel",
   "id": 6,
   "src_urls": [
     { "site_label": "cori", "url": "file:///global/cscratch1/sd/papajim/georgpap/pegasus/namd_wf/run0001/./equilibrate_250.restart.vel", "checkpoint": "false" }
   ],
   "dest_urls": [
     { "site_label": "cori", "url": "file:///scratch/equilibrate_250.restart.vel" }
   ] }
 ,
 { "type": "transfer",
   "linkage": "input",
   "lfn": "Q42.psf",
   "id": 7,
   "src_urls": [
     { "site_label": "cori", "url": "file:///global/cscratch1/sd/papajim/georgpap/pegasus/namd_wf/run0001/./Q42.psf", "checkpoint": "false" }
   ],
   "dest_urls": [
     { "site_label": "cori", "url": "file:///scratch/Q42.psf" }
   ] }
]
eof

echo -e "\n###############[Container] Checking file integrity for input files ###############"  1>&2
# do file integrity checks
pegasus-integrity --print-timings --verify=stdin 1>&2 << 'eof'
par_all27_prot_lipid.inp:crd.md18_vmd_autopsf.pdb:equilibrate_250.restart.xsc:production_250.conf:equilibrate_250.restart.coor:equilibrate_250.restart.vel:Q42.psf
eof

set +e
job_ec=0
echo -e "\n#########################[Container] Launching user task #########################"  1>&2

pegasus-kickstart  -n namd2 -N ID0000004 -R cori  -s production_250.dcd=production_250.dcd -L namd_wf -T 2019-03-28T16:24:54-07:00 /opt/NAMD_2.12_Linux-x86_64-multicore/namd2 +p 32 production_250.conf
set -e
echo -e "\n############################ Staging out output files ############################"  1>&2
# stage out
$PEGASUS_HOME/bin/pegasus-transfer --threads 1  1>&2 << 'eof'
[
 { "type": "transfer",
   "linkage": "output",
   "lfn": "",
   "id": 1,
   "src_urls": [
     { "site_label": "cori", "url": "file:///scratch/production_250.dcd", "checkpoint": "false" }
   ],
   "dest_urls": [
     { "site_label": "cori", "url": "file:///global/cscratch1/sd/papajim/georgpap/pegasus/namd_wf/run0001/./production_250.dcd" }
   ] }
]
eof

echo -e "\n################[Container] Exiting pegasus lite container script ################"  1>&2
EOF2


chmod +x namd2_ID0000004-cont.sh
if ! [ $pegasus_lite_start_dir -ef . ]; then
	cp $pegasus_lite_start_dir/pegasus-lite-common.sh . 
fi

set +e
shifter_init papajim/namd_image:latest
job_ec=$(($job_ec + $?))

shifter --image papajim/namd_image:latest --volume $PWD:/scratch --workdir=/scratch ./namd2_ID0000004-cont.sh 
job_ec=$(($job_ec + $?))


set -e


# clear the trap, and exit cleanly
trap - EXIT
pegasus_lite_final_exit

