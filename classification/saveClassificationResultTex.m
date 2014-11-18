function saveClassificationResultTex(path, Result, FeatureSelection, CrossValidationOptions, additional, description)

% Stores the important tables into a .tex file for direct use in a 
% document and generates an ROC print if available

% Plot rocCurve

if isfield(Result, 'rocCurve')
    rocFigure = figure;
    plot(Result.rocCurve(2,:), Result.rocCurve(1,:),  'Linewidth', 2);
    hold all;
    set(gca,'xlim',[0 1]);
    set(gca,'ylim',[0 1]);
    xlabel('1 - Specificity','fontsize',12,'fontweight','b');
    ylabel('Sensitivity','fontsize',12,'fontweight','b');
    title('ROC curve','fontsize',16,'fontweight','b');
    %legend('Good Quality', 'Bad Quality', 'Location', 'North');
    
    saveas(rocFigure, [path '.png'], 'png');
    saveas(rocFigure, [path '.jpg']);
    close (rocFigure);
end