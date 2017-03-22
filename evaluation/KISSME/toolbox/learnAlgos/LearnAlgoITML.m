%LEARNALGOITML Wrapper class to the actual ITML code
classdef LearnAlgoITML < LearnAlgo
    
    properties 
       p %parameters 
       s %struct
       available
    end
    
    properties (Constant)
        type = 'itml'
    end
    
    methods
        function obj = LearnAlgoITML(p)
           if nargin < 1
              p = struct(); 
           end
           
           if ~isfield(p,'roccolor')
                p.roccolor = 'b';
           end
           obj.p  = p;
           check(obj);
        end
        
        function bool = check(obj)
           bool = exist('ItmlAlg') ~= 0;
           if ~bool
               fprintf('Sorry %s not available\n',obj.type);
           end
           obj.available = bool;
        end
        
        function s = learnPairwise(obj,X,idxa,idxb,matches)
            if ~obj.available
                s = struct();
                return;
            end
            
            tic;
            s.M = PairMetricLearning(@ItmlAlg, idxa', idxb', matches, X');
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
            s.M = MetricLearning(@ItmlAlg, y', X');
            s.t = toc; 
            s.learnAlgo = obj;
            s.roccolor = obj.p.roccolor;
        end
        
        function d = dist(obj, s, X, idxa,idxb)
            d = cdistM(s.M,X,idxa,idxb); 
        end
    end    
end

