#
# Run this file to generate Figure 7 in
#
#   D. Neumann, T. Wiese, and W. Utschick, Learning the MMSE Channel Estimator,
#   IEEE Transactions on Signal Processing, 2018.
#
# (It may be necessary to split the loop over the different SNR values into
# several smaller loops as the TensorFlow graph is not reset after each
# loop and memory usage may build up.)
#
push!(LOAD_PATH,".")
using DataFrames
using CSV
import SCM3GPP; const scm = SCM3GPP
import CondNormalMMSE; const mmse = CondNormalMMSE
import CondNormalTF; const cntf = CondNormalTF

include("sim_helpers.jl")
include("more_estimators.jl") # OMP and Genie MMSE

verbose = true
#-------------------------------------
# Simulation parameters
#
write_file = true
filename   = "results/figure7.csv"
nBatches   = 100
nBatchSize = 100

#-------------------------------------
# Channel Model
#
snrs       = 15 #-15:5:15 # [dB]
nAntennas  = 64
AS         = 2.0 # standard deviation of Laplacian (angular spread)
nCoherence = 1
Channel    = scm.SCMMulti(pathAS=AS, nPaths=3)
# method that generates "nBatches" channel realizations
get_channel(nAntennas, nCoherence, nBatches) = scm.generate_channel(Channel, nAntennas, nCoherence=nCoherence, nBatches = nBatches)
# method that samples C_delta from delta prior
get_cov(nAntennas) = scm.toeplitzHe( scm.generate_channel(Channel, nAntennas, nCoherence=1)[2][:] )
# get circulant vector that generates all covariance matrices for arbitrary delta (here: use delta=0)
get_circ_cov_generator(nAntennas) = real(scm.best_circulant_approximation(scm.scm_channel([0.0],[1.0],nAntennas,AS=AS)[2]))

#-------------------------------------
# Learning Algorithm parameters
#
nLayers = 2
nLearningBatchSize = 20
nLearningBatches   = 6000

init_params = Dict{Symbol,Any}()

init_params[:nAntennas]   = [   8;  16;  32;  64]
init_params[:nBatches]    = [1000;1000;1000]
init_params[:nBatchSize]  = [  20;  20;  20]
init_params[:get_channel] = (nAntennas,nBatches) -> get_channel(nAntennas, nCoherence, nBatches)

init_params[:learning_rates] = Dict{Symbol,Vector{Float64}}()
init_params[:learning_rates][:ToepReLU] = 1e-5*64./init_params[:nAntennas]
init_params[:learning_rates][:CircReLU] = 1e-5*64./init_params[:nAntennas]
init_params[:learning_rates][:ToepSoftmax] = 1e-3*ones(init_params[:nAntennas])
init_params[:learning_rates][:CircSoftmax] = 1e-3*ones(init_params[:nAntennas])
init_params[:learning_rates][:ToepSoftplus] = 1e-3*ones(init_params[:nAntennas])
init_params[:learning_rates][:CircSoftplus] = 1e-3*ones(init_params[:nAntennas])
init_params[:learning_rates][:Toepswish] = 1e-4*64./init_params[:nAntennas]
init_params[:learning_rates][:Circswish] = 1e-4*64./init_params[:nAntennas]


results = DataFrame()
# read results from previous run
if isfile(filename)
    results = CSV.read(filename)
end

srand(size(results,1)) # use number of entries in results as seed for random number generator
for iSNR in 1:length(snrs)
    snr = snrs[iSNR]
    init_params[:snrs] = snr*ones(length(init_params[:nBatches]))

    verbose && println("Simulating with ", snr, " [dB] SNR")

    # Conditionally normal estimators
    cn_est = Dict{Symbol,Any}()
    cn_est[:FastMMSE] = mmse.FastMMSE(snr, get_circ_cov_generator(nAntennas))
    cn_est[:CircMMSE] = mmse.StructuredMMSE(snr, () -> get_cov(nAntennas), nSamples=16*nAntennas, transform = circ_trans)
    cn_est[:ToepMMSE] = mmse.StructuredMMSE(snr, () -> get_cov(nAntennas), nSamples=16*nAntennas, transform = toep_trans)
    cn_est[:CircML]   = mmse.MLEst(snr, transform = circ_trans)

    # Neural network estimators
    nn_est = Dict{Symbol,Any}()

    nn_est[:Circswish] = cntf.ConvNN(nLayers, init_params[:nAntennas][1], 
    									transform = circ_trans, 
    									learning_rate = init_params[:learning_rates][:Circswish][1],
   										activation = cntf.swish)
    nn_est[:Toepswish] = cntf.ConvNN(nLayers, init_params[:nAntennas][1], 
    									transform = toep_trans, 
    									learning_rate = init_params[:learning_rates][:Toepswish][1],
    								    activation = cntf.swish)


    nn_est[:CircSoftplus] = cntf.ConvNN(nLayers, init_params[:nAntennas][1],
    								 	transform = circ_trans, learning_rate = init_params[:learning_rates][:CircSoftplus][1],
    									activation = cntf.nn.softplus)
    nn_est[:ToepSoftplus] = cntf.ConvNN(nLayers, init_params[:nAntennas][1], 
    									transform = toep_trans, learning_rate = init_params[:learning_rates][:ToepSoftplus][1],
     								   	activation = cntf.nn.softplus)

    nn_est[:ToepReLU]    = cntf.ConvNN(nLayers, init_params[:nAntennas][1],
                                       transform = toep_trans,
                                       learning_rate = init_params[:learning_rates][:ToepReLU][1])
    nn_est[:CircReLU]    = cntf.ConvNN(nLayers, init_params[:nAntennas][1],
                                       transform = circ_trans,
                                       learning_rate = init_params[:learning_rates][:CircReLU][1])
    nn_est[:ToepSoftmax] = cntf.ConvNN(nLayers, init_params[:nAntennas][1],
                                       transform = toep_trans,
                                       learning_rate = init_params[:learning_rates][:ToepSoftmax][1],
                                       activation = cntf.nn.softmax)
    nn_est[:CircSoftmax] = cntf.ConvNN(nLayers, init_params[:nAntennas][1],
                                       transform = circ_trans,
                                       learning_rate = init_params[:learning_rates][:CircSoftmax][1],
                                       activation = cntf.nn.softmax)

    init_hier!(nn_est, init_params, verbose = verbose)
    train!(nn_est, snr = snr, nBatches = nLearningBatches, get_channel = () -> get_channel(nAntennas, nCoherence, nLearningBatchSize), verbose = verbose)
    
    algs = Dict{Symbol,Any}()
    algs[:GenieMMSE] = (y,h,h_cov) -> mmse_genie(y, h_cov, snr)
    algs[:GenieOMP]  = (y,h,h_cov) -> omp_genie(y, h)
    for (alg,cn) in cn_est
        algs[alg] = (y,h,h_cov) -> mmse.estimate(cn, y)
    end    
    for (alg,nn) in nn_est
        algs[alg] = (y,h,h_cov) -> cntf.estimate(nn, y)
    end

    (errs,rates) = evaluate(algs, snr = snr, nBatches = nBatches, get_channel = () -> get_channel(nAntennas, nCoherence, nBatchSize), verbose = verbose)

    for alg in keys(algs)
        new_row = DataFrame(MSE        = errs[alg],
                            rate       = rates[alg],
                            Algorithm  = String(alg),
                            SNR        = snr, 
                            nAntennas  = nAntennas,
                            nCoherence = nCoherence)

        if isempty(results)
            results = new_row
        else
            results = vcat(results,new_row)
        end
    end

    if write_file
        CSV.write(filename, results)
    end
    @show results
end
