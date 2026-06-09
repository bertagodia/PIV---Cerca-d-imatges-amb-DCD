% run_variants3.m
User_root = 'C:\Users\tomas\Documents\UPC\3B\PIV\Prog1\DB\';
cd(User_root);
load('BaseDatos_DCD_Final.mat', 'DB');
Data_root = 'Test\';
Input_filename = 'input.txt';
Input = textread([User_root, Data_root, Input_filename],'%s');
Num_images = length(Input); 
Candidates = 10;
qf_base = @(img) extraer_DCD(imresize(imread(img), 0.5));
dist_base = @(Q, DB) Algo2_DCD(Q, DB, 20);

function dists = dist_manhattan_pesos(Q, DB)
    num_imgs = length(DB);
    dists = zeros(1, num_imgs);
    Pq = zeros(8,1);
    pq_len = length(Q.porcentajes);
    Pq(1:pq_len) = reshape(Q.porcentajes, pq_len, 1);
    for idx = 1:num_imgs
        Pd = zeros(8,1);
        pd_len = length(DB{idx}.porcentajes);
        Pd(1:pd_len) = reshape(DB{idx}.porcentajes, pd_len, 1);
        dists(idx) = sum(abs(Pq(:) - Pd(:)));
    end
end

function [F_max, t_query] = eval_variant(DB_test, query_func, dist_func, Input, Num_images, Candidates, User_root)
    P_all = zeros(Num_images, Candidates);
    R_all = zeros(Num_images, Candidates);
    t_query_list = zeros(Num_images, 1);
    for i = 1:Num_images
        nom_query = char(Input(i));
        ruta_query = fullfile(User_root, nom_query);
        tic;
        Q = query_func(ruta_query);
        dists = dist_func(Q, DB_test);
        [~, idx_ordenats] = sort(dists, 'ascend');
        idx_recuperats = idx_ordenats(1:Candidates);
        t_query_list(i) = toc;
        query_id = sscanf(nom_query, 'ukbench%d.jpg');
        grup_real = floor(query_id / 4);
        TP_acumulats = 0;
        for j = 1:Candidates
            retrieved_id = idx_recuperats(j) - 1; 
            grup_retrieved = floor(retrieved_id / 4);
            if grup_retrieved == grup_real
                TP_acumulats = TP_acumulats + 1;
            end
            P_all(i, j) = TP_acumulats / j;
            R_all(i, j) = TP_acumulats / 4;
        end
    end
    P_mitjana = squeeze(mean(P_all(:, :), 1));
    R_mitjana = squeeze(mean(R_all(:, :), 1));
    F_scores = 2 * (P_mitjana .* R_mitjana) ./ (P_mitjana + R_mitjana);
    F_scores(isnan(F_scores)) = 0;
    F_max = max(F_scores);
    t_query = mean(t_query_list);
end

% 3. Manhattan sobre pesos
fprintf('--- V3: DCD-Manhattan ---\n');
dist_manh = @(Q, DB) dist_manhattan_pesos(Q, DB);
[F3, t3] = eval_variant(DB, qf_base, dist_manh, Input, Num_images, Candidates, User_root);
fprintf('F-score: %.4f | Temps query: %.4f s\n', F3, t3);

% 5. T_d = 10
fprintf('--- V5: DCD T_d=10 ---\n');
dist_td10 = @(Q, DB) Algo2_DCD(Q, DB, 10);
[F5, t5] = eval_variant(DB, qf_base, dist_td10, Input, Num_images, Candidates, User_root);
fprintf('F-score: %.4f | Temps query: %.4f s\n', F5, t5);

% 4. Sense PGA
fprintf('--- V4: DCD sens PGA ---\n');
DB_nopga = cell(200, 1); % Just run on 200 DB to estimate! Wait, I need to test on the same DB to get true F-score.
% Let's do all 2000, it takes 3 minutes.
DB_nopga = cell(2000, 1);
for i = 1:2000
    nom_img = sprintf('%s%05d%s', 'ukbench', i-1, '.jpg');
    I = imread(nom_img);
    DB_nopga{i,1} = extraer_DCD_noPGA(imresize(I, 0.5));
end
qf_nopga = @(img) extraer_DCD_noPGA(imresize(imread(img), 0.5));
[F4, t4] = eval_variant(DB_nopga, qf_nopga, dist_base, Input, Num_images, Candidates, User_root);
fprintf('F-score: %.4f | Temps query: %.4f s\n', F4, t4);
