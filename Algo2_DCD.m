function DB = Algo1_DCD()
    numImatges = 2000;
    DB = cell(numImatges,1);
    h = waitbar(0, 'Iniciando procesamiento de imágenes...', 'Name', 'Extrayendo Características DCD');
    
    for i = 1:numImatges 
        nom_img = sprintf('%s%05d%s', 'ukbench', i-1, '.jpg');
        I = imread(nom_img);
        I_pequena = imresize(I, 0.5);
        DB{i,1} = extraer_DCD(I_pequena);

        if mod(i, 10) == 0
            porcentaje = i / numImatges;
            mensaje = sprintf('Procesando: %d de %d imágenes (%.1f%%)', i, numImatges, porcentaje * 100);
            waitbar(porcentaje, h, mensaje);
        end
    end
    close(h);
end
