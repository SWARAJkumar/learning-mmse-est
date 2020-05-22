# Learning the MMSE Channel Estimator

This code was used to generate the figures in the article

D. Neumann, T. Wiese, and W. Utschick, _Learning the MMSE Channel Estimator_, Accepted for publication in _IEEE Transactions on Signal Processing_, 2018.



## Installation Notes

1. Download Julia version 0.6.4 from https://julialang-s3.julialang.org/bin/linux/x64/0.6/julia-0.6.4-linux-x86_64.tar.gz	
(note- there has been substancial syntax changes to julia 1.0+, this repo will not work with julia 1.0+ or julia 0.7. However, if one need to migrate the code to latest julia version, one must fix all the depricated warning given by juila 0.7)	

 2. Unizip:  `tar -xvzf julia-0.6.4-linux-x86_64.tar.gz`    	

 Add to path: `export PATH="$PATH:/path/to/<Julia directory>/bin"` , give path to the bin folder in julia directory.	

 3. Installing packages- `Pkg.add("Packagename")`    	

 install the following packages: "CSV", "DataFrames", "Interpolations", "Distributions" .	

 4. Tensorflow.jl installation:     	
4.1 Frist check if python 3.5 is installed on the system and accessible to the directory. Install tensorflow version 1.4.1 on this using `pip3 install tensorflow==1.4.1` and donnot update this tensflow package.      	

 4.2 Now install tensorflow.jl which is a wrapper for tensorflow package for python. It uses pycall to call the tf functions. 	

 `Pkg.add("TensorFlow",v"0.8.0",v"0.9.0")`     	

 This is essential for installing TensorFlow.jl version 0.8.0, as it will install >=0.8.0 and <0.9.0, which is just equivalent to saying install version= 0.8.0. It is essential that one installs TensorFlow.jl version 0.8.0 as higher version will lead to to segmentation fault in this repository.	

 ### Other useful instructions:	
Can check the packages installed and their respective versions using: `Pkg.status()`	
removing package:  `Pkg.rm("package name")`	
for more information of tensorflow.jl refer: https://github.com/malmaud/TensorFlow.jl	

 ## Uninstalling 	
Julia installation and all dependencies are there in the julia directory itself, so for removing julia from the system just do `rm -rf <julia directory>`     	

 Now remove the folder containg this repo from the system 	




