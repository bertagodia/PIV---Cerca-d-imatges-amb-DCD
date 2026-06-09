
%% Inicialització i representació de la base de dades
Hdb=Algo1();

%% Avaluació del sistema i comparativa de mètriques
% Variables de rutes
User_root      = 'C:\Users\tomas\Documents\UPC\3B\PIV\Prog1\DB\';
Data_root      = 'Test\';
Input_filename = 'input.txt';
Output_filename= 'output.txt';
Candidates     = 10; 

% Llegir l'arxiu d'entrada
Input = textread([User_root, Data_root, Input_filename],'%s');
Num_images = length(Input); 

% Matrius per Precision i Recall
P_all = zeros(3, Num_images, Candidates);
R_all = zeros(3, Num_images, Candidates);
Num_rellevants_total = 4;

% Obrim el fitxer de sortida
a = fopen([User_root, Data_root, Output_filename],'w'); 

for i = 1:Num_images
    nom_query = char(Input(i));
    
    % --- CRIDA CORRECTA A ALGO3 ---
    % Passem la ruta completa cap a la imatge query i la base de dades
    ruta_query = fullfile(User_root, nom_query); 
    index_methods = Algo3(ruta_query, Hdb, 10);
    
    % --- ESCRIPTURA A OUTPUT.TXT (Utilitzant el Mètode 3 com a principal) ---
    fprintf(a, 'Retrieved list for query image %s \n', nom_query);
    for j = 1:Candidates
        % Agafem els resultats de la fila 3 (Mètode 3)
        retrieved_id_txt = index_methods(3, j) - 1; 
        fprintf(a, '%s\n', sprintf('ukbench%05d.jpg', retrieved_id_txt));
    end
    fprintf(a, '\n');
    
    % --- AVALUACIÓ PRECISION-RECALL PELS 3 MÈTODES ---
    query_id = sscanf(nom_query, 'ukbench%d.jpg');
    grup_real = floor(query_id / 4);
    
    for m = 1:3 
        TP_acumulats = 0;
        for j = 1:Candidates
            retrieved_id = index_methods(m, j) - 1; 
            grup_retrieved = floor(retrieved_id / 4);
            
            if grup_retrieved == grup_real
                TP_acumulats = TP_acumulats + 1;
            end
            
            P_all(m, i, j) = TP_acumulats / j;
            R_all(m, i, j) = TP_acumulats / Num_rellevants_total;
        end
    end
end

% Tancar l'arxiu
fclose(a);

%% Representació Gràfica

figure('Name', 'Comparativa de Mètriques de Distància');
hold on;

colors = {'b', 'g', 'r'};
marcadors = {'-o', '-s', '-^'};
noms_metodes = {'Algo2_1: \chi^2', 'Algo2_2: Bhattacharyya', 'Algo2_3: Manhattan'};

colororder(colors);

for m = 1:3
    P_mitjana = squeeze(mean(P_all(m, :, :), 2))';
    R_mitjana = squeeze(mean(R_all(m, :, :), 2))';
    
    plot(R_mitjana, P_mitjana,'Marker','square','MarkerFaceColor','auto', 'LineWidth',1.25);
end

grid on;
xlabel('Recall');
ylabel('Precision');
title('Comparativa Precision-Recall');
xticks(0:0.1:1);
yticks(0:0.1:1);
axis([0 1 0 1]);
axis square;
legend(noms_metodes, 'Location', 'southwest');
hold off;
