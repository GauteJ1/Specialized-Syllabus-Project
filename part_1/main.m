function main()
    rng(1) % Reproducability

    real_data();

end

function real_data()
    load("/home/gautejohannessen/Documents/SpesPensum/Specialized-Syllabus-Project/data/EEM_NMR_LCMS.mat", 'X');
    X_structure = X;
    X = X_structure.data;
    X = tensor(X);

    % Min-max normalization
    % X_array = double(X);
    % X_min = min(X_array(:));
    % X_max = max(X_array(:));
    % X_normalized = (X_array - X_min) / (X_max - X_min);
    % X = tensor(X_normalized);

    mask = ~isnan(double(X));
    P = tensor(double(mask));


    % r = 3;
    rel_f_list = [];
    relfits_list = [];


    for r = 1:5
        best_rel_f = 1e20;
        best_relift = 0;

        for i = 1:20
            M_init = create_guess('Data', X, 'Num_Factors', r);%, 'Factor_Generator', 'nvecs');

            [M,M0,info] = cp_wopt(X, P, r, 'init', M_init, 'lower', 0);

            % disp(info.ExitMsg);
            
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

function output = relfit(X, M)
    X_array = double(X);
    X_array(isnan(X_array)) = 0;
    X = tensor(X_array);

    numer = (X-M).*(X-M);
    denom = X.*X;

    numer = double(numer);
    denom = double(denom);

    output = 100*(1-(sum(numer(:))./sum(denom(:))));
end
