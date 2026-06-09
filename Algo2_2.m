function d = Algo2_1(HQuery, HBaseDades)
    % HQuery: vector columna de l'histograma query (ex: 256 x 1)
    % HBaseDades: matriu amb tota la base de dades (ex: 256 x 2000)
    
    % 1. Numerador: La diferència al quadrat
    numerador = (HBaseDades - HQuery).^2;
    
    % 2. Denominador: La suma de les freqüències
    denominador = HBaseDades + HQuery + eps;
    
    % 3. Càlcul final: Dividim element a element (./) i sumem les columnes
    d = 0.5 * sum(numerador ./ denominador);

end