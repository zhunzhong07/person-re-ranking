function s = SetDefaultParams(s);
% s = SetDefaultParams(s);
% Sets default parameters
% s: user-specified parameters that are used instead of defaults

if (isfield(s, 'gamma') == 0),
    s.gamma = 1;
end

if (isfield(s, 'beta') == 0),
    s.beta = 1;
end

if (isfield(s, 'const_factor') == 0),
    s.const_factor = 40;
end

if (isfield(s, 'type4_rank') == 0),
    s.type4_rank = 5;
end

if (isfield(s, 'thresh') == 0),
   s.thresh = 10e-3; 
end

if (isfield(s, 'k') == 0),
    s.k = 4;
end

if (isfield(s, 'max_iters') == 0),
    s.max_iters = 100000;
end
