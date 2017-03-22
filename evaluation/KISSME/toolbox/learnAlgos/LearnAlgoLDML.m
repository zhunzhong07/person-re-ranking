%LEARNALGOITML Wrapper class to the actual LDML code
classdef LearnAlgoLDML < LearnAlgo
    
    properties 
       p %parameters 
       s %struct
       available
    end
    
    properties (Constant)
        type = 'ldml'
    end
    
    methods
        function obj = LearnAlgoLDML(p)
           if nargin < 1
              p = struct(); 
           end
           
           if ~isfield(p,'roccolor')
                p.roccolor = 'c';
           end
           
           if ~isunix
                display('Warning LDML may not work properly!');
                obj.available = 0;
                return;
            end
           
           obj.p  = p;
           check(obj);
        end
        
        function bool = check(obj)
           bool = exist('ldml_learn') ~= 0;
           if ~bool
               fprintf('Sorry %s not available\n',obj.type);
           end
           obj.available = bool;
        end
        
        function s = learnPairwise(obj,X,idxa,idxb,matches)   
            if ~isunix || ~obj.available
                s = struct();
                return;
            end
            
            X = X(:,[idxa(matches) idxb(matches)])'; %m x d
            Y = [1:sum(matches) 1:sum(matches)]';
            tic;
            [ s.L, s.b, s.info ] = ldml_learn( X, Y);
            s.M = s.L*s.L';
            s.t = toc;
            s.learnAlgo = obj;
            s.roccolor = obj.p.roccolor;
        end
        
        function s = learn(obj,X,y)
            if ~isunix || ~obj.available
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

