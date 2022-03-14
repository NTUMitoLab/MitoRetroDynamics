# MitoChannelAnalysis

[![CI](https://github.com/stevengogogo/MitoChannelAnalysis/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/stevengogogo/MitoChannelAnalysis/actions/workflows/ci.yml) [![docs](https://github.com/stevengogogo/MitoChannelAnalysis/actions/workflows/docs.yml/badge.svg?branch=main)](https://github.com/stevengogogo/MitoChannelAnalysis/actions/workflows/docs.yml)

<img width="1177" alt="Graphical Abstract" src="https://user-images.githubusercontent.com/29009898/130342513-081f4592-3cc6-4468-ba3b-868416f3be6b.png">

Codes, data and notebooks for the manuscript titled "Mathematical Modeling and Analysis of Mitochondrial Retrograde Signaling Dynamics"


## Notebooks

|Notebooks|Source code|Description|
|---|---|---|
|[FrequencyResponse.ipynb](FrequencyResponse.ipynb)|[FrequencyResponse/](FrequencyResponse/)|Generate frequency analysis on retrograde signaling model|
|[RobustAnalysis.ipynb](RobustAnalysis.ipynb)|[RobustnessAnalysis/](RobustAnalysis/)|Simulation of retrograde signaling model integrated with Chemical langevin equation|
|[SteadyStates.ipynb](SteadyStates.ipynb)|[SteadyStates/](SteadyStates/)|Steady state solutions under multiple knockout conditions and visualization|
|[validation.ipynb](validatoin.ipynb)|Validate the retrograde response with different expreesion level of RTG proteins|



## Toolbox Developed for this Research

- Ultrasensitivity Analysis: https://github.com/stevengogogo/EstimHill.jl
- Steady State Explorer: https://github.com/stevengogogo/FindSteadyStates.jl


## Environment

```
Ubuntu 20.04.1 LTS
Intel Xeon Processor (Skylake, IBRS), 8 cores
16GiB DIMM RAM
```


## Requirements

1. pip3
2. Scipy
3. Matplotlib
4. Jupyter lab
5. Julia (version 1.6)
6. IJulia

### Pip3 installation

jill (https://github.com/abelsiqueira/jill) is a light installer of Julia on Linux. To install jill, pip3 (https://pip.pypa.io/en/stable/) is required. 

**pip3 installation**

```
sudo apt-get install python3-pip
```

### Install Scipy

```
pip3 install scipy
```

### Install matplotlib

```
pip3 install matplotlib
```

### JupyterLab installation

The simulations are executed and displayed via JupyterLab. It is an IDE for literal programming. In this project, Julia kernel is used in Jupyterlab, and extra installation is needed to use Julia with Jupyterlab. 

```
pip3 install jupyterlab
```

See https://jupyterlab.readthedocs.io/en/stable/getting_started/installation.html for further instruction.

### Julia installation 

Julia can be installed by the official instruction (https://julialang.org/downloads/) or by following command line. 

```
pip3 install jill
jill install 1.6
```

jill can catch and install Julia 1.6 on Linux system. If the above command runs successfully, one may need to set Julia to PATH (more instruction can be found at https://julialang.org/downloads/platform/#linux_and_freebsd). This can be tested by the following command.

```
which julia
```

Expected output is `/home/ubuntu/.local/bin/julia`.


### IJulia 

IJulia (https://julialang.github.io/IJulia.jl/stable/manual/installation/) is a Julia package for kernel installation for Jupyter. 

The installation requires Julia Package manager (Pkg, https://docs.julialang.org/en/v1/stdlib/Pkg/), which is a built-in package in Julia. To install IJulia, one needs to open Julia REPL (Read–eval–print loop) using the following command line.

```
julia
```
![Julia REPL](https://user-images.githubusercontent.com/29009898/130343508-7d8e5e18-7ca8-46f8-b3de-3e4910c42ff3.png)

The Julia REPL begins in the terminal after submitting `julia` command. The next step is to install IJulia with package manager (Pkg). Copy-paste the following code block to Julia REPL

```julia
using Pkg
Pkg.add("IJulia")
Pkg.build("IJulia")
```
![IJulia installation with Pkg](https://user-images.githubusercontent.com/29009898/130343609-a997c935-a209-4364-8c5c-e2e62a3e42b0.png)

### Enabling multi-threaded kernel

Some notebooks use multithread algorithms to speed up. The multithread process can be set by IJulia in Julia REPL.

```
using IJulia
IJulia.installkernel("Julia 8 Threads", env=Dict(
    "JULIA_NUM_THREADS" => "8",
))
```

where `JULIA_NUM_THREADS` represents number of threads that can be used in the Julia process, and this can not be changed after a Julia process is initiated. Though the number of threads is set as `8`, it can be changed and usually depends on the hardware setup.


## Set up of simulation environments

Each Jupyter notebook (`.ipynb`) has its own package and Julia environmental setup under the folder with identical name. For instance, the source code and required package of `FrequencyResponse.ipynb` locate under the folder [FrequencyResponse](FrequencyResponse/). The purpose of separated simulation environment is to minimize version conflicts between packages in a complex environment. Therefore, the source code folder has the following structure: 

```
NotebookName.ipynb
NotebookName/
    img/
    result/
    src/
        NotebookName.jl
        ...
    test/
    Manifest.toml
    Project.toml
```

- `NotebookName.ipynb`: pipeline of simulation
- `src`: source code for simulation
- `NotebookName.jl`: The package name is the same as the name of the notebook.
- `test/`: contains Unit testing files
- `Project.toml` contains the required Julia package for the simulation in `NotebookName.ipynb`
- `Manifest.toml` is machine-generated record for Julia installation. This file provides detailed Julia versions which are used to generate the corresponding simulation. The record is to assure the reproducible result.


## Execute notebooks 

```
jupyter lab
```


Select the kernel with the name `Julia 8 Threads` to initiate Julia with multiple threads. After successfully initiation, one can see `Julia 8 Threads 1.6` located at the top right corner.

![Jupyter screen shot](https://user-images.githubusercontent.com/29009898/130344079-b98a76f1-13c5-4b8c-a195-dd6f45bd5527.png)


## Analysis of multiple solutions

10 out of 270+ solutions are plotted under the jupyter notebooks at [result/](PlottingMakie/result/). Noted that these notebooks are modified from [FrequencyResponse.ipynb](FrequencyResponse.ipynb) by [run_sol.jl](run_sol.jl). Some minor errors including save path errors can be ignored when viewing these files.
