function decomp()
    rng(1) % Reproducability

    %% Load data
    load("../data/EEM_NMR_LCMS.mat", 'X', 'Y', 'Z');
    
    X_structure = X;
    X = X_structure.data;
    X = tensor(X);

    Y_structure = Y;
    Y = Y_structure.data;
    Y = tensor(Y);

    Z_structure = Z;
    Z = Z_structure.data;
    Z = tensor(Z);


    %% Handle NaNs in X
    mask = ~isnan(double(X));
    P = tensor(double(mask));

    X_from_part1 = import_data('../data/best_model.tensor');
    missing_vals = P .* X_from_part1;

    Xd = double(X);
    Xd(isnan(Xd)) = 0;
    Xd = Xd + missing_vals;
    
    X = tensor(Xd);

    %% Add data to model object
    ZZ.object{1} = X;
    ZZ.object{2} = Y;
    ZZ.object{3} = Z;


    %% Metadata
    sz = {28,251,21,28,13324,8,28,168};
    modes  = {[1 2 3], [4 5 6],[7 8]};
    
    %% Tensor model
    model{1} = 'CP';
    model{2} = 'CP';
    model{3} = 'CP';

    %% Coupling
    coupling.lin_coupled_modes = [1 0 0 1 0 0 1 0]; % Mode 1, 4 and 7 are coupled
    coupling.coupling_type = 4; % 4: C=DeltaH
    coupling.coupl_trafo_matrices = cell(8,1);
    % Matrices described in report
    coupling.coupl_trafo_matrices{1} = [1, 0, 0; 0, 1, 0; 0, 0, 1; 0, 0, 0; 0,0,0; 0,0,0];
    coupling.coupl_trafo_matrices{4} = [1, 0, 0 0, 0; 0, 1, 0, 0,0; 0, 0, 1,0,0; 0, 0, 0,1,0; 0,0,0,0,1; 0,0,0,0,0];
    coupling.coupl_trafo_matrices{7} = [1, 0, 0 0, 0; 0, 1, 0, 0,0; 0, 0, 1,0,0; 0, 0, 0,1,0; 0,0,0,0,0; 0,0,0,0,1];

    %% Loss functions
    loss_function{1} = 'Frobenius';
    loss_function{2} = 'Frobenius';
    loss_function{3} = 'Frobenius';

    %% Initialization options
    distr_data = {@(x,y) rand(x,y), @(x,y) rand(x,y), @(x,y) rand(x,y),@(x,y) rand(x,y),@(x,y) rand(x,y),@(x,y) rand(x,y),@(x,y) rand(x,y),@(x,y) rand(x,y)}; % function handle of distribution of data within each factor matrix /or Delta if linearly coupled, x,y are the size inputs %coupled modes need to have same distribution! If not, just the first one will be considered
    lambdas_data = {[1 1 1], [1 1 1 1 1], [1 1 1 1 1]};

    init_options.lambdas_init = lambdas_data;
    init_options.nvecs = 0;
    init_options.distr = distr_data;
    init_options.normalize = 0;

    %% Constraints
    % All modes have non-negativity constraints
    constrained_modes = [1 1 1 1 1 1 1 1];

    constraints = cell(length(constrained_modes),1);
    constraints{1} = {'non-negativity'};
    constraints{2} = {'non-negativity'};
    constraints{3} = {'non-negativity'};
    constraints{4} = {'non-negativity'};
    constraints{5} = {'non-negativity'};
    constraints{6} = {'non-negativity'};
    constraints{7} = {'non-negativity'};
    constraints{8} = {'non-negativity'};

    %% Define model weights
    weights = [1/3 1/3 1/3];

    %% Define model object
    ZZ.loss_function = loss_function;
    ZZ.model = model;
    ZZ.modes = modes;
    ZZ.size  = sz;
    ZZ.coupling = coupling;
    ZZ.constrained_modes = constrained_modes;
    ZZ.constraints = constraints;
    ZZ.weights = weights;

    %% Options 
    options.Display ='no'; %  set to 'iter' or 'final' or 'no'
    options.DisplayIters = 10;
    options.MaxOuterIters = 10000;
    options.MaxInnerIters = 5;
    options.AbsFuncTol   = 1e-4;
    options.OuterRelTol = 1e-8;
    options.innerRelPrTol_coupl = 1e-3;
    options.innerRelPrTol_constr = 1e-3;
    options.innerRelDualTol_coupl = 1e-3;
    options.innerRelDualTol_constr = 1e-3;
    options.bsum = 0;

    %% Set run options
    runs = 30;

    min_loss = 1e+20;
    models = cell(1,runs);
    best_Zhat = {};
    losses = [];

    for i = 1:runs
        %% Create random initialization
        init_fac = init_coupled_AOADMM_CMTF(ZZ,'init_options', init_options);

        %% Run algorithm
        fprint("Run model %d", i);
        tic
        [Zhat,~,~,out] = cmtf_AOADMM(ZZ,'alg_options',options,'init',init_fac,'init_options',init_options); 
        toc

        %% Save relevant stats
        loss = out.f_tensors + out.f_couplings + out.f_constraints;
        if loss < min_loss
            min_loss = loss;
            best_Zhat = Zhat;
        end
        losses = [losses loss];
        models{i} = Zhat;
    end

    %% Get runs close to best run
    tol = 1.0005;
    close_model_indices = [];
    for i = 1:runs
        if losses(i) <= tol*min_loss
            close_model_indices = [close_model_indices i];
        end
    end

    %% Scores for "almost optimal" runs to check uniqueness
    for ii = 1:length(close_model_indices)
        i = close_model_indices(ii);
        rel_loss = losses(i) / min_loss;
        scores = [score(best_Zhat{1}, models{i}{1}) score(best_Zhat{2}, models{i}{2}) score(best_Zhat{3}, models{i}{3})];
        disp(rel_loss);
        disp(scores);
    end

    %% Plot factors of the best run
    plot_factors(best_Zhat{1}, "EEM Factors")
    plot_factors(best_Zhat{2}, "3-way NMR Factors")
    plot_factors(best_Zhat{3}, "LCMS Factors")
    