FRAMEWORK_DIR = fileparts(mfilename('fullpath'));
LIB_DIR = fullfile(FRAMEWORK_DIR,'lib');

%--------------------------------------------------------------------------
% Large Margin Nearest Neighbor Metric Learning (LMNN)
%
% License: na
% Url: http://www.cse.wustl.edu/~kilian/code/page21/page21.html
%--------------------------------------------------------------------------

try
    url ='http://www.cse.wustl.edu/~kilian/code/files/LMNN.zip';
    LMNN_DIR = fullfile(LIB_DIR,'LMNN');
    unzip(url,LIB_DIR);
    if isunix || ismac
       run(fullfile(LMNN_DIR,'install.m'));
    else
       run(fullfile(LMNN_DIR,'installWINDOWS.m'));
    end
    clc;
    clc; fprintf('Installing LMNN succeeded!\n');
    pause(0.5);
catch ME
    clc; fprintf('Warning: Installing LMNN failed!\n');
    pause(2);
end

%--------------------------------------------------------------------------
% Information Theoretic Metric Learning algorithm (ITML)
%
% License: na
% Url: http://www.cs.utexas.edu/~pjain/itml/
%--------------------------------------------------------------------------
try
    url ='http://www.cs.utexas.edu/~pjain/itml/download/itml-1.2.tar.gz';
    untar(url,LIB_DIR);
    clc; fprintf('ITML installation succeeded!\n');
    pause(0.5);
catch ME
    clc; fprintf('Warning: ITML installation failed!\n');
    pause(2);
end

%--------------------------------------------------------------------------
% Logistic Discriminant-based Metric Learning  (LDML)
%
% License: na
% Url: http://lear.inrialpes.fr/people/guillaumin/code.php#mildml
%--------------------------------------------------------------------------

try
    url = 'http://lear.inrialpes.fr/people/guillaumin/code/MildML_0.1.tar.gz';
    untar(url,LIB_DIR);
    clc; fprintf('LDML installation succeeded!\n');
    pause(0.5);
catch ME
    clc; fprintf('Warning: LDML installation failed!\n');
    pause(2);
end

%--------------------------------------------------------------------------
% LIBLINEAR / Linear SVM
%
% License: New BSD License
% Url: http://www.csie.ntu.edu.tw/~cjlin/liblinear/
%--------------------------------------------------------------------------

try
    url = 'http://www.csie.ntu.edu.tw/~cjlin/cgi-bin/liblinear.cgi?+http://www.csie.ntu.edu.tw/~cjlin/liblinear+zip';
    unzip(url,LIB_DIR);
    if ~strcmp(computer,'PCWIN64')
       LIB_LIN_DIR = dir(fullfile(LIB_DIR,'liblinear*'));
       LIB_LIN_DIR = fullfile(LIB_DIR,LIB_LIN_DIR.name,'matlab');
       wd = cd;
       cd(LIB_LIN_DIR);
       delete(fullfile(cd,'run.m'));
       make;
       cd(wd);
    end
    clc; fprintf('LIBLINEAR installation succeeded!\n');
    pause(0.5);
catch ME
    clc; fprintf('Warning: LIBLINEAR installation failed!\n');
    pause(2);
end
