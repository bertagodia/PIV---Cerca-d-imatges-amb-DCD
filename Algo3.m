function d = Algo2_3(HQuery, HBaseDades)
    % HQuery: vector columna (N x 1)
    % HBaseDades: matriu (N x 2000)
    
    d = sum(abs(HBaseDades - HQuery), 1);
end