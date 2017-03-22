%LEARNALGOMLEUCLIDEAN Simulates plain L2 distance as learning algorithm.
classdef LearnAlgoMLEuclidean < LearnAlgo 
    
    properties 
       p %parameters 
       s %struct
    end
    
    properties (Constant)
        type = 'identity'
    end
    
    methods
        function obj = LearnAlgoMLEuclidean(p)        
            if nargin < 1
               p = struct(); 
            end
            
            if ~isfield(p,'roccolor')
                p.roccolor = 'r';
            end
            
            obj.p = p;
        end
        
        function s = learnPairwise(obj,X,idxa,idxb,matches)           
            s.M = eye(size(X,1));
            s.t = 0.0;
            s.learnAlgo = obj;
            s.roccolor = obj.p.roccolor;
        end
        
        function s = learn(obj,X,y)
            s.M = eye(size(X,1));
            s.t = 0.0;
            s.learnAlgo = obj;
            s.roccolor = obj.p.roccolor;
        end
        
        function d = dist(obj, s, X, idxa,idxb)
            d = cdistM(s.M,X,idxa,idxb); 
        end
    end    
end

