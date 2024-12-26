## QMHub-CHARMM Interface:
> *Details on the interface setup can be found [here](https://raafik980.github.io/posts/charmm-python-interfacer/)*

- - -

### Step-by-Step Installation Instructions


#### 0. Clone this repository
```bash
git clone https://github.com/raafik980/ML_CHARMM.git
cd ML_CHARMM

#Assign variable to the working directory
export ML_CHARMM_DIR=/path/to/repository
```

#### 1. Setup conda environment
- Follow instructions at [conda.io](https://docs.conda.io/projects/conda/en/latest/index.html) to downlaod and install  conda

```bash
conda activate
conda create -n qmhubenv python=3.9
conda activate qmhubenv
conda install conda-forge::mamba
mamba install -c conda-forge ipython doxygen cmake=3.26.4 make numpy=1.23.4 scipy=1.9.3 mkl gawk pybind11 pytorch pytorch-lightning matplotlib mdanalysis multiprocess tqdm

#Assign variable to the conda environment directory directory
export CONDA_ENV_DIR=/path/to/conda/envs/qmhubenv
```

#### 2. Setup *sqm*
- Follow instruction at [ambermd.org](https://ambermd.org/AmberTools.php) to install AmberTools software suite

```bash
#Assign variable to sqm (AmberTools) installation directory
export SQM_INSTALL_DIR=/path/to/amber_install_dir
```

#### 3. Setup QMHub with helPME
```bash
conda activate qmhubenv

#QMHub
#------
cd $ML_CHARMM_DIR
cd qmhub #  Source: https://github.com/panxl/qmhub.git
pip install .
# (test 'import qmhub' in ipython)

#helPME
#-------
cd $ML_CHARMM_DIR
git clone https://github.com/andysim/helpme.git
cd helpme
mkdir build
cd build
rm -rf * #(clean build directory)

cmake .. -DCMAKE_INSTALL_PREFIX=$CONDA_ENV_DIR -DENABLE_OPENMP=ON -DENABLE_MPI=OFF
make -j4
make install
cp python/helpmelib.cpython-39-x86_64-linux-gnu.so $CONDA_ENV_DIR/lib/python3.9/site-packages/qmhub
```

#### 4. Setup modified CHARMM with QMHub Interface
- Follow the instructions at [charmm.org](https://academiccharmm.org/) to download the CHARMM program
```bash
#Assign variable to the extracted CHARMM directory from the eg: c47a1.tar.gz
export CHARMM_DIR=/path/to/charmm_dir
```
- Implement the modifications to the CHARMM source files as described below
```bash
cp $ML_CHARMM_DIR/charmm_qmhub/source/ltm/psf_ltm.F90 $CHARMM_DIR/source/ltm
cp $ML_CHARMM_DIR/charmm_qmhub/source/gukint/gukini.F90 $CHARMM_DIR/source/gukint
```
- Install modified CHARMM
```bash
conda activate qmhubenv

cd $CHARMM_DIR
mkdir build_dir
cd build_dir
rm -rf * #(clean build directory)

../configure --with-qchem --without-openmm --without-blade --without-cuda --prefix=../install_dir
make -j4
make install
```

- - -

### Simulation Guide


