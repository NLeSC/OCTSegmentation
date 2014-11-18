function Params = loadParameters(group, filename)
% PARAMS = loadParameters(GROUP, FILENAME)
% Function to load OCTSEG parameters from a parameter file.
% The parameter file is a text file, that is formated the following way:
% All lines follow the scheme:
% <Parametername><SPACE/TAB><Parametervalues>
% Comments can be made if the parametername is "%". The rest of the line is
% ignored. Extra whitespace lines may be included as one likes.
% PARAMS: The loaded parameter struct. The denominations for the parameters
% within this struct can be best found in the functions that use it.
% GROUP: The parameter group to load. Possibilities are:
%   RPE: Parameters for the automated circular scan RPE segmentation
%   all: Load all parameters (some may be overwritten multiple times. Do
%   use with care or avoid it)
% FILENAME: The filename of the parameter file.
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg
%
% First final Version: November 2010

% Default parameters
if nargin < 1
    group = '';
end
if nargin < 2
    filename = 'octseg.param';
end

fid = fopen([filename], 'r');
if fid == -1
    disp('No Parameter File found.');
    return;
end

Params = [];

% Read the parameter file line by line and search for parameter names.
line = fgetl(fid);
while ischar(line)
    [den data] = strtok(line);
    
    % Load all parameters for the main programm
    if strcmp(group, 'MAIN')
        if numel(den) == 0
        elseif strcmp(den, '%')   
        elseif strcmp(den, 'BINARY_META')
            Params.BINARY_META = str2num(data);   
        elseif strcmp(den, 'DATA_PRIMATE')
            Params.DATA_PRIMATE = str2num(data);   
        end
    end
    
    % Load all parameters for the export programm
    if strcmp(group, 'EXPORT')
        if numel(den) == 0
        elseif strcmp(den, '%')   
        elseif strcmp(den, 'EXPORT_REFLECTION_WIDTH')
            Params.EXPORT_REFLECTION_WIDTH = str2num(data);   
        end
    end
    
    % Load all parameters for the Visualizer
    if strcmp(group, 'VISU')
        if numel(den) == 0
        elseif strcmp(den, '%')
        elseif strcmp(den, 'VISU_ZOOM_WINDOWSIZE')
            Params.VISU_ZOOM_WINDOWSIZE = str2num(data);
        elseif strcmp(den, 'VISU_COLOR_RPEAUTO')
            Params.VISU_COLOR_RPEAUTO = str2num(data);
        elseif strcmp(den, 'VISU_COLOR_RPEMAN')
            Params.VISU_COLOR_RPEMAN = str2num(data);
        elseif strcmp(den, 'VISU_COLOR_INFLAUTO')
            Params.VISU_COLOR_INFLAUTO = str2num(data);
        elseif strcmp(den, 'VISU_COLOR_INFLMAN')
            Params.VISU_COLOR_INFLMAN = str2num(data);
        elseif strcmp(den, 'VISU_COLOR_ICLAUTO')
            Params.VISU_COLOR_ICLAUTO = str2num(data);
        elseif strcmp(den, 'VISU_COLOR_ICLMAN')
            Params.VISU_COLOR_ICLMAN = str2num(data);
        elseif strcmp(den, 'VISU_COLOR_IPLAUTO')
            Params.VISU_COLOR_IPLAUTO = str2num(data);
        elseif strcmp(den, 'VISU_COLOR_IPLMAN')
            Params.VISU_COLOR_IPLMAN = str2num(data);
        elseif strcmp(den, 'VISU_COLOR_OPLAUTO')
            Params.VISU_COLOR_OPLAUTO = str2num(data);
        elseif strcmp(den, 'VISU_COLOR_OPLMAN')
            Params.VISU_COLOR_OPLMAN = str2num(data);
        elseif strcmp(den, 'VISU_COLOR_ONFLAUTO')
            Params.VISU_COLOR_ONFLAUTO = str2num(data);
        elseif strcmp(den, 'VISU_COLOR_ONFLMAN')
            Params.VISU_COLOR_ONFLMAN = str2num(data);
        elseif strcmp(den, 'VISU_COLOR_SKLERAAUTO')
            Params.VISU_COLOR_SKLERAAUTO = str2num(data);
        elseif strcmp(den, 'VISU_COLOR_SKLERAMAN')
            Params.VISU_COLOR_SKLERAMAN = str2num(data);
            
        elseif strcmp(den, 'VISU_COLOR_MEDLINEAUTO')
            Params.VISU_COLOR_MEDLINEAUTO = str2num(data);
        elseif strcmp(den, 'VISU_COLOR_MEDLINEMAN')
            Params.VISU_COLOR_MEDLINEMAN = str2num(data);    
            
        elseif strcmp(den, 'VISU_COLOR_ADDITIONAL1')
            Params.VISU_COLOR_ADDITIONAL1 = str2num(data);
        elseif strcmp(den, 'VISU_COLOR_ADDITIONAL2')
            Params.VISU_COLOR_ADDITIONAL2 = str2num(data);
        elseif strcmp(den, 'VISU_COLOR_BV')
            Params.VISU_COLOR_BV = str2num(data);
        elseif strcmp(den, 'VISU_OPACITY_BV')
            Params.VISU_OPACITY_BV = str2num(data);
        elseif strcmp(den, 'VISU_COLOR_MARKER')
            Params.VISU_COLOR_MARKER = str2num(data);
        elseif strcmp(den, 'VISU_OPACITY_MARKER')
            Params.VISU_OPACITY_MARKER = str2num(data);
        elseif strcmp(den, 'VISU_COLOR_ONH_BOUNDARY')
            Params.VISU_COLOR_ONH_BOUNDARY = str2num(data);
        elseif strcmp(den, 'VISU_OPACITY_ONH_BOUNDARY')
            Params.VISU_OPACITY_ONH_BOUNDARY = str2num(data);
        elseif strcmp(den, 'VISU_ONH_BOUNDARY_WIDTH')
            Params.VISU_ONH_BOUNDARY_WIDTH = str2num(data);   
            
        elseif strcmp(den, 'VISU_MARKER_OCTWIDTH')
            Params.VISU_MARKER_OCTWIDTH = str2num(data);
        elseif strcmp(den, 'VISU_MARKER_SLOWIDTH')
            Params.VISU_MARKER_SLOWIDTH = str2num(data);
                        
        elseif strcmp(den, 'VISU_COLOR_SCANPATTERN')
            Params.VISU_COLOR_SCANPATTERN = str2num(data);
        elseif strcmp(den, 'VISU_COLOR_SCANAREA')
            Params.VISU_COLOR_SCANAREA = str2num(data);
        elseif strcmp(den, 'VISU_COLOR_SCANPOSITION')
            Params.VISU_COLOR_SCANPOSITION = str2num(data);
            
            
        elseif strcmp(den, 'VISU_COLOR_ONHMAP_LOW')
            Params.VISU_COLOR_ONHMAP_LOW = str2num(data);
        elseif strcmp(den, 'VISU_COLOR_ONHMAP_HIGH')
            Params.VISU_COLOR_ONHMAP_HIGH = str2num(data);
        elseif strcmp(den, 'VISU_COLOR_BVMAP_LOW')
            Params.VISU_COLOR_BVMAP_LOW = str2num(data);
        elseif strcmp(den, 'VISU_COLOR_BVMAP_HIGH')
            Params.VISU_COLOR_BVMAP_HIGH = str2num(data);
        elseif strcmp(den, 'VISU_OPACITY_REGIONMAP')
            Params.VISU_OPACITY_REGIONMAP = str2num(data);
            
        elseif strcmp(den, 'VISU_COLOR_RETINAMAP_LOW')
            Params.VISU_COLOR_RETINAMAP_LOW = str2num(data);
        elseif strcmp(den, 'VISU_COLOR_RETINAMAP_MIDDLE')
            Params.VISU_COLOR_RETINAMAP_MIDDLE = str2num(data);
        elseif strcmp(den, 'VISU_COLOR_RETINAMAP_HIGH')
            Params.VISU_COLOR_RETINAMAP_HIGH = str2num(data);
        elseif strcmp(den, 'VISU_RANGE_RETINAMAP')
            Params.VISU_RANGE_RETINAMAP = str2num(data);
        elseif strcmp(den, 'VISU_OPACITY_THICKNESSMAP')
            Params.VISU_OPACITY_THICKNESSMAP = str2num(data);
            
        elseif strcmp(den, 'VISU_COLOR_RNFLMAP_LOW')
            Params.VISU_COLOR_RNFLMAP_LOW = str2num(data);
        elseif strcmp(den, 'VISU_COLOR_RNFLMAP_MIDDLE')
            Params.VISU_COLOR_RNFLMAP_MIDDLE = str2num(data);
        elseif strcmp(den, 'VISU_COLOR_RNFLMAP_HIGH')
            Params.VISU_COLOR_RNFLMAP_HIGH = str2num(data);
        elseif strcmp(den, 'VISU_RANGE_RNFLMAP')
            Params.VISU_RANGE_RNFLMAP = str2num(data);
        end
    end    
    
    % Load all parameters for the manual sklera segmentation
    if strcmp(group, 'SKLERA')
        if numel(den) == 0
        elseif strcmp(den, '%')
        elseif strcmp(den, 'INFL_MEDLINE_SIGMA1')
        elseif strcmp(den, 'SKLERA_ALIGNASCANS_ADDER')
            Params.ALIGNASCANS_ADDER = str2num(data);
        elseif strcmp(den, 'SKLERA_COLOR_SKLERA')
            Params.SKLERA_COLOR_SKLERA = str2num(data);   
        elseif strcmp(den, 'SKLERA_COLOR_POINTS')
            Params.SKLERA_COLOR_POINTS = str2num(data);   
        end
    end
    
    % Load all parameters for the automated ONH segmentation
    if strcmp(group, 'ONH')
        if numel(den) == 0
        elseif strcmp(den, '%')
        elseif strcmp(den, 'ONH_SEGMENT_POLYNUMBER')
            Params.ONH_SEGMENT_POLYNUMBER = str2num(data);
        elseif strcmp(den, 'ONH_SEGMENT_BSCANTHRESHOLD')
            Params.ONH_SEGMENT_BSCANTHRESHOLD = str2num(data);
        elseif strcmp(den, 'ONH_SEGMENT_ENFACETHRESHOLD')
            Params.ONH_SEGMENT_ENFACETHRESHOLD = str2num(data);
        elseif strcmp(den, 'ONH_SEGMENT_MEDFILT')
            Params.ONH_SEGMENT_MEDFILT = str2num(data);
        elseif strcmp(den, 'ONH_SEGMENT_MAXITER')
            Params.ONH_SEGMENT_MAXITER = str2num(data);
        elseif strcmp(den, 'ONH_SEGMENT_ERODENUMBER')
            Params.ONH_SEGMENT_ERODENUMBER = str2num(data);
        elseif strcmp(den, 'ONH_SEGMENT_DILATENUMBER')
            Params.ONH_SEGMENT_DILATENUMBER = str2num(data);
        end
    end
    
    % Load all parameters for the automated Medline segmentation
    if strcmp(group, 'MEDLINECIRC')
        if numel(den) == 0
        elseif strcmp(den, '%')
        elseif strcmp(den, 'MEDLINECIRC_SIGMA1')
            Params.MEDLINE_SIGMA1 = str2num(data);
        elseif strcmp(den, 'MEDLINECIRC_SIGMA2')
            Params.MEDLINE_SIGMA2 = str2num(data);
        elseif strcmp(den, 'MEDLINECIRC_MINDIST')
            Params.MEDLINE_MINDIST = str2num(data);
        elseif strcmp(den, 'MEDLINECIRC_RANSAC_NORM')
            Params.MEDLINE_RANSAC_NORM = str2num(data);
        elseif strcmp(den, 'MEDLINECIRC_RANSAC_MAXITER')
            Params.MEDLINE_RANSAC_MAXITER = str2num(data);
        elseif strcmp(den, 'MEDLINECIRC_RANSAC_POLYNUMBER')
            Params.MEDLINE_RANSAC_POLYNUMBER = str2num(data);
        elseif strcmp(den, 'MEDLINECIRC_LINESWEETER')
            temp = str2num(data);
            Params.MEDLINE_LINESWEETER = reshape(temp, [4 7]);
        end
    end
    
    if strcmp(group, 'MEDLINELIN')
        if numel(den) == 0
        elseif strcmp(den, '%')
        elseif strcmp(den, 'MEDLINELIN_SIGMA1')
            Params.MEDLINE_SIGMA1 = str2num(data);
        elseif strcmp(den, 'MEDLINELIN_SIGMA2')
            Params.MEDLINE_SIGMA2 = str2num(data);
        elseif strcmp(den, 'MEDLINELIN_MINDIST')
            Params.MEDLINE_MINDIST = str2num(data);
        elseif strcmp(den, 'MEDLINELIN_RANSAC_NORM')
            Params.MEDLINE_RANSAC_NORM = str2num(data);
        elseif strcmp(den, 'MEDLINELIN_RANSAC_MAXITER')
            Params.MEDLINE_RANSAC_MAXITER = str2num(data);
        elseif strcmp(den, 'MEDLINELIN_RANSAC_POLYNUMBER')
            Params.MEDLINE_RANSAC_POLYNUMBER = str2num(data);
            
        elseif strcmp(den, 'MEDLINELIN_MERGE_THRESHOLD')
            Params.MEDLINE_MERGE_THRESHOLD = str2num(data);
        elseif strcmp(den, 'MEDLINELIN_MERGE_DILATE')
            Params.MEDLINE_MERGE_DILATE = str2num(data);
        elseif strcmp(den, 'MEDLINELIN_MERGE_BORDER')
            Params.MEDLINE_MERGE_BORDER = str2num(data);
                     
        elseif strcmp(den, 'MEDLINELIN_LINESWEETER')
            temp = str2num(data);
            Params.MEDLINE_LINESWEETER = reshape(temp, [4 7]);
            
        elseif strcmp(den, 'MEDLINEVOL_MEDFILT')
            Params.MEDLINEVOL_MEDFILT = str2num(data);
        end
    end
    
    
    % Load all parameters for the automated RPE segmentation
    if strcmp(group, 'RPECIRC')
        if numel(den) == 0
        elseif strcmp(den, '%')
        elseif strcmp(den, 'RPECIRC_MEDLINE_SIGMA1')
            Params.MEDLINE_SIGMA1 = str2num(data);
        elseif strcmp(den, 'RPECIRC_MEDLINE_SIGMA2')
            Params.MEDLINE_SIGMA2 = str2num(data);
        elseif strcmp(den, 'RPECIRC_MEDLINE_MINDIST')
            Params.MEDLINE_MINDIST = str2num(data);
        elseif strcmp(den, 'RPECIRC_MEDLINE_LINESWEETER')
            temp = str2num(data);
            Params.MEDLINE_LINESWEETER = reshape(temp, [4 7]);
        elseif strcmp(den, 'RPECIRC_SPLITNORMALIZE_CUTOFF')
            Params.SPLITNORMALIZE_CUTOFF = str2num(data);
        elseif strcmp(den, 'RPECIRC_SPLITNORMALIZE_LINESWEETER')
            temp = str2num(data);
            Params.SPLITNORMALIZE_LINESWEETER = reshape(temp, [4 7]);
        elseif strcmp(den, 'RPECIRC_REMOVEBIAS_REGIONWIDTH')
            Params.REMOVEBIAS_REGIONWIDTH = str2num(data);
        elseif strcmp(den, 'RPECIRC_REMOVEBIAS_FRACTION')
            Params.REMOVEBIAS_FRACTION = str2num(data);
        elseif strcmp(den, 'RPECIRC_FINDRETINAEXTREMA_SIGMA_GRADIENT')
            Params.FINDRETINAEXTREMA_SIGMA_GRADIENT = str2num(data);
        elseif strcmp(den, 'RPECIRC_FINDRETINAEXTREMA_SIGMA_FZ')
            Params.FINDRETINAEXTREMA_SIGMA_FZ = str2num(data);
        elseif strcmp(den, 'RPECIRC_FINDBLOODVESSELS_WINDOWWIDTH')
            Params.FINDBLOODVESSELS_WINDOWWIDTH = str2num(data);
        elseif strcmp(den, 'RPECIRC_FINDBLOODVESSELS_WINDOWHEIGHT')
            Params.FINDBLOODVESSELS_WINDOWHEIGHT = str2num(data);
        elseif strcmp(den, 'RPECIRC_FINDBLOODVESSELS_THRESHOLD')
            Params.FINDBLOODVESSELS_THRESHOLD = str2num(data);
        elseif strcmp(den, 'RPECIRC_FINDBLOODVESSELS_FREEWIDTH')
            Params.FINDBLOODVESSELS_FREEWIDTH = str2num(data);
        elseif strcmp(den, 'RPECIRC_FINDBLOODVESSELS_MULTWIDTH')
            Params.FINDBLOODVESSELS_MULTWIDTH = str2num(data);
        elseif strcmp(den, 'RPECIRC_FINDBLOODVESSELS_MULTWIDTHTHRESH')
            Params.FINDBLOODVESSELS_MULTWIDTHTHRESH = str2num(data);
        elseif strcmp(den, 'RPECIRC_SEGMENT_MEDFILT1')
            Params.RPECIRC_SEGMENT_MEDFILT1 = str2num(data);
        elseif strcmp(den, 'RPECIRC_SEGMENT_MEDFILT2')
            Params.RPECIRC_SEGMENT_MEDFILT2 = str2num(data);
        elseif strcmp(den, 'RPECIRC_SEGMENT_POLYDIST')
            Params.RPECIRC_SEGMENT_POLYDIST = str2num(data);
        elseif strcmp(den, 'RPECIRC_SEGMENT_POLYNUMBER')
            Params.RPECIRC_SEGMENT_POLYNUMBER = str2num(data);
        elseif strcmp(den, 'RPECIRC_SEGMENT_LINESWEETER1')
            temp = str2num(data);
            Params.RPECIRC_SEGMENT_LINESWEETER1 = reshape(temp, [4 7]);
        elseif strcmp(den, 'RPECIRC_SEGMENT_LINESWEETER2')
            temp = str2num(data);
            Params.RPECIRC_SEGMENT_LINESWEETER2 = reshape(temp, [4 7]);
         elseif strcmp(den, 'RPECIRC_LINEAR_LINESWEETER_SIMPLE')
             temp = str2num(data);
            Params.RPECIRC_LINEAR_LINESWEETER_SIMPLE = reshape(temp, [4 7]);
        end
    end
    
    
    if strcmp(group, 'RPELIN')
        if numel(den) == 0
        elseif strcmp(den, '%')
        elseif strcmp(den, 'RPELIN_MEDLINE_SIGMA1')
            Params.MEDLINE_SIGMA1 = str2num(data);
        elseif strcmp(den, 'RPELIN_MEDLINE_SIGMA2')
            Params.MEDLINE_SIGMA2 = str2num(data);
        elseif strcmp(den, 'RPELIN_MEDLINE_MINDIST')
            Params.MEDLINE_MINDIST = str2num(data);
        elseif strcmp(den, 'RPELIN_MEDLINE_MINDISTBELOW')
            Params.RPELIN_MEDLINE_MINDISTBELOW = str2num(data);
        elseif strcmp(den, 'RPELIN_MEDLINE_LINESWEETER')
            temp = str2num(data);
            Params.MEDLINE_LINESWEETER = reshape(temp, [4 7]);
        elseif strcmp(den, 'RPELIN_SPLITNORMALIZE_CUTOFF')
            Params.SPLITNORMALIZE_CUTOFF = str2num(data);
        elseif strcmp(den, 'RPELIN_SPLITNORMALIZE_LINESWEETER')
            temp = str2num(data);
            Params.SPLITNORMALIZE_LINESWEETER = reshape(temp, [4 7]);
        elseif strcmp(den, 'RPELIN_REMOVEBIAS_REGIONWIDTH')
            Params.REMOVEBIAS_REGIONWIDTH = str2num(data);
        elseif strcmp(den, 'RPELIN_REMOVEBIAS_FRACTION')
            Params.REMOVEBIAS_FRACTION = str2num(data);
        elseif strcmp(den, 'RPELIN_FINDRETINAEXTREMA_SIGMA_GRADIENT')
            Params.FINDRETINAEXTREMA_SIGMA_GRADIENT = str2num(data);
        elseif strcmp(den, 'RPELIN_FINDRETINAEXTREMA_SIGMA_FZ')
            Params.FINDRETINAEXTREMA_SIGMA_FZ = str2num(data);
        elseif strcmp(den, 'RPELIN_FINDBLOODVESSELS_WINDOWWIDTH')
            Params.FINDBLOODVESSELS_WINDOWWIDTH = str2num(data);
        elseif strcmp(den, 'RPELIN_FINDBLOODVESSELS_WINDOWHEIGHT')
            Params.FINDBLOODVESSELS_WINDOWHEIGHT = str2num(data);
        elseif strcmp(den, 'RPELIN_FINDBLOODVESSELS_THRESHOLD')
            Params.FINDBLOODVESSELS_THRESHOLD = str2num(data);
        elseif strcmp(den, 'RPELIN_FINDBLOODVESSELS_FREEWIDTH')
            Params.FINDBLOODVESSELS_FREEWIDTH = str2num(data);
        elseif strcmp(den, 'RPELIN_FINDBLOODVESSELS_MULTWIDTH')
            Params.FINDBLOODVESSELS_MULTWIDTH = str2num(data);
        elseif strcmp(den, 'RPELIN_FINDBLOODVESSELS_MULTWIDTHTHRESH')
            Params.FINDBLOODVESSELS_MULTWIDTHTHRESH = str2num(data);
        elseif strcmp(den, 'RPELIN_SEGMENT_MEDFILT')
            Params.RPELIN_SEGMENT_MEDFILT = str2num(data);
            
        elseif strcmp(den, 'RPELIN_RANSAC_POLYNUMBER')
            Params.RPELIN_RANSAC_POLYNUMBER = str2num(data);
        elseif strcmp(den, 'RPELIN_RANSAC_POLYNUMBER_MEDLINE')
            Params.RPELIN_RANSAC_POLYNUMBER_MEDLINE = str2num(data);
        elseif strcmp(den, 'RPELIN_RANSAC_MAXITER')
            Params.RPELIN_RANSAC_MAXITER = str2num(data);
        elseif strcmp(den, 'RPELIN_RANSAC_NORM_MEDLINE')
            Params.RPELIN_RANSAC_NORM_MEDLINE = str2num(data);
        elseif strcmp(den, 'RPELIN_RANSAC_NORM_RPE')
            Params.RPELIN_RANSAC_NORM_RPE = str2num(data);   
            
        elseif strcmp(den, 'RPELIN_MERGE_DILATE')
            Params.RPELIN_MERGE_DILATE = str2num(data);
        elseif strcmp(den, 'RPELIN_MERGE_BORDER')
            Params.RPELIN_MERGE_BORDER = str2num(data);
        elseif strcmp(den, 'RPELIN_MERGE_THRESHOLD')
            Params.RPELIN_MERGE_THRESHOLD = str2num(data);
            
        elseif strcmp(den, 'RPELIN_LINESWEETER_FINAL')
            temp = str2num(data);
            Params.RPELIN_LINESWEETER_FINAL = reshape(temp, [4 7]);
        elseif strcmp(den, 'RPELIN_LINESWEETER_SIMPLE')
            temp = str2num(data);
            Params.RPELIN_LINESWEETER_SIMPLE = reshape(temp, [4 7]);
            
        elseif strcmp(den, 'RPELIN_VOLUME_MASK')
            Params.RPELIN_VOLUME_MASK = str2num(data);            
        elseif strcmp(den, 'RPELIN_VOLUME_MEDFILT')
            Params.RPELIN_VOLUME_MEDFILT = str2num(data);
        end
    end
    
    
    % Load all parameters for the automated BV segmentation
    if strcmp(group, 'BV')
        if numel(den) == 0
        elseif strcmp(den, '%')
        elseif strcmp(den, 'BV_FINDBLOODVESSELS_WINDOWWIDTH')
            Params.FINDBLOODVESSELS_WINDOWWIDTH = str2num(data);
        elseif strcmp(den, 'BV_FINDBLOODVESSELS_WINDOWHEIGHT')
            Params.FINDBLOODVESSELS_WINDOWHEIGHT = str2num(data);
        elseif strcmp(den, 'BV_FINDBLOODVESSELS_THRESHOLD')
            Params.FINDBLOODVESSELS_THRESHOLD = str2num(data);
        elseif strcmp(den, 'BV_FINDBLOODVESSELS_FREEWIDTH')
            Params.FINDBLOODVESSELS_FREEWIDTH = str2num(data);
        elseif strcmp(den, 'BV_FINDBLOODVESSELS_MULTWIDTH')
            Params.FINDBLOODVESSELS_MULTWIDTH = str2num(data);
        elseif strcmp(den, 'BV_FINDBLOODVESSELS_MULTWIDTHTHRESH')
            Params.FINDBLOODVESSELS_MULTWIDTHTHRESH = str2num(data);
        end
    end
    
    % Load all parameters for the automated INFL segmentation
    if strcmp(group, 'INFL')
        if numel(den) == 0
        elseif strcmp(den, '%')
        elseif strcmp(den, 'INFL_MEDLINE_SIGMA1')
            Params.MEDLINE_SIGMA1 = str2num(data);
        elseif strcmp(den, 'INFL_MEDLINE_SIGMA2')
            Params.MEDLINE_SIGMA2 = str2num(data);
        elseif strcmp(den, 'INFL_MEDLINE_MINDIST')
            Params.MEDLINE_MINDIST = str2num(data);
        elseif strcmp(den, 'INFL_MEDLINE_MINDISTABOVE')
            Params.INFL_MEDLINE_MINDISTABOVE = str2num(data);
        elseif strcmp(den, 'INFL_MEDLINE_LINESWEETER')
            temp = str2num(data);
            Params.MEDLINE_LINESWEETER = reshape(temp, [4 7]);
        elseif strcmp(den, 'INFL_SPLITNORMALIZE_CUTOFF')
            Params.SPLITNORMALIZE_CUTOFF = str2num(data);
        elseif strcmp(den, 'INFL_SPLITNORMALIZE_LINESWEETER')
            temp = str2num(data);
            Params.SPLITNORMALIZE_LINESWEETER = reshape(temp, [4 7]);
        elseif strcmp(den, 'INFL_FINDRETINAEXTREMA_SIGMA_GRADIENT')
            Params.FINDRETINAEXTREMA_SIGMA_GRADIENT = str2num(data);
        elseif strcmp(den, 'INFL_ALIGNASCANS_ADDER')
            Params.ALIGNASCANS_ADDER = str2num(data);
        elseif strcmp(den, 'INFL_FINDRETINAEXTREMA_SIGMA_FZ')
            Params.FINDRETINAEXTREMA_SIGMA_FZ = str2num(data);
        elseif strcmp(den, 'INFL_SEGMENT_LINESWEETER_MEDLINE')
            temp = str2num(data);
            Params.INFL_SEGMENT_LINESWEETER_MEDLINE = reshape(temp, [4 7]);
        elseif strcmp(den, 'INFL_SEGMENT_LINESWEETER_FINAL')
            temp = str2num(data);
            Params.INFL_SEGMENT_LINESWEETER_FINAL = reshape(temp, [4 7]);
            
        elseif strcmp(den, 'INFLLIN_RANSAC_NORM_MEDLINE')
            Params.INFLLIN_RANSAC_NORM_MEDLINE = str2num(data);
        elseif strcmp(den, 'INFLLIN_RANSAC_MAXITER')
            Params.INFLLIN_RANSAC_MAXITER = str2num(data);
        elseif strcmp(den, 'INFLLIN_RANSAC_POLYNUMBER_MEDLINE')
            Params.INFLLIN_RANSAC_POLYNUMBER_MEDLINE = str2num(data);
            
        elseif strcmp(den, 'INFL_LINEAR_LINESWEETER_FINALSIMPLE')
            temp = str2num(data);
            Params.INFL_LINEAR_LINESWEETER_FINALSIMPLE = reshape(temp, [4 7]);
            
        elseif strcmp(den, 'INFL_VOLUME_LINESWEETER')
            temp = str2num(data);
            Params.INFL_VOLUME_LINESWEETER = reshape(temp, [4 7]);
        elseif strcmp(den, 'INFLLIN_VOLUME_MEDFILT')
            Params.INFLLIN_VOLUME_MEDFILT = str2num(data);
        elseif strcmp(den, 'INFLLIN_VOLUME_MASK')
            Params.INFLLIN_VOLUME_MASK = str2num(data);
        end
    end
    
    
    % Load all parameters for the automated inner layer segmentation
    if strcmp(group, 'InnerCirc')
        if numel(den) == 0
        elseif strcmp(den, '%')
        elseif strcmp(den, 'INNERCIRC_ALIGNASCANS_ADDER')
            Params.ALIGNASCANS_ADDER = str2num(data);
        elseif strcmp(den, 'INNERCIRC_SEGMENT_MIRRORWIDTH')
            Params.INNERCIRC_SEGMENT_MIRRORWIDTH = str2num(data);
        elseif strcmp(den, 'INNERCIRC_SEGMENT_RPEDILATE')
            Params.INNERCIRC_SEGMENT_RPEDILATE = str2num(data);       
        elseif strcmp(den, 'INNERCIRC_MEDLINE_SIGMA1')
            Params.MEDLINE_SIGMA1 = str2num(data);
        elseif strcmp(den, 'INNERCIRC_MEDLINE_SIGMA2')
            Params.MEDLINE_SIGMA2 = str2num(data);
        elseif strcmp(den, 'INNERCIRC_MEDLINE_MINDIST')
            Params.MEDLINE_MINDIST = str2num(data);
        elseif strcmp(den, 'INNERCIRC_MEDLINE_LINESWEETER')
            temp = str2num(data);
            Params.MEDLINE_LINESWEETER = reshape(temp, [4 7]);
        elseif strcmp(den, 'INNERCIRC_SPLITNORMALIZE_CUTOFF')
            Params.SPLITNORMALIZE_CUTOFF = str2num(data);
        elseif strcmp(den, 'INNERCIRC_SPLITNORMALIZE_LINESWEETER')
            temp = str2num(data);
            Params.SPLITNORMALIZE_LINESWEETER = reshape(temp, [4 7]);
        elseif strcmp(den, 'INNERCIRC_SEGMENT_LINESWEETER_MEDLINE')
            temp = str2num(data);
            Params.INNERCIRC_SEGMENT_LINESWEETER_MEDLINE = reshape(temp, [4 7]);
        elseif strcmp(den, 'INNERCIRC_SEGMENT_AVERAGEWIDTH')
            Params.INNERCIRC_SEGMENT_AVERAGEWIDTH = str2num(data);
        elseif strcmp(den, 'INNERCIRC_FINDRETINAEXTREMA_SIGMA_GRADIENT')
            Params.FINDRETINAEXTREMA_SIGMA_GRADIENT = str2num(data);
        elseif strcmp(den, 'INNERCIRC_FINDRETINAEXTREMA_SIGMA_FZ')
            Params.FINDRETINAEXTREMA_SIGMA_FZ = str2num(data);
            
        elseif strcmp(den, 'INNERCIRC_EXTENDBLOODVESSELS_ADDWIDTH')
            Params.INNERCIRC_EXTENDBLOODVESSELS_ADDWIDTH = str2num(data);
        elseif strcmp(den, 'INNERCIRC_EXTENDBLOODVESSELS_MULTWIDTH')
            Params.INNERCIRC_EXTENDBLOODVESSELS_MULTWIDTH = str2num(data);
        elseif strcmp(den, 'INNERCIRC_EXTENDBLOODVESSELS_MULTWIDTHTHRESH')
            Params.INNERCIRC_EXTENDBLOODVESSELS_MULTWIDTHTHRESH = str2num(data);
            
        elseif strcmp(den, 'INNERCIRC_SEGMENT_MINDIST_RPE_ICL')
            Params.INNERCIRC_SEGMENT_MINDIST_RPE_ICL = str2num(data);               
        elseif strcmp(den, 'INNERCIRC_SEGMENT_MINDIST_ICL_OPL')
            Params.INNERCIRC_SEGMENT_MINDIST_ICL_OPL = str2num(data);
        elseif strcmp(den, 'INNERCIRC_SEGMENT_MINDIST_OPL_IPL')
            Params.INNERCIRC_SEGMENT_MINDIST_OPL_IPL = str2num(data);
        elseif strcmp(den, 'INNERCIRC_SEGMENT_RPEWINDOW_ICL')
            Params.INNERCIRC_SEGMENT_RPEWINDOW_ICL = str2num(data);
        elseif strcmp(den, 'INNERCIRC_SEGMENT_RPEWINDOW_IPL')
            Params.INNERCIRC_SEGMENT_RPEWINDOW_IPL = str2num(data);
        elseif strcmp(den, 'INNERCIRC_SEGMENT_RPEWINDOW_OPL')
            Params.INNERCIRC_SEGMENT_RPEWINDOW_OPL = str2num(data);
        elseif strcmp(den, 'INNERCIRC_SEGMENT_RPECONSTRANGE_ICL')
            Params.INNERCIRC_SEGMENT_RPECONSTRANGE_ICL = str2num(data);   
        elseif strcmp(den, 'INNERCIRC_SEGMENT_RPECONSTRANGE_OPL')
            Params.INNERCIRC_SEGMENT_RPECONSTRANGE_OPL = str2num(data);       
        elseif strcmp(den, 'INNERCIRC_SEGMENT_RPECONSTRANGE_IPL')
            Params.INNERCIRC_SEGMENT_RPECONSTRANGE_IPL = str2num(data);    
        elseif strcmp(den, 'INNERCIRC_SEGMENT_RPESORTPART')
            Params.INNERCIRC_SEGMENT_RPESORTPART = str2num(data);
        elseif strcmp(den, 'INNERCIRC_SEGMENT_RPEDILATE')
            Params.INNERCIRC_SEGMENT_RPEDILATE = str2num(data);       
        elseif strcmp(den, 'INNERCIRC_SEGMENT_LINESWEETER_ICL')
            temp = str2num(data);
            Params.INNERCIRC_SEGMENT_LINESWEETER_ICL = reshape(temp, [4 7]);
        elseif strcmp(den, 'INNERCIRC_SEGMENT_LINESWEETER_IPL')
            temp = str2num(data);
            Params.INNERCIRC_SEGMENT_LINESWEETER_IPL = reshape(temp, [4 7]);
        elseif strcmp(den, 'INNERCIRC_SEGMENT_LINESWEETER_OPL')
            temp = str2num(data);
            Params.INNERCIRC_SEGMENT_LINESWEETER_OPL = reshape(temp, [4 7]);
        end
    end
    
    
    if strcmp(group, 'InnerLin')
        if numel(den) == 0
        elseif strcmp(den, '%')
        elseif strcmp(den, 'INNERLIN_ALIGNASCANS_ADDER')
            Params.ALIGNASCANS_ADDER = str2num(data);
        elseif strcmp(den, 'INNERLIN_SEGMENT_MIRRORWIDTH')
            Params.INNERLIN_SEGMENT_MIRRORWIDTH = str2num(data);
        elseif strcmp(den, 'INNERLIN_SEGMENT_RPEDILATE')
            Params.INNERLIN_SEGMENT_RPEDILATE = str2num(data);
        elseif strcmp(den, 'INNERLIN_MEDLINE_SIGMA1')
            Params.MEDLINE_SIGMA1 = str2num(data);
        elseif strcmp(den, 'INNERLIN_MEDLINE_SIGMA2')
            Params.MEDLINE_SIGMA2 = str2num(data);
        elseif strcmp(den, 'INNERLIN_MEDLINE_MINDIST')
            Params.MEDLINE_MINDIST = str2num(data);
        elseif strcmp(den, 'INNERLIN_MEDLINE_LINESWEETER')
            temp = str2num(data);
            Params.MEDLINE_LINESWEETER = reshape(temp, [4 7]);
            
            
        elseif strcmp(den, 'INNERLIN_RANSAC_POLYNUMBER_MEDLINE')
            Params.INNERLIN_RANSAC_POLYNUMBER_MEDLINE = str2num(data);
        elseif strcmp(den, 'INNERLIN_RANSAC_POLYNUMBER_BOUNDARIES')
            Params.INNERLIN_RANSAC_POLYNUMBER_BOUNDARIES = str2num(data);
        elseif strcmp(den, 'INNERLIN_RANSAC_MAXITER')
            Params.INNERLIN_RANSAC_MAXITER = str2num(data);
        elseif strcmp(den, 'INNERLIN_RANSAC_NORM_MEDLINE')
            Params.INNERLIN_RANSAC_NORM_MEDLINE = str2num(data);
        elseif strcmp(den, 'INNERLIN_RANSAC_NORM_BOUNDARIES')
            Params.INNERLIN_RANSAC_NORM_BOUNDARIES = str2num(data);
            
        elseif strcmp(den, 'INNERLIN_MERGE_DILATE')
            Params.INNERLIN_MERGE_DILATE = str2num(data);
        elseif strcmp(den, 'INNERLIN_MERGE_BORDER')
            Params.INNERLIN_MERGE_BORDER = str2num(data);
        elseif strcmp(den, 'INNERLIN_MERGE_THRESHOLD')
            Params.INNERLIN_MERGE_THRESHOLD = str2num(data);
        elseif strcmp(den, 'INNERLIN_DISCARD_THRESHOLD')
            
        elseif strcmp(den, 'INNERLIN_SPLITNORMALIZE_CUTOFF')
            Params.SPLITNORMALIZE_CUTOFF = str2num(data);
        elseif strcmp(den, 'INNERLIN_SPLITNORMALIZE_LINESWEETER')
            temp = str2num(data);
            Params.SPLITNORMALIZE_LINESWEETER = reshape(temp, [4 7]);
        elseif strcmp(den, 'INNERLIN_SEGMENT_LINESWEETER_MEDLINE')
            temp = str2num(data);
            Params.INNERLIN_SEGMENT_LINESWEETER_MEDLINE = reshape(temp, [4 7]);
        elseif strcmp(den, 'INNERLIN_SEGMENT_AVERAGEWIDTH')
            Params.INNERLIN_SEGMENT_AVERAGEWIDTH = str2num(data);
        elseif strcmp(den, 'INNERLIN_FINDRETINAEXTREMA_SIGMA_GRADIENT')
            Params.FINDRETINAEXTREMA_SIGMA_GRADIENT = str2num(data);
        elseif strcmp(den, 'INNERLIN_FINDRETINAEXTREMA_SIGMA_FZ')
            Params.FINDRETINAEXTREMA_SIGMA_FZ = str2num(data);
            
        elseif strcmp(den, 'INNERLIN_EXTENDBLOODVESSELS_ADDWIDTH')
            Params.INNERLIN_EXTENDBLOODVESSELS_ADDWIDTH = str2num(data);
        elseif strcmp(den, 'INNERLIN_EXTENDBLOODVESSELS_MULTWIDTH')
            Params.INNERLIN_EXTENDBLOODVESSELS_MULTWIDTH = str2num(data);
        elseif strcmp(den, 'INNERLIN_EXTENDBLOODVESSELS_MULTWIDTHTHRESH')
            Params.INNERLIN_EXTENDBLOODVESSELS_MULTWIDTHTHRESH = str2num(data);
            
        elseif strcmp(den, 'INNERLIN_SEGMENT_MINDIST_RPE_ICL')
            Params.INNERLIN_SEGMENT_MINDIST_RPE_ICL = str2num(data);               
        elseif strcmp(den, 'INNERLIN_SEGMENT_MINDIST_ICL_OPL')
            Params.INNERLIN_SEGMENT_MINDIST_ICL_OPL = str2num(data);
        elseif strcmp(den, 'INNERLIN_SEGMENT_MINDIST_OPL_IPL')
            Params.INNERLIN_SEGMENT_MINDIST_OPL_IPL = str2num(data);
        elseif strcmp(den, 'INNERLIN_SEGMENT_RPEWINDOW_ICL')
            Params.INNERLIN_SEGMENT_RPEWINDOW_ICL = str2num(data);
        elseif strcmp(den, 'INNERLIN_SEGMENT_RPEWINDOW_IPL')
            Params.INNERLIN_SEGMENT_RPEWINDOW_IPL = str2num(data);
        elseif strcmp(den, 'INNERLIN_SEGMENT_RPEWINDOW_OPL')
            Params.INNERLIN_SEGMENT_RPEWINDOW_OPL = str2num(data);
        elseif strcmp(den, 'INNERLIN_SEGMENT_RPECONSTRANGE_ICL')
            Params.INNERLIN_SEGMENT_RPECONSTRANGE_ICL = str2num(data);   
        elseif strcmp(den, 'INNERLIN_SEGMENT_RPECONSTRANGE_OPL')
            Params.INNERLIN_SEGMENT_RPECONSTRANGE_OPL = str2num(data);       
        elseif strcmp(den, 'INNERLIN_SEGMENT_RPECONSTRANGE_IPL')
            Params.INNERLIN_SEGMENT_RPECONSTRANGE_IPL = str2num(data);    
        elseif strcmp(den, 'INNERLIN_SEGMENT_RPESORTPART')
            Params.INNERLIN_SEGMENT_RPESORTPART = str2num(data);
        elseif strcmp(den, 'INNERLIN_SEGMENT_RPEDILATE')
            Params.INNERLIN_SEGMENT_RPEDILATE = str2num(data);       
        elseif strcmp(den, 'INNERLIN_SEGMENT_LINESWEETER_ICL')
            temp = str2num(data);
            Params.INNERLIN_SEGMENT_LINESWEETER_ICL = reshape(temp, [4 7]);
        elseif strcmp(den, 'INNERLIN_SEGMENT_LINESWEETER_IPL')
            temp = str2num(data);
            Params.INNERLIN_SEGMENT_LINESWEETER_IPL = reshape(temp, [4 7]);
        elseif strcmp(den, 'INNERLIN_SEGMENT_LINESWEETER_OPL')
            temp = str2num(data);
            Params.INNERLIN_SEGMENT_LINESWEETER_OPL = reshape(temp, [4 7]);
        elseif strcmp(den, 'INNERLIN_VOLUME_MASK')
            Params.INNERLIN_VOLUME_MASK = str2num(data);
        elseif strcmp(den, 'INNERLIN_VOLUME_MEDFILT')
            Params.INNERLIN_VOLUME_MEDFILT = str2num(data);
        end
    end
    
    % Load all parameters for the automated ONFL segmentation
    if strcmp(group, 'ONFLCIRC')
        if numel(den) == 0
        elseif strcmp(den, '%')
        elseif strcmp(den, 'ONFLCIRC_ALIGNASCANS_ADDER')
            Params.ALIGNASCANS_ADDER = str2num(data);
        elseif strcmp(den, 'ONFLCIRC_SEGMENT_MIRRORWIDTH')
            Params.ONFLCIRC_SEGMENT_MIRRORWIDTH = str2num(data);
        elseif strcmp(den, 'ONFLCIRC_SEGMENT_NOISEESTIMATE_MEDIAN')
            Params.ONFLCIRC_SEGMENT_NOISEESTIMATE_MEDIAN = str2num(data);
        elseif strcmp(den, 'ONFLCIRC_SEGMENT_DENOISEPM_SIGMAMULT')
            Params.ONFLCIRC_SEGMENT_DENOISEPM_SIGMAMULT = str2num(data);
        elseif strcmp(den, 'ONFLCIRC_DENOISEPM_TIME')
            Params.DENOISEPM_TIME = str2num(data);
        elseif strcmp(den, 'ONFLCIRC_DENOISEPM_SMOOTH')
            Params.DENOISEPM_SMOOTH = str2num(data);
        elseif strcmp(den, 'ONFLCIRC_DENOISEPM_MAXITER')
            Params.DENOISEPM_MAXITER = str2num(data);
        elseif strcmp(den, 'ONFLCIRC_FINDRETINAEXTREMA_SIGMA_GRADIENT')
            Params.FINDRETINAEXTREMA_SIGMA_GRADIENT = str2num(data);
        elseif strcmp(den, 'ONFLCIRC_FINDRETINAEXTREMA_SIGMA_FZ')
            Params.FINDRETINAEXTREMA_SIGMA_FZ = str2num(data);
        elseif strcmp(den, 'ONFLCIRC_SEGMENT_LINESWEETER_INIT_INTERPOLATE')
            temp = str2num(data);
            Params.ONFLCIRC_SEGMENT_LINESWEETER_INIT_INTERPOLATE = reshape(temp, [4 7]);

        elseif strcmp(den, 'ONFLCIRC_EXTENDBLOODVESSELS_ADDWIDTH')
            Params.ONFLCIRC_EXTENDBLOODVESSELS_ADDWIDTH = str2num(data);
        elseif strcmp(den, 'ONFLCIRC_EXTENDBLOODVESSELS_MULTWIDTH')
            Params.ONFLCIRC_EXTENDBLOODVESSELS_MULTWIDTH = str2num(data);
        elseif strcmp(den, 'ONFLCIRC_EXTENDBLOODVESSELS_MULTWIDTHTHRESH')
            Params.ONFLCIRC_EXTENDBLOODVESSELS_MULTWIDTHTHRESH = str2num(data);

        elseif strcmp(den, 'ONFLCIRC_EXTENDBLOODVESSELS_ADDWIDTH_EN')
            Params.ONFLCIRC_EXTENDBLOODVESSELS_ADDWIDTH_EN = str2num(data);
        elseif strcmp(den, 'ONFLCIRC_EXTENDBLOODVESSELS_MULTWIDTH_EN')
            Params.ONFLCIRC_EXTENDBLOODVESSELS_MULTWIDTH_EN = str2num(data);
        elseif strcmp(den, 'ONFLCIRC_EXTENDBLOODVESSELS_MULTWIDTHTHRESH_EN')
            Params.ONFLCIRC_EXTENDBLOODVESSELS_MULTWIDTHTHRESH_EN = str2num(data);
        elseif strcmp(den, 'ONFLCIRC_ENERGYSMOOTH_GRADIENTWEIGHT')
            Params.ENERGYSMOOTH_GRADIENTWEIGHT = str2num(data);
        elseif strcmp(den, 'ONFLCIRC_ENERGYSMOOTH_NEIGHBORWEIGHT')
            Params.ENERGYSMOOTH_NEIGHBORWEIGHT = str2num(data);
        elseif strcmp(den, 'ONFLCIRC_ENERGYSMOOTH_REGIONWEIGHT')
            Params.ENERGYSMOOTH_REGIONWEIGHT = str2num(data);
        elseif strcmp(den, 'ONFLCIRC_ENERGYSMOOTH_MAXITER')
            Params.ENERGYSMOOTH_MAXITER = str2num(data);
        elseif strcmp(den, 'ONFLCIRC_SEGMENT_MINDIST_IPL_ONFL')
            Params.ONFLCIRC_SEGMENT_MINDIST_IPL_ONFL = str2num(data);
        elseif strcmp(den, 'ONFLCIRC_SEGMENT_LINESWEETER_FINAL')
            temp = str2num(data);
            Params.ONFLCIRC_SEGMENT_LINESWEETER_FINAL = reshape(temp, [4 7]);
        end
    end
    
    
     if strcmp(group, 'ONFLLIN')
        if numel(den) == 0
        elseif strcmp(den, '%')
        elseif strcmp(den, 'ONFLLIN_ALIGNASCANS_ADDER')
            Params.ALIGNASCANS_ADDER = str2num(data);
        elseif strcmp(den, 'ONFLLIN_SEGMENT_NOISEESTIMATE_MEDIAN')
            Params.ONFLLIN_SEGMENT_NOISEESTIMATE_MEDIAN = str2num(data);
        elseif strcmp(den, 'ONFLLIN_SEGMENT_DENOISEPM_SIGMAMULT')
            Params.ONFLLIN_SEGMENT_DENOISEPM_SIGMAMULT = str2num(data);
        elseif strcmp(den, 'ONFLLIN_DENOISEPM_TIME')
            Params.DENOISEPM_TIME = str2num(data);
        elseif strcmp(den, 'ONFLLIN_DENOISEPM_SMOOTH')
            Params.DENOISEPM_SMOOTH = str2num(data);
        elseif strcmp(den, 'ONFLLIN_DENOISEPM_MAXITER')
            Params.DENOISEPM_MAXITER = str2num(data);
        elseif strcmp(den, 'ONFLLIN_FINDRETINAEXTREMA_SIGMA_GRADIENT')
            Params.FINDRETINAEXTREMA_SIGMA_GRADIENT = str2num(data);
        elseif strcmp(den, 'ONFLLIN_FINDRETINAEXTREMA_SIGMA_FZ')
            Params.FINDRETINAEXTREMA_SIGMA_FZ = str2num(data);
        elseif strcmp(den, 'ONFLLIN_SEGMENT_LINESWEETER_INIT_INTERPOLATE')
            temp = str2num(data);
            Params.ONFLLIN_SEGMENT_LINESWEETER_INIT_INTERPOLATE = reshape(temp, [4 7]);
        elseif strcmp(den, 'ONFLLIN_SEGMENT_LINESWEETER_INIT_SMOOTH')
            temp = str2num(data);
            Params.ONFLLIN_SEGMENT_LINESWEETER_INIT_SMOOTH = reshape(temp, [4 7]);

        elseif strcmp(den, 'ONFLLIN_EXTENDBLOODVESSELS_ADDWIDTH_ALL')
            Params.ONFLLIN_EXTENDBLOODVESSELS_ADDWIDTH_ALL = str2num(data);
        elseif strcmp(den, 'ONFLLIN_EXTENDBLOODVESSELS_MULTWIDTH_ALL')
            Params.ONFLLIN_EXTENDBLOODVESSELS_MULTWIDTH_ALL = str2num(data);
        elseif strcmp(den, 'ONFLLIN_EXTENDBLOODVESSELS_MULTWIDTHTHRESH_ALL')
            Params.ONFLLIN_EXTENDBLOODVESSELS_MULTWIDTHTHRESH_ALL = str2num(data);

        elseif strcmp(den, 'ONFLLIN_EXTENDBLOODVESSELS_ADDWIDTH_EN')
            Params.ONFLLIN_EXTENDBLOODVESSELS_ADDWIDTH_EN = str2num(data);
        elseif strcmp(den, 'ONFLLIN_EXTENDBLOODVESSELS_MULTWIDTH_EN')
            Params.ONFLLIN_EXTENDBLOODVESSELS_MULTWIDTH_EN = str2num(data);
        elseif strcmp(den, 'ONFLLIN_EXTENDBLOODVESSELS_MULTWIDTHTHRESH_EN')
            Params.ONFLLIN_EXTENDBLOODVESSELS_MULTWIDTHTHRESH_EN = str2num(data);        
            
        elseif strcmp(den, 'ONFLLIN_RANSAC_POLYNUMBER')
            Params.ONFLLIN_RANSAC_POLYNUMBER = str2num(data);    
        elseif strcmp(den, 'ONFLLIN_RANSAC_MAXITER')
            Params.ONFLLIN_RANSAC_MAXITER = str2num(data);
        elseif strcmp(den, 'ONFLLIN_RANSAC_NORM')
            Params.ONFLLIN_RANSAC_NORM = str2num(data);
        elseif strcmp(den, 'ONFLLIN_MERGE_DILATE')
            Params.ONFLLIN_MERGE_DILATE = str2num(data);
        elseif strcmp(den, 'ONFLLIN_MERGE_BORDER')
            Params.ONFLLIN_MERGE_BORDER = str2num(data);
        elseif strcmp(den, 'ONFLLIN_MERGE_THRESHOLD')
            Params.ONFLLIN_MERGE_THRESHOLD = str2num(data);
            
        elseif strcmp(den, 'ONFLLIN_ENERGYSMOOTH_GRADIENTWEIGHT')
            Params.ENERGYSMOOTH_GRADIENTWEIGHT = str2num(data);
        elseif strcmp(den, 'ONFLLIN_ENERGYSMOOTH_NEIGHBORWEIGHT')
            Params.ENERGYSMOOTH_NEIGHBORWEIGHT = str2num(data);
        elseif strcmp(den, 'ONFLLIN_ENERGYSMOOTH_REGIONWEIGHT')
            Params.ENERGYSMOOTH_REGIONWEIGHT = str2num(data);
        elseif strcmp(den, 'ONFLLIN_ENERGYSMOOTH_MAXITER')
            Params.ENERGYSMOOTH_MAXITER = str2num(data);
        elseif strcmp(den, 'ONFLLIN_SEGMENT_MINDIST_IPL_ONFL')
            Params.ONFLLIN_SEGMENT_MINDIST_IPL_ONFL = str2num(data);
        elseif strcmp(den, 'ONFLLIN_SEGMENT_LINESWEETER_FINAL')
            temp = str2num(data);
            Params.ONFLLIN_SEGMENT_LINESWEETER_FINAL = reshape(temp, [4 7]);
        elseif strcmp(den, 'ONFLLIN_VOLUME_MASK')
            Params.ONFLLIN_VOLUME_MASK = str2num(data);
        elseif strcmp(den, 'ONFLLIN_VOLUME_MEDFILT')
            Params.ONFLLIN_VOLUME_MEDFILT = str2num(data);
        end
    end
    
    line = fgetl(fid);
end


fclose(fid);
