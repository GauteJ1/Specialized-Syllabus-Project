### Packages:

Tensor Toolbox v3.6 - https://www.tensortoolbox.org/

Poblano Toolbox: v1.2 - https://github.com/sandialabs/poblano_toolbox

AOADMM-DataFusionFramework: Newest release - https://github.com/AOADMM-DataFusionFramework/Matlab-Code

The Proximity Operator Repository: Newest release - https://proximity-operator.net/index.html

L-BFGS-B-C: Newest release - https://github.com/stephenbeckr/L-BFGS-B-C

### Running the programs:

There are three main programs to be run:

``` code_part1/find_rank ```
fits 20 models for each rank 1 to 5 and prints the RelFit and Loss values for the best model of each rank.
The printed data is also saved to ```data/rank_results.txt```

To fit the CP model in part 1 and plot the discovered factors, one needs to run the program
``` code_part1/run_model(rank) ```
This program takes a single integer as input: the rank to use for the model. It saves the plots in the figures folder.
It also prints relative loss and FMS scores for models with loss less than 1.02 times that of the best model.
If ran with rank=3, it will also save the best model to be used for part 2.

For part 2, there is a single program:
``` code_part2/decomp ```
It takes no input arguments. It handles the missing data in X, as discussed in the assignment, fits a CMTF model to the data, and plots the factors of the best model over 30 runs.
It also prints the FMS scores of models with loss within 1.005 times that of the loss of the best model.
