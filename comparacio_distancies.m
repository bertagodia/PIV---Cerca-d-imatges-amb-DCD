function index_methods = Algo3(Nom_img, Hdb, Candidates)
    
    % Llegim la imatge
    Imaget = imread(Nom_img);
    IBNt = rgb2gray(Imaget);
    H=imhist(IBNt);
    H_Comparar=H/sum(H);

    % Calcular la distància entre l'histograma de la imatge seleccionada i la base de dades

    d1 = Algo2_1(H_Comparar, Hdb');
    d2 = Algo2_2(H_Comparar, Hdb');
    d3 = Algo2_3(H_Comparar, Hdb');

    [d1,idx1] = sort(d1);
    [d2,idx2] = sort(d2);
    [d3,idx3] = sort(d3);
    
    index_methods = [idx1(1:Candidates); 
                     idx2(1:Candidates); 
                     idx3(1:Candidates)];
end