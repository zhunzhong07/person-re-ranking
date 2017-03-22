function preds = KNN(y, X, M, k, Xt)
% function preds = KNN(y, X, M, k, Xt)
% perform knn classification on each row of Xt
% M is the factor matrix : A = M*M'


add1 = 0;
if (min(y) == 0),
    y = y + 1;
    add1 = 1;
end
[n,m] = size(X);
[nt, m] = size(Xt);
K = (X*M)*(M'*Xt');
l = zeros(n,1);
for (i=1:n),
    l(i) = (X(i,:)*M)*(M'*X(i,:)');
end

lt = zeros(nt,1);
for (i=1:nt),
    lt(i) = (Xt(i,:)*M)*(M'*Xt(i,:)');
end

D = zeros(n, nt);
for (i=1:n),
    for (j=1:nt),
        D(i,j) = l(i) + lt(j) - 2 * K(i, j);
    end
end

[V, Inds] = sort(D);

preds = zeros(nt,1);
for (i=1:nt),
    counts = [];
    for (j=1:k),        
        if (y(Inds(j,i)) > length(counts)),
            counts(y(Inds(j,i))) = 1;
        else
            counts(y(Inds(j,i))) = counts(y(Inds(j,i))) + 1;
        end
    end
    [v, preds(i)] = max(counts);
end
if (add1 == 1),
    preds = preds - 1;
end