function run_model(rank)
    rng(1); % Reproducibility

    r = rank; % Discovered in find_rank.m

    %% Load data
    load("/home/gautejohannessen/Documents/SpesPensum/Specialized-Syllabus-Project/data/EEM_NMR_LCMS.mat", 'X');
    X_structure = X;
    X = X_structure.data;
    X = tensor(X);


    %% Create weights
    mask = ~isnan(double(X));
    P = tensor(double(mask));

    models = cell(1,20);
    losses = [];
    best_loss = 1e20;
    best_index = 0;

    %% Fit 20 models
    for i = 1:20
        M_init = create_guess('Data', X, 'Num_Factors', r, 'Factor_Generator', 'rand');

        [M,~,info] = cp_wopt(X, P, r, 'init', M_init, 'lower', 0);
        
        if info.f < best_loss
            best_loss = info.f;
            best_index = i;
        end

        models{i} = M;
        losses = [losses info.f];
    end

    %% Keep models with loss less than 2% more than best model
    tol = 1.02;
    close_model_indices = [];

    for i = 1:20
        if losses(i) <= tol*best_loss
            close_model_indices = [close_model_indices i];
        end
    end

    %% Print scores of close to optimal models
    disp("Match scores for almost equal models");
    for ii = 1:length(close_model_indices)
        i = close_model_indices(ii);
        
        disp(score(models{best_index}, models{i}));
    end

    %% Plot factors for best model
    best_model = models{best_index};
    plot_factors(best_model.U);

    %% Save model when rank is 3 for part 2
    if rank == 3
        export_data(tensor(best_model), '../data/best_model.tensor');
    end
