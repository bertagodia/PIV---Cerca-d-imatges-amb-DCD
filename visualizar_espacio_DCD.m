% Test rapid: verificar que extraer_DCD genera centroides normals
I = imread('ukbench00000.jpg');
I = imresize(I, 0.5);
dcd = extraer_DCD(I);

fprintf('num_colors: %d\n', dcd.num_colors);
fprintf('centroides:\n');
disp(dcd.centroides);
fprintf('sum(porcentajes): %.4f\n', sum(dcd.porcentajes));
