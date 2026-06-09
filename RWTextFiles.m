
%% Inicialització i representació de la base de dades
Hdb=Algo1();

%Representació de la matriu d'histogrames
figure(1); mesh(Hdb); colormap("turbo"); axis("tight"); colorbar();
xlabel('Escala de grisos');
ylabel('Index de la Imatge');
zlabel('Num of pixels');
title('Representació de imatges amb historiogrames');


%% Avaluació del sistema: PR Individual per Imatge (Mètode Chi-Quadrat)
% Variables de rutes
User_root      = 'C:\Users\tomas\Documents\UPC\3B\PIV\Prog1\DB\';
Data_root      = 'Test\';
Input_filename = 'input.txt';
Output_filename= 'output.txt';
Candidates     = 10; 

% Llegir l'arxiu d'entrada
Input = textread([User_root, Data_root, Input_filename],'%s');
Num_images = length(Input); 

% Matrius per Precision i Recall (ara només 2D: Imatge x Rank_N)
P_all = zeros(Num_images, Candidates);
R_all = zeros(Num_images, Candidates);
Num_rellevants_total = 4;

% Obrim el fitxer de sortida
a = fopen([User_root, Data_root, Output_filename],'w'); 

for i = 1:Num_images
    nom_query = char(Input(i));
    
    % --- CRIDA A ALGO3 ---
    ruta_query = fullfile(User_root, nom_query); 
    index_methods = Algo3(ruta_query, Hdb, 10);
    idx_recuperats = index_methods(2, :);
    
    % --- ESCRIPTURA A OUTPUT.TXT ---
    fprintf(a, 'Retrieved list for query image %s \n', nom_query);
    for j = 1:Candidates
        retrieved_id_txt = idx_recuperats(j) - 1; 
        fprintf(a, '%s\n', sprintf('ukbench%05d.jpg', retrieved_id_txt));
    end
    fprintf(a, '\n');
    
    % --- AVALUACIÓ PRECISION-RECALL (INDIVIDUAL) ---
    query_id = sscanf(nom_query, 'ukbench%d.jpg');
    grup_real = floor(query_id / 4);
    TP_acumulats = 0;
    
    for j = 1:Candidates
        retrieved_id = idx_recuperats(j) - 1; 
        grup_retrieved = floor(retrieved_id / 4);
        
        if grup_retrieved == grup_real
            TP_acumulats = TP_acumulats + 1;
        end
        
        % Guardem el P i R específic d'aquesta imatge 'i'
        P_all(i, j) = TP_acumulats / j;
        R_all(i, j) = TP_acumulats / Num_rellevants_total;
    end
end

% Tancar l'arxiu
fclose(a);

%% Representació Gràfica Individual
figure('Name', 'PR Individual per Imatge');
hold on;

P_mitjana = squeeze(mean(P_all(:, :), 1))';
R_mitjana = squeeze(mean(R_all(:, :), 1))';

plot(R_mitjana, P_mitjana, '-s', 'LineWidth', 2,'MarkerFaceColor','auto', ...
    'MarkerSize', 5, 'Color', "green");

% Format de la gràfica
grid on;
xlabel('Recall');
ylabel('Precision');
title(['Corba Precision-Recall (Distància Bhattacharyya)']);
xticks(0:0.1:1);
yticks(0:0.1:1);
axis([0 1 0 1]);
axis square

% Posem la llegenda fora de la gràfica perquè no tapi les línies (són moltes)
legend("Coef. Bhattacharyya"); 
hold off;

