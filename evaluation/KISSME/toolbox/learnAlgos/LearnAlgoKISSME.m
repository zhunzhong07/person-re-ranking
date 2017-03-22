% LEARNALGOKISSME Keep it simple and straightforward metric learning!
%
% LearnAlgoKISSME properties:
%   p  - Parameter struct.
%   p.roccolor - default 'g'.
%   p.pmetric  - Backproject on the cone of p.s.d. matrices? Default 1.
%   p.lambda   - Influence of the dissimilar pairs. Range 0 to 1, default
%   1.
%   s - struct to store the last result
%   available - if the LearnAlgoKISSME is ready
%
% LearnAlgoKISSME properties (Constant):
%   type - string identifier default 'kissme'
%
% LearnAlgoKISSME methods:
%   LearnAlgoKISSME  - ctor.
%   learnPairwise    - learn from pairwise equivalence labels
%   learn            - learn with fully supervised data
%   dist             - calculate distance between pairs of samples
%
% See also LearnAlgoLMNN,LearnAlgoITML,LearnAlgoLDML
%
% copyright by Martin Koestinger (2011)
% Graz University of Technology
% contact koestinger@icg.tugraz.at
%
% For more information, see <a href="matlab: 
% web('http://lrs.icg.tugraz.at/members/koestinger')">the ICG Web site</a>.
%
classdef LearnAlgoKISSME < LearnAlgo
    
    properties 
       p %parameters 
       s %struct
       available %are we ready?
    end
    
    properties (Constant)
        type = 'kissme'
    end
    
    methods
        function obj = LearnAlgoKISSME(p) 
            % obj = LearnAlgoKISSME(p) 
            % Constructor
            %
            % parameters:
            %   p  - Parameter struct.
            %   p.roccolor - default 'g'.
            %   p.pmetric - Backproject on the cone of p.s.d. matrices? Default 1.
            %   p.lambda - Influence of the dissimilar pairs. Range 0 to 1, default 1.
            %
            % return:
            %   obj       - object handle to instance of class LearnAlgoKISSME
            %   
           if nargin < 1
               p = struct(); 
           end
            
           if ~isfield(p,'lambda')
             p.lambda =  1;
           end
           
           if ~isfield(p,'roccolor')
                p.roccolor = 'g';
           end
           
           if ~isfield(p,'pmetric')
               p.pmetric = 1;
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
            %   obj       - instance of class LearnAlgoKISSME
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
            %   s.p       - Used parameters, see LearnAlgoKISSME properties for details.s
            %   s.learnAlgo - class handle to obj
            %   s.roccolor  - line color for ROC curve, default 'g'
            %   
            if ~obj.available
                s = struct();
                return;
            end
            
            idxa = double(idxa);
            idxb = double(idxb);
            
            %--------------------------------------------------------------
            %   KISS Metric Learning CORE ALGORITHM
            %
            
            tic;
            % Eqn. (12) - sum of outer products of pairwise differences (similar pairs)
            % normalized by the number of similar pairs.
            covMatches    = SOPD(X,idxa(matches),idxb(matches)) / sum(matches);
            % Eqn. (13) - sum of outer products of pairwise differences (dissimilar pairs)
            % normalized by the number of dissimilar pairs.
            covNonMatches = SOPD(X,idxa(~matches),idxb(~matches)) / sum(~matches);
            t = toc;
            
            tic;
            % Eqn. (15-16)
            s.M = inv(covMatches) - obj.p.lambda * inv(covNonMatches);   
            if obj.p.pmetric
                % to induce a valid pseudo metric we enforce that  M is p.s.d.
                % by clipping the spectrum
                s.M = validateCovMatrix(s.M);
            end
            s.t = toc + t;   
            
            %
            %   END KISS Metric Learning CORE ALGORITHM
            %--------------------------------------------------------------
            
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
            %   obj       - instance of class LearnAlgoKISSME
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

