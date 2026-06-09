function idx_recuperats = Algo3_DCD(Nom_img, DB_DCD, Candidates)
    % 1. Llegim la imatge i la reescalem per 0.5
    Imaget = imread(Nom_img);
    Imaget = imresize(Imaget, 0.5);
    
    % 2. Extreure el descriptor DCD de la imatge de cerca
    Query_DCD = extraer_DCD(Imaget);

    % 3. Calcular la Quadratic Form Distance contra tota la Base de Dades
    distancies = Algo2_DCD(Query_DCD, DB_DCD);

    % 4. Ordenar de menor a major distància
    [~, idx_ordenats] = sort(distancies, 'ascend');
    
    % 5. Retornar el Top N candidats
    idx_recuperats = idx_ordenats(1:Candidates);
end