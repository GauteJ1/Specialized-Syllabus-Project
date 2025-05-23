function find_rank()
    rng(1) % Reproducability

    % Load data
    load("/home/gautejohannessen/Documents/SpesPensum/Specialized-Syllabus-Project/data/EEM_NMR_LCMS.mat", 'X');
    X_structure = X;
    X = X_structure.data;
    X = tensor(X);

    % Create weights
    mask = ~isnan(double(X));
    P = tensor(double(mask));

    rel_f_list = [];
    relfits_list = [];

    for r = 1:5
        best_rel_f = 1e20;
        best_relift = 0;

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

        rel_f_list(end + 1) = rel_f;
        relfits_list(end + 1) = relfits;
    end

    for r = 1:5
        disp(r);
        disp(rel_f_list(r));
        disp(relfits_list(r));
    end
end
