% test_baseline.m
User_root = 'C:\Users\tomas\Documents\UPC\3B\PIV\Prog1\DB\';
Data_root = 'Test\';
Input_filename = 'input.txt';

% Load DB
load('BaseDatos_DCD_Final.mat', 'DB');

Input = textread([User_root, Data_root, Input_filename],'%s');
Num_images = length(Input);
Candidates = 10;
Num_rellevants_total = 4;
TP_all = 0;
Total_queries = 0;

P_all = zeros(Num_images, Candidates);
R_all = zeros(Num_images, Candidates);

for i = 1:Num_images
    nom_query = char(Input(i));
    ruta_query = fullfile(User_root, nom_query);
    
    % Algo3_DCD modifies dist to find nearest
    idx_recuperats = Algo3_DCD(ruta_query, DB, Candidates);
    
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
        R_all(i, j) = TP_acumulats / Num_rellevants_total;
    end
end

P_mitjana = squeeze(mean(P_all, 1));
R_mitjana = squeeze(mean(R_all, 1));

% Calculate F-score for all ranks
F_scores = 2 * (P_mitjana .* R_mitjana) ./ (P_mitjana + R_mitjana);
F_scores(isnan(F_scores)) = 0; % Handle 0/0
[max_F, max_idx] = max(F_scores);

fprintf('Baseline Precision@10: %.4f\n', P_mitjana(10));
fprintf('Baseline Recall@10: %.4f\n', R_mitjana(10));
fprintf('Max Baseline F-score: %.4f at Rank %d\n', max_F, max_idx);
