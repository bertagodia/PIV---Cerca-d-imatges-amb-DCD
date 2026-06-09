function HBaseDades=Algo1()
    for i = 1:2000 
        nom_img = sprintf('%s%05d%s', 'ukbench', i-1, '.jpg');
        I= imread(nom_img);
        IBN = rgb2gray(I);
        H = imhist(IBN);
        HBaseDades(i,:) = H/sum(H); % Normalitzem
    end
end