clear;

detected_or_labeled = 1;

if detected_or_labeled == 1
    load('cuhk03_new_protocol_config_detected.mat');
    file_path = 'cuhk03_detected/';
    savepath  = 'train_cuhk03_detected';
else
    load('cuhk03_new_protocol_config_labeled.mat');
    file_path = 'cuhk03_labeled/';
    savepath  = 'train_cuhk03_labeled';
end

fp = fopen([savepath '.txt'],'wt');
for i = 1: length(train_idx)
    imgpath = [file_path filelist{train_idx(i)}];
    if i == 1
        label = 0;
    else
        if labels(train_idx(i)) ~= labels(train_idx(i-1))
            label = label +1;
        end
    end
    fprintf(fp, '%s\n', [imgpath ' ' num2str(label)]);
end
fclose(fp);
