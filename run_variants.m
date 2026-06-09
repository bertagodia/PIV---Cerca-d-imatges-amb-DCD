%% Inicialització de la base de dades
DB = Algo1_DCD();

%% Guardem/Carreguem la DB
save('BaseDatos_DCD_Final1.mat', 'DB', '-v7.3');
%load('BaseDatos_DCD_Final.mat');

%% Avaluació del sistema: Precision-Recall (DCD)

% Rutes (Modifica segons el teu ordinador)
User_root      = 'C:\Users\tomas\Documents\UPC\3B\PIV\Prog1\DB\';
Data_root      = 'Test\';
Input_filename = 'input.txt';
Output_filename= 'output_DCD.txt';
Candidates     = 10; 

% Llegir queries
Input = textread([User_root, Data_root, Input_filename],'%s');
Num_images = length(Input); 

% Matrius per emmagatzemar P i R per a cada imatge i rang
P_all = zeros(Num_images, Candidates);
R_all = zeros(Num_images, Candidates);
Num_rellevants_total = 4;

% Obrir fitxer de sortida
a = fopen([User_root, Data_root, Output_filename],'w'); 

for i = 1:Num_images
    nom_query = char(Input(i));
    
    % Obtenir imatges recuperades
    ruta_query = fullfile(User_root, nom_query); % Assegura't que aquesta ruta apunta on toca
    
    % CRIDA AL NOU ALGO3 DCD
    idx_recuperats = Algo3_DCD(ruta_query, DB, Candidates);
    
    % Escriure resultats a l'arxiu de sortida
    fprintf(a, 'Retrieved list for query image %s \n', nom_query);
    for j = 1:Candidates
        retrieved_id_txt = idx_recuperats(j) - 1; 
        fprintf(a, '%s\n', sprintf('ukbench%05d.jpg', retrieved_id_txt));
    end
    fprintf(a, '\n');
    
    % Calcular Precision i Recall per aquesta query
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
    
    fprintf('Query %d de %d avaluada.\n', i, Num_images);
end
fclose(a);

% --- Calculate and Print F-score ---
P_mitjana = squeeze(mean(P_all(:, :), 1));
R_mitjana = squeeze(mean(R_all(:, :), 1));
F_scores = 2 * (P_mitjana .* R_mitjana) ./ (P_mitjana + R_mitjana);
F_scores(isnan(F_scores)) = 0; % Handle 0/0
[max_F, max_idx] = max(F_scores);

fprintf('======================================\n');
fprintf('DCD Retrieval Evaluation Results\n');
fprintf('Precision@10: %.4f\n', P_mitjana(10));
fprintf('Recall@10: %.4f\n', R_mitjana(10));
fprintf('Max F-score: %.4f at Rank %d\n', max_F, max_idx);
fprintf('======================================\n');

%% Representació gràfica Precision-Recall mitjana
figure('Name', 'Corba PR mitjana');
hold on;

P_mitjana = squeeze(mean(P_all(:, :), 1))';
R_mitjana = squeeze(mean(R_all(:, :), 1))';

plot(R_mitjana, P_mitjana, '-s', 'LineWidth', 2,'MarkerFaceColor','auto', ...
    'MarkerSize', 5, 'Color', "green");

grid on;
xlabel('Recall');
ylabel('Precision');
title('Corba Precision-Recall');
xticks(0:0.1:1);
yticks(0:0.1:1);
axis([0 1 0 1]);
axis square

legend("Dominant Color Descriptor (QFD)"); 
hold off;
saveas(gcf, 'PR_curve_DCD.png');

%% Representació visual de les imatges recuperades
fid = fopen([User_root, Data_root, Output_filename], 'r');

for i = 4:8
    % Llegir capçalera de la query
    linia_titol = fgetl(fid);
    parts = strsplit(linia_titol, ' ');
    nom_query_txt = parts{end-1};
    id_query_txt = sscanf(nom_query_txt, 'ukbench%d.jpg');
    grup_real_txt = floor(id_query_txt / 4);
    
    % Llegir resultats
    resultats = cell(1, Candidates);
    for k = 1:Candidates
        resultats{k} = fgetl(fid);
    end
    fgetl(fid); % línia en blanc
    
    % Crear figura
    figure('Name', ['Resultats: ' nom_query_txt], ...
           'Position', [50+(i*20) 100+(i*20) 1000 450], 'Color', 'w');
    
    % Mostrar imatge query
    subplot(2, 4, [1, 5]);
    img_query = imread(fullfile(User_root, nom_query_txt));
    imshow(img_query);
    title('IMATGE QUERY', 'Color',"black");
    
    % Mostrar 6 imatges recuperades
    posicions_graella = [2, 3, 4, 6, 7, 8]; 
    for k = 1:6
        subplot(2, 4, posicions_graella(k));
        img_rec = imread(fullfile(User_root, resultats{k}));
        imshow(img_rec);
        title(sprintf('Imatge top %d', k), 'Color', 'black');
    end
end

fclose(fid);