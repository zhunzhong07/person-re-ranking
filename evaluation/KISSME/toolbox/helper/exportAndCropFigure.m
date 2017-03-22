function exportAndCropFigure(h,name,saveDir)
    if nargin < 3
        return;
    end
    [status,message,messageid] = mkdir(saveDir);
    [status,message,messageid] = mkdir(fullfile(saveDir,'png'));
    [status,message,messageid] = mkdir(fullfile(saveDir,'pdf'));
    [status,message,messageid] = mkdir(fullfile(saveDir,'fig'));
    
    saveas(h,fullfile(saveDir,name));
    saveas(h,fullfile(saveDir,'png',[name '.png']));
    saveas(h,fullfile(saveDir,'fig',[name '.fig']));
    saveas(h,fullfile(saveDir,'pdf',[name '.pdf']));

    %- auto crop pdf -%
    cmdStr = ['pdfcrop.pl' ' ' fullfile(saveDir,'pdf',name)  ... 
    ' ' fullfile(saveDir,'pdf',name)];
    [status, result] = system(cmdStr);

end

