% calculate and draw confusion matrix
function [ap_mat, r1_mat] = draw_confusion_matrix(ap, r1, queryCam)

ap_mat = zeros(6, 6);
r1_mat = zeros(6, 6);
count1 = zeros(6, 6);
count2 = zeros(6, 6);
for n = 1:length(queryCam)
    for k = 1:6
        ap_mat(queryCam(n), k) = ap_mat(queryCam(n), k) + ap(n, k);
        if ap(n, k) ~= 0
            count1(queryCam(n), k) = count1(queryCam(n), k) + 1;
        end
        if r1(n, k) >= 0
            r1_mat(queryCam(n), k) = r1_mat(queryCam(n), k) + r1(n, k);
            count2(queryCam(n), k) = count2(queryCam(n), k) + 1;
        end
    end
end
num_class = 6;
ap_mat = ap_mat./count1;
name_class{1} = 'Cam1';
name_class{2} = 'Cam2';
name_class{3} = 'Cam3';
name_class{4} = 'Cam4';
name_class{5} = 'Cam5';
name_class{6} = 'Cam6';
draw_cm(ap_mat,name_class,num_class);

r1_mat = r1_mat./count2;
name_class{1} = 'Cam1';
name_class{2} = 'Cam2';
name_class{3} = 'Cam3';
name_class{4} = 'Cam4';
name_class{5} = 'Cam5';
name_class{6} = 'Cam6';
draw_cm(r1_mat,name_class,num_class);