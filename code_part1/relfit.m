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