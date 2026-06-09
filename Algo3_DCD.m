function dists = Algo2_DCD(query, DB, T_d, alpha)
    % query: estructura amb .centroides (Kx3) i .porcentajes (Kx1)
    % DB: cell array d'estructures amb .centroides i .porcentajes
    % T_d: llindar de proximitat entre colors (default: 20)
    % alpha: factor per d_max, rang 1.0-1.5 (default: 1.2)
    
    if nargin < 3 || isempty(T_d), T_d = 20; end
    if nargin < 4 || isempty(alpha), alpha = 1.2; end
    
    d_max = alpha * T_d;
    
    % Pesos per canals L*, a*, b*: L* menys important (il·luminacio)
    W = diag([0.3, 1.0, 1.0]);
    
    num_imgs = length(DB);
    dists = zeros(1, num_imgs);
    
    % Query data
    Cq = query.centroides;
    Pq = query.porcentajes;
    
    % Transformar centroides query amb pesos
    Cq_w = Cq * W;
    
    % Matriu de similitud interna de la Query (Full QFD)
    dist_qq = pdist2(Cq_w, Cq_w, 'euclidean');
    A_qq = max(0, 1 - dist_qq / d_max);
    A_qq(dist_qq > T_d) = 0;
    terme1 = sum(sum(A_qq .* (Pq * Pq.')));
    
    for idx = 1:num_imgs
        db = DB{idx};
        Cd = db.centroides;
        Pd = db.porcentajes;
        
        % Transformar centroides DB amb pesos
        Cd_w = Cd * W;
        
        % Matriu de similitud interna de la Imatge DB (Full QFD)
        dist_dd = pdist2(Cd_w, Cd_w, 'euclidean');
        A_dd = max(0, 1 - dist_dd / d_max);
        A_dd(dist_dd > T_d) = 0;
        terme2 = sum(sum(A_dd .* (Pd * Pd.')));
        
        % Distancies ponderades i similitud creuada
        dist_mat = pdist2(Cq_w, Cd_w, 'euclidean');
        
        % Matriu de similitud a_ij
        A = max(0, 1 - dist_mat / d_max);
        A(dist_mat > T_d) = 0;
        
        % Terme d'interaccio vectoritzat
        interaccio = 2 * sum(sum(A .* (Pq * Pd.')));
        
        dists(idx) = sqrt(abs(terme1 + terme2 - interaccio));
    end
end
