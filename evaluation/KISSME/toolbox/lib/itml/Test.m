disp('Loading iris data');
X = load('data/iris.mtx');
y = load('data/iris.truth');

disp('Running ITML');
num_folds = 2;
knn_neighbor_size = 4;
acc = CrossValidateKNN(y, X, @(y,X) MetricLearningAutotuneKnn(@ItmlAlg, y, X), num_folds, knn_neighbor_size);

disp(sprintf('kNN cross-validated accuracy = %f', acc));

