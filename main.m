function DCD = extraer_DCD_noPGA(I)
    numColors = 8;
    maxDistorsion = 1;
    
    % Convertir a Lab (rang correcte: L* 0-100, a* +/-100, b* +/-100)
    ILAB = double(rgb2lab(I));
    
    [filas, cols, ~] = size(ILAB);
    num_pixels = filas * cols;
    X = reshape(ILAB, num_pixels, 3);
    
    % SENSE PGA: Tots els pixels tenen el mateix pes
    h = ones(num_pixels, 1) / num_pixels;
    
    X_h = X .* h;

    centroides = sum(X_h, 1) / sum(h);

    while size(centroides, 1) < numColors
        K = size(centroides, 1);
        distancias = pdist2(X, centroides, "squaredeuclidean");
        [~, etiquetas] = min(distancias, [], 2);

        D = zeros(K, 1);
        for i = 1:K
            idx = (etiquetas == i);
            if any(idx)
                D(i) = sum(h(idx) .* distancias(idx, i));
            end
        end

        if max(D) < maxDistorsion
            break;
        end

        [~, idx_max_D] = max(D);
        c_target = centroides(idx_max_D, :);
        perturbacion = [1, 1, 1] * 5;
        c_new1 = c_target + perturbacion;
        c_new2 = c_target - perturbacion;
        centroides(idx_max_D, :) = c_new1;
        centroides = [centroides; c_new2];
        
        for iter = 1:10
            dist_temp = pdist2(X, centroides, "squaredeuclidean");
            [~, etiq_temp] = min(dist_temp, [], 2);
            for j = 1:size(centroides, 1)
                idx = (etiq_temp == j);
                if any(idx)
                    centroides(j, :) = sum(X(idx, :) .* h(idx), 1) / sum(h(idx));
                end
            end
        end
    end

    distancias = pdist2(X, centroides, "squaredeuclidean");
    [~, etiquetas] = min(distancias, [], 2);

    K_final = size(centroides, 1);
    porcentajes = zeros(K_final, 1);
    varianzas = zeros(K_final, 3);

    for i = 1:K_final
        idx = (etiquetas == i);
        porcentajes(i) = sum(idx) / num_pixels;
        if any(idx)
            varianzas(i, :) = var(X(idx, :), 1);
        end
    end

    [porcentajes, orden] = sort(porcentajes, 'descend');
    centroides = centroides(orden, :);
    varianzas = varianzas(orden, :);

    DCD.num_colors = K_final;
    DCD.centroides = centroides;
    DCD.porcentajes = porcentajes;
    DCD.varianzas = varianzas;
end
