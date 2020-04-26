# Learning the MMSE Channel Estimator

This code was used to generate the figures in the article

D. Neumann, T. Wiese, and W. Utschick, _Learning the MMSE Channel Estimator_, Accepted for publication in _IEEE Transactions on Signal Processing_, 2018.

## Abstract
We present a method for estimating Gaussian random vectors with random covariance matrices, which uses techniques from the field of machine learning.
Such models are typical in communication systems, where the covariance matrix of the channel vector depends on random parameters, e.g., angles of propagation paths.
If the covariance matrices exhibit certain Toeplitz and shift-invariance structures, the complexity of the MMSE channel estimator can be reduced to _O(M_ log _M)_ floating point operations, where _M_ is the channel dimension.
While in the absence of structure the complexity is much higher, we obtain a similarly efficient (but suboptimal) estimator by using the MMSE estimator of the structured model as a blueprint for the architecture of a neural network.
This network learns the MMSE estimator for the unstructured model, but only within the given class of estimators that contains the MMSE estimator for the structured model.
Numerical simulations with typical spatial channel models demonstrate the generalization properties of the chosen class of estimators to realistic channel models.


## Installation Notes

Steps for installation on Linux:
1. Download Julia version 0.6.4 from https://julialang-s3.julialang.org/bin/linux/x64/0.6/julia-0.6.4-linux-x86_64.tar.gz
(note- there has been substancial syntax changes to julia 1.0+, this repo will not work with julia 1.0+ or julia 0.7. However, if one need to migrate the code to latest julia version, one must fix all the depricated warning given by juila 0.7)

2. Unizip:  `tar -xvzf julia-0.6.4-linux-x86_64.tar.gz`    

Add to path: `export PATH="$PATH:/path/to/<Julia directory>/bin"` , give path to the bin folder in julia directory.

3. Installing packages- `Pkg.add("Packagename")`    

install the following packages: "CSV", "DataFrames", "Interpolations", "Distributions" .

4. Tensorflow.jl installation:  
4.1 Frist check if python 3.5 is installed on the system and accessible to the directory. Install tensorflow version 1.4.1 on this using `pip3 install tensorflow==1.4.1` and donnot update this tensflow package

4.2 Now install tensorflow.jl which is a wrapper for tensorflow 

`Pkg.add("TensorFlow",v"0.8.0",v"0.9.0")`     

This is essential for installing TensorFlow.jl version 0.8.0, as it will install >=0.8.0 and <0.9.0, which is just equivalent to saying install version= 0.8.0. It is essential that one installs TensorFlow.jl version 0.8.0 as higher version will lead to to segmentation fault in this repository.

### Other useful instructions:
Can check the packages installed and their respective versions using: `Pkg.status()`
removing package:  `Pkg.rm("package name")`
for more information of tensorflow.jl refer: https://github.com/malmaud/TensorFlow.jl

## Uninstalling 
Julia installation and all dependencies are there in the julia directory itself, so for removing julia from the system just do rm -rf <julia directory>

Now remove the folder containg this repo from the system 


## License
This code is licensed under 3-clause BSD License:

>Copyright (c) 2018 D. Neumann and T. Wiese
>
>Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
>
>1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
>
>2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
>
>3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
>
>THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
