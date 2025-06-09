function find_rank()
% Finding rank of 
    rng(1) % Reproducability

    %% Load data
    load("/home/gautejohannessen/Documents/SpesPensum/Specialized-Syllabus-Project/data/EEM_NMR_LCMS.mat", 'X');
    X_structure = X;
    X = X_structure.data;
    X = tensor(X);

    %% Create weights
    mask = ~isnan(double(X));
    P = tensor(double(mask));

    rel_f_list = [];
    relfits_list = [];

    %% Run model for ranks 1 to 5
    for r = 1:5
        best_rel_f = 1e20;
        best_relift = 0;
        
        % Fit 20 times each rank and keep the best model
        for i = 1:20
            M_init = create_guess('Data', X, 'Num_Factors', r);

            [M,~,info] = cp_wopt(X, P, r, 'init', M_init, 'lower', 0);
            
            if info.f < best_rel_f
                best_rel_f = info.f;
                best_relift = relfit(X, M); 
            end
        end
        if r==1
            first_f = best_rel_f;
        end

        rel_f = best_rel_f/first_f;
        relfits = best_relift;

        rel_f_list = [rel_f_list; rel_f];
        relfits_list = [relfits_list; relfits];
    end

    %% Save results to file
    R = [1; 2; 3; 4; 5];
    Loss = rel_f_list;
    RelFit = relfits_list;
    T = table(R, Loss, RelFit);
    writetable(T, "../data/rank_results.txt");
    type ../data/rank_results.txt;
end
