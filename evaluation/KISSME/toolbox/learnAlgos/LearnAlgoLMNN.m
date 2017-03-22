%LEARNALGOLMNN Wrapper class to the actual LMNN code
classdef LearnAlgoLMNN < LearnAlgo
    
    properties 
       p %parameters 
       s %struct
       available
       fhanlde
    end
    
    properties (Constant)
        type = 'lmnn'
    end
    
    methods
        function obj = LearnAlgoLMNN(p)
            if nargin < 1
              p = struct(); 
            end           
            if ~isfield(p,'knn')
                p.knn = 1;
            end

            if ~isfield(p,'maxiter')
                p.maxiter = 1000; %std
            end

            if ~isfield(p,'validation')
                p.validation = 0;
            end
            
            if ~isfield(p,'roccolor')
                p.roccolor = 'k';
            end
            
            if ~isfield(p,'quiet')
                p.quiet = 1;
            end

            obj.p  = p;
            check(obj);
        end
        
        function bool = check(obj)
           bool = exist('lmnn.m') == 2;
           if ~bool
               fprintf('Sorry %s not available\n',obj.type);
           end
           obj.fhanlde = @lmnn;
           
           if isunix && exist('lmnn2.m') == 2;
              obj.fhanlde = @lmnn2;
           end
           obj.available = bool;
        end
        
        function s = learnPairwise(obj,X,idxa,idxb,matches)
            if ~obj.available
                s = struct();
                return;
            end
            
            obj.p.knn = 1;
            
            X = X(:,[idxa(matches) idxb(matches)]); %m x d
            y = [1:sum(matches) 1:sum(matches)];
            
            tic;
            [s.L, s.Det] = obj.fhanlde(X,consecutiveLabels(y),obj.p.knn, ...
                'maxiter',obj.p.maxiter,'validation',obj.p.validation, ...
                'quiet',obj.p.quiet); 
            s.M = s.L'*s.L;
            s.t = toc;
            s.learnAlgo = obj;
            s.roccolor = obj.p.roccolor;
        end
        
        function s = learn(obj,X,y)
            if ~obj.available
                s = struct();
                return;
            end
            
            tic;
            [s.L, s.Det] = obj.fhanlde(X,consecutiveLabels(y),obj.p.knn, ...
                'maxiter', obj.p.maxiter,'validation',obj.p.validation, ... 
                'quiet',obj.p.quiet); 
            s.M = s.L'*s.L;
            s.t = toc;
            s.learnAlgo = obj;
            s.roccolor = obj.p.roccolor;
        end
        
        function d = dist(obj, s, X, idxa,idxb)
            d = cdistM(s.M,X,idxa,idxb); 
        end
    end    
end

% lmnn2 needs consecutive integers as labels
function ty = consecutiveLabels(y)
    uniqueLabels = unique(y);
    ty = zeros(size(y));
    for cY=1:length(uniqueLabels)
        mask = y == uniqueLabels(cY);
        ty(mask ) = cY;
    end
end