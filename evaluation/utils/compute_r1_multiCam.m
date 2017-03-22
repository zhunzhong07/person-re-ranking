function r1 = compute_r1_multiCam(good_image, junk_image, index, queryCam, testCam)
good_cam = testCam(good_image);
good_cam_uni = unique(good_cam); 
r1 = ones(1, 6)-3;

% on the same camera
good_cam_now = queryCam;
ngood = length(junk_image)-1;
junk_image_now = [good_image; index(1)];
good_image_now = setdiff(junk_image, index(1));
good_now = 0; 
for n = 1:length(index) 
    flag = 0;
    if ngood == 0
        r1(good_cam_now) = -1;
        break;
    end
    if ~isempty(find(good_image_now == index(n), 1)) 
        flag = 1; % good image 
        good_now = good_now+1; 
    end
    if ~isempty(find(junk_image_now == index(n), 1))
        continue; % junk image 
    end
    if flag == 0
        r1(good_cam_now) = 0;
        break;
    end
    if flag == 1%good
        r1(good_cam_now) = 1;
        break;
    end 
end 

for k = 1:length(good_cam_uni)
    good_cam_now = good_cam_uni(k);
    ngood = length(find(good_cam == good_cam_now));
    pos_junk = find(good_cam ~= good_cam_now);
    junk_image_now = [junk_image; good_image(pos_junk)];
    pos_good = find(good_cam == good_cam_now);
    good_image_now = good_image(pos_good);
    for n = 1:length(index) 
        flag = 0;
        if ngood == 0
            r1(good_cam_now) = -1;
            break;
        end
        if ~isempty(find(good_image_now == index(n), 1)) 
            flag = 1; % good image 
        end
        if ~isempty(find(junk_image_now == index(n), 1))
            continue; % junk image 
        end

        if flag == 0
            r1(good_cam_now) = 0;
            break;
        end
        if flag == 1%good
            r1(good_cam_now) = 1;
            break;
        end 
    end 
end

end


