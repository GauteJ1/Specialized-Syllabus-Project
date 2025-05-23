function plot_factors(data)
    s = size(data);
    dims = s(1);

    colors = [1 0 0; 0 0 1; 0 1 0; 0.8 0.8 0; 0.8 0 0.8];

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
        if dim == 2
            title('Emission Mode');
            xlabel('Emission Wavelength');
        end
        if dim == 3
            title('Excitation Mode');
            xlabel('Excitation Wavelength');
        end
    end

    % Adjust layout
    sgtitle("$R = " + string(rank) + "$", 'Interpreter', 'latex');

    filename = "../figures/factors_rank" + string(rank);
    print(filename, '-dpdf');
end