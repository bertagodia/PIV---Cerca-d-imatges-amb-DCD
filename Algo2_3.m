function d = Algo2_2(HQuery, HBaseDades)
    % Calculem el coeficient de Bhattacharyya (suma de les arrels del producte)
    BC = sum(sqrt(HBaseDades .* HQuery), 1);
    
    % Ho convertim a distància real
    d = sqrt(1 - BC);
end