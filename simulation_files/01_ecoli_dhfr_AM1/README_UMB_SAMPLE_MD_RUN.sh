#!/bin/bash
#

# SET BY USER: NECESSARY DIRECTORY PATHS
export CONDA_ENV_DIR=/usr/local/miniforge3/envs/c47a1qmhubv1env
export SQM_INSTALL_DIR=/home/raafik/amber_omp
export CHARMM_DIR=/home/raafik/c47a1-qmhub-v1
# SET BY USER: ASSIGN NUMBER OF PROCESSORS 
export OMP_NUM_THREADS=1
charmm_nproc=1

#==============================================================

# SETTING UP CONDA ENVIRONMENT (FOR QMHub AND helPME)
source $CONDA_ENV_DIR/../../activate_conda_env.sh
conda activate pycharmmenv
export LD_PRELOAD=$CONDA_ENV_DIR/lib/libmkl_core.so:$CONDA_ENV_DIR/lib/libmkl_sequential.so

# SETTING 'SQM' (AMBERTOOLS) TO PATH
source $SQM_INSTALL_DIR/amber.sh

# SETTING MODIFIED CHARMM LOCATION AND INPUT FILES
charmm=$CHARMM_DIR/charmm_install_dir/bin/charmm
equi_prefix=step4.0_equilibration
qmpr_prefix=step4.1_qmmmprep
prod_prefix=step5_production_nvt
prod_step=step5
umb_window=window
qm_package=qmhub

#==============================================================

# MINIMIZATION AND EQUILIBRATION MD

mpirun -np 4 ${charmm} < ${equi_prefix}.inp > ${equi_prefix}.out

#==============================================================

# QM/MM INPUT PREPERATION 

${charmm} < ${qmpr_prefix}.inp > ${qmpr_prefix}.out

#==============================================================

# QM/MM MD WITH UMBRELLA SAMPLING (US)

cntmax=6 # 'cntmax' number of chunks per window
win=1 # starting US window 
winmax=41 # finishing US window

for ((i=$win;i<=$winmax;i++)); do
    cnt=1  # restart control
    while [ $cnt -le $cntmax ]; do
        pcnt=$(( cnt - 1 ))
        istep=${prod_step}_${umb_window}_${i}_${cnt}
        pstep=${prod_step}_${umb_window}_${i}_${pcnt}
        if [ ${cnt} -eq 1 ]; then
            pstep=${equi_prefix}
        fi

        ${charmm} win=${i} cnt=${cnt} cntmax=${cntmax} qm_package=${qm_package} < ${prod_prefix}.inp > ${istep}.out
        cnt=$(( cnt + 1 ))
    done
done

#==============================================================

