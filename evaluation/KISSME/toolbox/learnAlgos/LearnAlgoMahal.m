% LEARNALGOMAHAL Mahalanobis distance formed of the similar pairs
%
% LearnAlgoMahal properties:
%   p  - Parameter struct.
%   p.roccolor - default 'g'.
%   s - struct to store the last result
%   available - if the LearnAlgoKISSME is ready
%
% LearnAlgoMahal properties (Constant):
%   type - string identifier default 'mahal'
%
% LearnAlgoMahal methods:
%   LearnAlgoMahal  - ctor.
%   learnPairwise    - learn from pairwise equivalence labels
%   learn            - learn with fully supervised data
%   dist             - calculate distance between pairs of samples
%
% See also LEARNALGOKISSME,LearnAlgoLMNN,LearnAlgoITML,LearnAlgoLDML
%
% copyright by Martin Koestinger (2011)
% Graz University of Technology
% contact koestinger@icg.tugraz.at
%
% For more information, see <a href="matlab: 
% web('http://lrs.icg.tugraz.at/members/koestinger')">the ICG Web site</a>.
%
classdef LearnAlgoMahal < LearnAlgo
    
    properties 
       p %parameters 
       s %struct
       available
    end
    
    properties (Constant)
        type = 'mahal'
    end
    
    methods
        function obj = LearnAlgoMahal(p)     
            % obj = LearnAlgoMahal(p) 
            % Constructor
            %
            % parameters:
            %   p  - Parameter struct.
            %   p.roccolor - default 'g'.
            %
            % return:
            %   obj       - object handle to instance of class LearnAlgoKISSME
            %   
           if nargin < 1
               p = struct(); 
           end
            
           if ~isfield(p,'lambda')
             p.lambda =  0;
           end
           
           if ~isfield(p,'roccolor')
                p.roccolor = 'm';
           end
           
           obj.p  = p;
           check(obj);
        end
        
        function bool = check(obj)
           % bool = check(obj)
           % Checks if all dependencies are satisfied
           %
           bool = exist('SOPD') ~= 0;
           if ~bool
               className = class(obj);
               fprintf('Sorry %s not available\n',className);
           end
           obj.available = bool;
        end
        
        function s = learnPairwise(obj,X,idxa,idxb,matches)           
            % s = learnPairwise(obj,X,idxa,idxb,matches)
            % Learn from pairwise equivalence labels
            %
            % parameters:
            %   obj       - instance of class LearnAlgoMahal
            %   X         - input matrix, each column is an input vector 
            %   [DxN*2]. N is the number of pairs. D is the feature 
            %   dimensionality
            %   idxa      - index of image A in X [1xN]
            %   idxb      - index of image B in X [1xN]
            %   matches   - matches defines if a pair is similar (1) or 
            %   dissimilar (0)
            %
            % return:
            %   s         - Result data struct
            %   s.M       - Trained quadratic distance metric
            %   s.t       - Training time in seconds
            %   s.p       - Used parameters, see LearnAlgoMahal properties for details.s
            %   s.learnAlgo - class handle to obj
            %   s.roccolor  - line color for ROC curve, default 'g'
            %   
            if ~obj.available
                s = struct();
                return;
            end
            
            tic;
            covMatches = SOPD(X,idxa(matches),idxb(matches)) / sum(matches);
            t = toc;
            
            tic;
            s.M = inv(covMatches);   
            s.t = toc + t;             
            s.learnAlgo = obj;
            s.roccolor = obj.p.roccolor;
        end
        
        function s = learn(obj,X,y)
            % not implemented yet, sorry.
            if ~obj.available
                s = struct();
                return;
            end
            
            s.roccolor = obj.p.roccolor;
            error('not implemented yet!');
        end
        
        function d = dist(obj, s, X, idxa,idxb)  
            % d = dist(obj, s, X, idxa,idxb)
            % Calculate the distance between pairs of samples
            %
            % parameters:
            %   obj       - instance of class LearnAlgoMahal
            %   s         - struct with member M, quadratic form
            %   X         - Input matrix (each column is an input vector)
            %   idxa,idxb - idxa(c),idxb(c) index of images a,b, pair c in X
            %   matches   - matches(c) defines if pair c is similar (1) or dissimilar (0)
            %
            % return:
            %   d         - distance for each pair specified in idxa,idxb
            %   
            d = cdistM(s.M,X,idxa,idxb); 
        end
    end    
end

