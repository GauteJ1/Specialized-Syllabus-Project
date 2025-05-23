function run_model(rank)
    rng(1); % Reproducibility

    r = rank; % Discovered in find_rank.m

    % Load data
    load("/home/gautejohannessen/Documents/SpesPensum/Specialized-Syllabus-Project/data/EEM_NMR_LCMS.mat", 'X');
    X_structure = X;
    X = X_structure.data;
    X = tensor(X);

    % Create weights
    mask = ~isnan(double(X));
    P = tensor(double(mask));

    models = cell(1,20);
    losses = [];
    best_loss = 1e20;
    best_index = 0;

    for i = 1:20
        M_init = create_guess('Data', X, 'Num_Factors', r);

        [M,~,info] = cp_wopt(X, P, r, 'init', M_init, 'lower', 0);
        
        if info.f < best_loss
            best_loss = info.f;
            best_index = i;
        end

        models{i} = M;
        losses = [losses info.f];
    end

    tol = 1.05;

    % disp(best_index);
    % disp(best_loss);
    % disp(losses);

    close_model_indices = [];

    for i = 1:20
        if losses(i) <= tol*best_loss
            close_model_indices = [close_model_indices i];
        end
    end

    for ii = 1:length(close_model_indices)
        i = close_model_indices(ii);

        disp(score(models{best_index}, models{i}));
    end

    best_model = models{best_index};

    plot_factors(best_model.U);
