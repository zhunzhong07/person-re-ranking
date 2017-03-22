clear;

load('cuhk-03.mat');

detected_or_labeled = 1;

if detected_or_labeled == 1
    img_vector = detected;
    load('cuhk03_multishot_config_detected.mat');
    path  = 'cuhk03_detected/';
    mkdir(path);
else
    img_vector = labeled;
    load('cuhk03_multishot_config_labeled.mat');
    path  = 'cuhk03_labeled/';
    mkdir(path);
end

for i = 1: length(filelist)
    img_name = filelist{i};
    j1 = str2num(img_name(1));
    j2 = str2num(img_name(3:5));
    j3 = str2num(img_name(9:10));
    imwrite(img_vector{j1}{j2,j3}, [path img_name]);  
end