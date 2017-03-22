function [ds,rocPlot] = evalData(pairs, ds, params)
% EVALDATA Evaluate results and plot figures
%
% Input:
%   pairs - [1xN] struct. N is the number of pairs. Fields: pairs.fold
%   pairs.match, pairs.img1, pairs.img2.
%   ds        - [1xF] data struct. F is the number of folds. 
%   ds.method.dist is required to compute tpr, fpr, etc.
%   params    - Parameter struct with the following fields:
%   params.title - Title for ROC plot.
%   params.saveDir - Directory to which all the plots are saved 
%
% Output:
%   ds        - Augmented result data struct
%   rocPlot   - handle to the ROC figure
%   
% copyright by Martin Koestinger (2011)
% Graz University of Technology
% contact koestinger@icg.tugraz.at
%
% For more information, see <a href="matlab: 
% web('http://lrs.icg.tugraz.at/members/koestinger')">the ICG Web site</a>.
%

if ~isfield(params,'title')
    params.title = 'ROC'; 
end

matches = logical([pairs.match]);

%-- EVAL FOLDS --%
un = unique([pairs.fold]);
for c=1:length(un)
    testMask = [pairs.fold] == un(c);  

    % eval fold
    names = fieldnames(ds(c));
    for nameCounter=1:length(names)
        %tpr, fpr
        [ds(c).(names{nameCounter}).tpr, ds(c).(names{nameCounter}).fpr] = ...
            icg_roc(matches(testMask),-ds(c).(names{nameCounter}).dist);

        [ignore, ds(c).(names{nameCounter}).eerIdx] = min(abs(ds(c).(names{nameCounter}).tpr ...
            - (1-ds(c).(names{nameCounter}).fpr)));

        %eer
        ds(c).(names{nameCounter}).eer = ... 
            ds(c).(names{nameCounter}).tpr(ds(c).(names{nameCounter}).eerIdx);
    end

    h = myplotroc(ds(c),matches(testMask),names,params);
    title(sprintf('%s Fold: %d',params.title, c));

    %save figure if save dir is specified
    if isfield(params,'saveDir')
        exportAndCropFigure(h,sprintf('Fold%d',c),params.saveDir);
    end
    close;
end

%-- EVAL ALL --%
names = fieldnames(ds);
for nameCounter=1:length(names)
   s = [ds.(names{nameCounter})];
   ms.(names{nameCounter}).std = std([s.eer]);
   ms.(names{nameCounter}).dist = [s.dist];
   ms.(names{nameCounter}).se  = ms.(names{nameCounter}).std/sqrt(length(un));
   [ms.(names{nameCounter}).tpr, ms.(names{nameCounter}).fpr, ms.(names{nameCounter}).thresh] = icg_roc(matches,-[s.dist]); 
   [ignore, ms.(names{nameCounter}).eerIdx] = min(abs(ms.(names{nameCounter}).tpr ...
        - (1-ms.(names{nameCounter}).fpr)));  
   ms.(names{nameCounter}).eer = ms.(names{nameCounter}).tpr(ms.(names{nameCounter}).eerIdx);
   ms.(names{nameCounter}).type = names{nameCounter};
   ms.(names{nameCounter}).roccolor = s(1).roccolor;
end

[rocPlot.h,rocPlot.hL] = myplotroc(ms,matches,names,params);
if isfield(params,'saveDir')
    exportAndCropFigure(rocPlot.h,'overall.png',params.saveDir);
end

end
%--------------------------------------------------------------------------
function [h,l] = myplotroc(ds,matches,names,params)
    legendEntries = cell(1,length(names));
    
    rocColors = prism(length(names)); %hsv(length(names))
    
    for nameCounter=1:length(names)
        roccolor = rocColors(nameCounter,:);
        if isfield(ds.(names{nameCounter}),'roccolor');
            roccolor = ds.(names{nameCounter}).roccolor;
        end
        
        %plot roc
        if nameCounter==1
            h = icg_plotroc(matches,-ds.(names{nameCounter}).dist);
            hold on; plot(ds.(names{nameCounter}).fpr,ds.(names{nameCounter}).tpr,'Color',roccolor,'LineWidth',2,'LineStyle','-'); hold off;
        else
            hold on; plot(ds.(names{nameCounter}).fpr,ds.(names{nameCounter}).tpr,'Color',roccolor,'LineWidth',2,'LineStyle','-'); hold off;
        end
        legendEntries{nameCounter} = sprintf('%s (%.3f)',upper(names{nameCounter}),ds.(names{nameCounter}).eer);
    end
    grid on;

    ha = get(gca);
    set(get(get(ha.Children(end),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    set(get(get(ha.Children(end-1),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

    l = legend(legendEntries,'Location', 'SouthEast');  
    drawnow;
end
%--------------------------------------------------------------------------

