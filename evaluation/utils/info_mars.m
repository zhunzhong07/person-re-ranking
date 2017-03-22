% generate info
if ~exist('info/train_name.txt')
    img_dir = 'bbox_test/';
    files = dir(img_dir);
    files = files(3:end);
    fid = fopen('info/test_name.txt', 'w');
    for n = 1:length(files)
        n
        img_files = dir([img_dir files(n).name '/*.jpg']);
        for m = 1:length(img_files)
            fprintf(fid, '%s\r\n', img_files(m).name);
        end
    end
    fclose(fid);

    img_dir = 'bbox_train/';
    files = dir(img_dir);
    files = files(3:end);
    fid = fopen('info/train_name.txt', 'w');
    for n = 1:length(files)
        n
        img_files = dir([img_dir files(n).name '/*.jpg']);
        for m = 1:length(img_files)
            fprintf(fid, '%s\r\n', img_files(m).name);
        end
    end
    fclose(fid);
end


if ~exist('info/basic_info.mat');
    train_img_files = textread('info/train_name.mat', '%s');
    test_img_files = textread('info/test_name.mat', '%s');
    train_ID = zeros(length(train_img_files), 1);
    train_Cam = zeros(length(train_img_files), 1);
    train_Tracklet = zeros(length(train_img_files), 1);
    test_ID = zeros(length(test_img_files), 1);
    test_Cam = zeros(length(test_img_files), 1);
    test_Tracklet = zeros(length(test_img_files), 1);
    for n = 1:length(train_img_files)
        name = train_img_files{n};
        train_ID(n) = str2num(name(1:4));
        train_Cam(n) = str2num(name(6));
        train_Tracklet(n) = str2num(name(8:11));
    end
    for n = 1:length(test_img_files)
        name = test_img_files{n};
        test_ID(n) = str2num(name(1:4));
        test_Cam(n) = str2num(name(6));
        test_Tracklet(n) = str2num(name(8:11));
    end
    save('info/basic_info.mat', 'train_ID', 'train_Cam', 'train_Tracklet', 'test_ID', 'test_Cam', 'test_Tracklet');
else
    load('info/basic_info.mat');
end

train_nPerson = length(unique(train_ID));
trainID_uni = unique(train_ID);
test_nPerson = length(unique(test_ID));
testID_uni = unique(test_ID);
count = 0;
tracklet_count = 0;
while (1)
    count = count + 1;
    pos = find(train_ID == trainID_uni(count));
    track_uni = unique(train_Tracklet(pos));
    for n = 1:length(track_uni)
        tracklet_count = tracklet_count + 1;
        pos2 = find(train_Tracklet(pos) == track_uni(n));
        tracks_train(tracklet_count).start = pos(pos2(1));
        tracks_train(tracklet_count).end = pos(pos2(end));
        tracks_train(tracklet_count).ID = train_ID(pos(pos2(1)));
        tracks_train(tracklet_count).cam = train_Cam(pos(pos2(1)));
    end
    if count == train_nPerson
        break;
    end
end

count = 0;
tracklet_count = 0;
while (1)
    count = count + 1;
    pos = find(test_ID == testID_uni(count));
    track_uni = unique(test_Tracklet(pos));
    for n = 1:length(track_uni)
        tracklet_count = tracklet_count + 1;
        pos2 = find(test_Tracklet(pos) == track_uni(n));
        tracks_test(tracklet_count).start = pos(pos2(1));
        tracks_test(tracklet_count).end = pos(pos2(end));
        tracks_test(tracklet_count).ID = test_ID(pos(pos2(1)));
        tracks_test(tracklet_count).cam = test_Cam(pos(pos2(1)));
    end
    if count == test_nPerson
        break;
    end
end
track_train_info = zeros(length(tracks_train), 4);
for n = 1:length(tracks_train)
    track_train_info(n, 1) = tracks_train(n).start;
    track_train_info(n, 2) = tracks_train(n).end;
    track_train_info(n, 3) = tracks_train(n).ID;
    track_train_info(n, 4) = tracks_train(n).cam;
end

track_test_info = zeros(length(tracks_test), 4);
for n = 1:length(tracks_test)
    track_test_info(n, 1) = tracks_test(n).start;
    track_test_info(n, 2) = tracks_test(n).end;
    track_test_info(n, 3) = tracks_test(n).ID;
    track_test_info(n, 4) = tracks_test(n).cam;
end
save('info/tracks_train_info.mat', 'track_train_info');
save('info/tracks_test_info.mat', 'track_test_info');
% save('tracks_train.mat', 'tracks_train', '-v7.3');
% save('tracks_test.mat', 'tracks_test', '-v7.3');




