classdef LearnAlgoSVM < LearnAlgo
     
    properties 
       p %parameters 
       s %struct
       available
    end
    
    properties (Constant)
        type = 'svm'
    end
    
    methods
        function obj = LearnAlgoSVM(p)         
            if nargin < 1
               p = struct(); 
            end
            
            if ~isfield(p,'smoothing')
               p.smoothing =  1;
            end
            
            if ~isfield(p,'mu')
               p.mu =  0;
            end

            if ~isfield(p,'sigma')
               p.sigma =  1;
            end

            if ~isfield(p,'sqrt')
                p.sqrt = 0;
            end
            
            if ~isfield(p,'liblinear_options')
                p.liblinear_options = '-B 1 -s 2';
            end
            
            if ~isfield(p,'roccolor')
                p.roccolor = [1 0.5 0];
            end
            
            obj.p  = p;
            check(obj);
        end
        
        function bool = check(obj)
           bool = exist('train') == 3 & exist('predict') == 3;
           if ~bool
               className = class(obj);
               fprintf('Sorry %s not available\n',className);
           end
           obj.available = bool;
        end
        
        function s = learnPairwise(obj,X,idxa,idxb,matches)
            if ~obj.available
               s = struct();
               return;
            end
            
            a = X(:,idxa);
            b = X(:,idxb);

            if obj.p.smoothing
                g = normpdf((a + b).*0.5,obj.p.mu,obj.p.sigma);
            else
                g = 1;
            end

            if obj.p.sqrt
                instance_matrix = [abs(sqrt(a) - sqrt(b)) .* g; (sqrt(a) .* sqrt(b)) .* g];
            else
                instance_matrix = [abs(a - b) .* g; (a .* b) .* g];
            end

            tic;
            s.model = train(double(matches)', sparse(instance_matrix'), obj.p.liblinear_options);
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
        
        function d = dist(obj, s, X, idxa,idxb,gt_matches)    
            if ~obj.available
               d = NaN;
               return;
            end
            
            if nargin < 6
                gt_matches = zeros(size(idxa));
            end
            
            a = X(:,idxa);
            b = X(:,idxb);
            
            if obj.p.smoothing
                g = normpdf((a + b).*0.5,obj.p.mu,obj.p.sigma);
            else
                g = 1;
            end

            if obj.p.sqrt
                instance_matrix = [abs(sqrt(a) - sqrt(b)) .* g; (sqrt(a) .* sqrt(b)) .* g];
            else
                instance_matrix = [abs(a - b) .* g; (a .* b) .* g];
            end
            
            [predicted_label, accuracy, d] = predict(double(gt_matches'), sparse(instance_matrix'),s.model);
            d = d' * -1; % turn classifier score into distance
        end
    end    
end

