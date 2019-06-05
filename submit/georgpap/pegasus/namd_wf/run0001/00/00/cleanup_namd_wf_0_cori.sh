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

pegasus_lite_section_start stage_in
pegasus_lite_section_end stage_in
set +e
job_ec=0
pegasus_lite_section_start task_execute
echo -e "\n######################[Pegasus Lite] Executing the user task ######################"  1>&2
pegasus-kickstart -n pegasus::cleanup -N null -i - -R cori  -L namd_wf -T 2019-03-28T16:24:54-07:00 /global/common/software/m2187/pegasus-wrappers/pegasus-transfer 
job_ec=$?
pegasus_lite_section_end task_execute
set -e
pegasus_lite_section_start stage_out
pegasus_lite_section_end stage_out

set -e


# clear the trap, and exit cleanly
trap - EXIT
pegasus_lite_final_exit

