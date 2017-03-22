function ap_multi = compute_AP_multiCam(good_image, junk_image, index, queryCam, testCam)
good_cam = testCam(good_image);
good_cam_uni = unique(good_cam); 
ap_multi = zeros(1, 6);

% on the same camera
good_cam_now = queryCam;
ngood = length(junk_image)-1;
junk_image_now = [good_image; index(1)];
good_image_now = setdiff(junk_image, index(1));
old_recall = 0; 
old_precision = 1.0; 
ap = 0; 
intersect_size = 0; 
j = 0; 
good_now = 0; 
for n = 1:length(index) 
    flag = 0;
    if ~isempty(find(good_image_now == index(n), 1)) 
        flag = 1; % good image 
        good_now = good_now+1; 
    end
    if ~isempty(find(junk_image_now == index(n), 1))
        continue; % junk image 
    end

    if flag == 1%good
        intersect_size = intersect_size + 1; 
    end 
    if ngood == 0
        ap_multi(good_cam_now) = 0;
        break;
    end
    recall = intersect_size/ngood; 
    precision = intersect_size/(j + 1); 
    ap = ap + (recall - old_recall)*((old_precision+precision)/2); 
    old_recall = recall; 
    old_precision = precision; 
    j = j+1; 

    if good_now == ngood 
        ap_multi(good_cam_now) = ap;
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
    old_recall = 0; 
    old_precision = 1.0; 
    ap = 0; 
    intersect_size = 0; 
    j = 0; 
    good_now = 0; 
    for n = 1:length(index) 
        flag = 0;
        if ~isempty(find(good_image_now == index(n), 1)) 
            flag = 1; % good image 
            good_now = good_now+1; 
        end
        if ~isempty(find(junk_image_now == index(n), 1))
            continue; % junk image 
        end

        if flag == 1%good
            intersect_size = intersect_size + 1; 
        end 
        recall = intersect_size/ngood; 
        precision = intersect_size/(j + 1); 
        ap = ap + (recall - old_recall)*((old_precision+precision)/2); 
        old_recall = recall; 
        old_precision = precision; 
        j = j+1; 

        if good_now == ngood 
            ap_multi(good_cam_now) = ap;
            break; 
        end 
    end 
end

end


