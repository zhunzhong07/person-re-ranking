function fH = icg_plotroc(targets,outputs)
% ICG_PLOTROC plots receiver operating characteristics
%
% Input:
%   targets - 
%   outputs - 
%
% Output:
%   fH   - handle to the ROC figure
%
% Example:
%   icg_plotroc([ones(1,10) zeros(1,10)],20:-1:1);
%   produces a perfect step curve
%
% copyright by Martin Koestinger (2011)
% Graz University of Technology
% contact koestinger@icg.tugraz.at
%
% For more information, see <a href="matlab: 
% web('http://lrs.icg.tugraz.at/members/koestinger')">the ICG Web site</a>.
%

if nargin < 1
    error('plotroc: Not enough input arguments.');
end

fH = figure;
title('ROC');

ylabel('True Positive Rate (TPR)');
xlabel('False Positive Rate (FPR)');

grid on;
xlim([0 1]);
ylim([0 1]);

set(fH,'name','Receiver Operating Characteristic');
set(fH,'menubar','none','toolbar','none','NumberTitle','off');

screenSize = get(0,'ScreenSize');
screenSize = screenSize(3:4);
windowSize = [800 800];
position = [(screenSize-windowSize)/2 windowSize]; %to center it
set(fH,'position',position);

[tpr,fpr] = icg_roc(targets,outputs);

rocColors = hsv(size(tpr,1)); %hsv(length(names))

hold on; plot([0 1],[0 1],'Color',[0.75 0.75 0.75],'LineWidth',2); hold off;

for c=1:size(tpr,1)
    hold on; plot(fpr(c,:),tpr(c,:),'Color',rocColors(c,:),'LineWidth',2); hold off;
end
drawnow;