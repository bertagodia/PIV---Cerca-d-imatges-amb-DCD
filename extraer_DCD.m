% calc_table.m
User_root = 'C:\Users\tomas\Documents\UPC\3B\PIV\Prog1\DB\';
cd(User_root);

fprintf('--- SYSTEM 1 ---\n');
% Extraccio
t_ext1_list = zeros(10,1);
for k=1:10
    tic; 
    I = imread(sprintf('ukbench%05d.jpg', k-1));
    IBN = rgb2gray(I);
    H = imhist(IBN);
    H_Comparar = H/sum(H);
    t_ext1_list(k) = toc;
end
t_ext1 = mean(t_ext1_list);
fprintf('Temps extracció / imatge: %.4f s\n', t_ext1);

% F-score (we just use Algo3 on 50 images to estimate or calculate it)
% First, need HBaseDades (we can generate it fast for all 2000)
HBaseDades = zeros(2000, 256);
for i=1:2000
    I = imread(sprintf('ukbench%05d.jpg', i-1));
    HBaseDades(i,:) = imhist(rgb2gray(I))/sum(imhist(rgb2gray(I)));
end

Data_root = 'Test\';
Input_filename = 'input.txt';
Input = textread([User_root, Data_root, Input_filename],'%s');
Num_images = length(Input); 
Candidates = 10;
P_all = zeros(Num_images, Candidates);
R_all = zeros(Num_images, Candidates);

t_query1_list = zeros(Num_images,1);
for i = 1:Num_images
    nom_query = char(Input(i));
    I = imread(nom_query);
    H_Comparar = imhist(rgb2gray(I))/sum(imhist(rgb2gray(I)));
    
    tic;
    % Manhattan (Algo2_3 is usually best for hist)
    diffs = abs(HBaseDades' - H_Comparar);
    d = sum(diffs, 1);
    [~, idx] = sort(d);
    t_query1_list(i) = toc;
    
    query_id = sscanf(nom_query, 'ukbench%d.jpg');
    grup_real = floor(query_id / 4);
    TP_acum = 0;
    for j = 1:Candidates
        retrieved_id = idx(j) - 1; 
        grup_retrieved = floor(retrieved_id / 4);
        if grup_retrieved == grup_real
            TP_acum = TP_acum + 1;
        end
        P_all(i, j) = TP_acum / j;
        R_all(i, j) = TP_acum / 4;
    end
end
P_m = mean(P_all, 1); R_m = mean(R_all, 1);
F = 2*(P_m.*R_m)./(P_m+R_m); F(isnan(F))=0;
[maxF1, maxIdx1] = max(F);
fprintf('Temps cerca / query: %.4f s\n', mean(t_query1_list));
fprintf('Max F-score: %.4f\n', maxF1);

fprintf('\n--- SYSTEM 2 ---\n');
t_ext2_list = zeros(10,1);
for k=1:10
    tic; 
    I = imread(sprintf('ukbench%05d.jpg', k-1));
    I_pequena = imresize(I, 0.5);
    dcd = extraer_DCD(I_pequena);
    t_ext2_list(k) = toc;
end
t_ext2 = mean(t_ext2_list);
fprintf('Temps extracció / imatge: %.4f s\n', t_ext2);

load('BaseDatos_DCD_Final.mat', 'DB');
t_query2_list = zeros(Num_images,1);
for i = 1:Num_images
    nom_query = char(Input(i));
    ruta_query = fullfile(User_root, nom_query);
    tic;
    idx_recuperats = Algo3_DCD(ruta_query, DB, Candidates);
    t_query2_list(i) = toc;
end
fprintf('Temps cerca / query: %.4f s\n', mean(t_query2_list));
