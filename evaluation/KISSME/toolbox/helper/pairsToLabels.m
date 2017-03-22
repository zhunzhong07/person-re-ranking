function [X,Y] = pairsToLabels(pairs, instance_matrix)
    imgs1 = [pairs.img1];      
    imgs2 = [pairs.img2];

    keymat = [[imgs1.classId] [imgs2.classId]; [imgs1.id] [imgs2.id]];
    [ids, idsndx] = unique(keymat','rows');

    X = instance_matrix(:,idsndx);
    Y = ids(:,1)';
end