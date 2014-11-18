function [goOn notProcessedList] = getFileNumbersForAutomatedProcessing(DataDescriptors, guiMode, descriptor)
% GETFILENUMBERSFORAUTOMATEDPROCESSING: Used in octsegMain.
% First checks, if the segmentation (set by the descriptor) has already be
% performed. If yes, the user is asked how to proceed.
% Parameters can be looked up in the octsegMain
% Return values:
% notProcessedList: The filenumbers of the files to process
% goOn: set to 1 if the segmentation should be started.

global PROCESSEDFILES;
global PROCESSEDFILESANSWER;

goOn = 1;
notProcessedList = [];

[status, processedList, notProcessedList] = checkFilesIfProcessed(DataDescriptors, getMetaTag(descriptor, 'auto'));

if status ~= PROCESSEDFILES.NONE
    if guiMode == 2 || guiMode == 3
        answer = processAllQuestion(['Should the ' descriptor ' be automatically segmented on all files or only the remaining ones?']);
        if answer == PROCESSEDFILESANSWER.CANCEL
            goOn = 0;
        elseif answer == PROCESSEDFILESANSWER.ALL
            notProcessedList = 1:numel(DataDescriptors.filenameList);
        elseif answer == PROCESSEDFILESANSWER.REMAINING
        else
            goOn = 0;
        end
    elseif guiMode == 1
        answer = questionText(['The ' descriptor ' will be segmented for ALL BScans again. Previously generated results will be lost!']);
        if answer == PROCESSEDFILESANSWER.CANCEL
            goOn = 0;
            return;
        end
        notProcessedList = 1:DataDescriptors.Header.NumBScans;
    end
end