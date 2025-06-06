function plot_factors(data, plot_name)
    s = size(data);
    dims = length(s);

    colors = [1 0 0; 0 0 1; 0 1 0; 0.8 0.8 0; 0.8 0 0.8; 0 0.8 0.8; 0 0 0];

    % Create a figure
    figure;

    for dim = 1:dims
        matrix = data{dim};
        s = size(matrix);
        n = s(1);
        rank = s(2);

        subplot(3, 1, dim);

        hold on;
        for r = 1:rank
            plot(1:n, matrix(:,r), "Color", colors(r,:), 'LineWidth', 2);
        end
        hold off;

        if dim == 1
            title('Mixtures Mode');
            xlabel('Sample ID');
        end
        if dim == 2 && plot_name == "EEM Factors"
            title('Emission Mode');
            xlabel('Emission Wavelength');
        end
        if dim == 2 && plot_name == "3-way NMR Factors"
            title('Chemical Shift Mode');
            xlabel('Chemical Shifts');
        end
        if dim == 2 && plot_name == "LCMS Factors"
            title('Feature Mode');
            xlabel('Features');
        end
        if dim == 3 && plot_name == "EEM Factors"
            title('Excitation Mode');
            xlabel('Excitation Wavelength');
        end
        if dim == 3 && plot_name == "3-way NMR Factors"
            title('Gradient Level Mode');
            xlabel('Gradient Levels');
        end
    end

    % Adjust layout
    sgtitle(plot_name);

    filename = "../figures/factors_" + plot_name;
    print(filename, '-dpdf');
end