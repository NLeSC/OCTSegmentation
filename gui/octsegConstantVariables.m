function octsegConstantVariables 
% OCTSEGCONSTANTVARIABLS
% This file defines the constant/gloabl variables for the various GUIs. 
% Currently, all variables are kept in this one file - this creates some
% overhead, but enables a better code maintanance.
%
% Code by Markus Mayer, Pattern Recognition Lab, 
% University of Erlangen-Nuremberg, March 2011
%
% Some reminders for code structuring in OCTSEG:
%
% In accesing META Tags, the following function should be used:
% getMetaTag
% The descriptor names for the available segmentations are:
%   INFL
%   ONFL
%   Inner Layers
%   ICL
%   IPL
%   OPL
%   RPE
%   Sklera
%   Medline
%   Blood Vessels
%   ONH
%   ONHCircle
%   ONHCenter
%   ONHRadius

% Where is the parameter file located?
global PARAMETER_FILENAME;
PARAMETER_FILENAME = 'octseg.param';

% Table descriptors for octsegMain
global TABLE_HEADERS;
TABLE_HEADERS = {{'BScan #', 'OCTSEG', 'ONH', 'RPE', 'Blood Vessels', 'INFL', 'Inner Layers', 'ONFL', 'Sklera'}, ...
                {'BScan #', 'OCTSEG', 'RPE', 'Blood Vessels', 'INFL',  'Inner Layers', 'ONFL', 'Sklera'}, ...
                {'BScan #', 'OCTSEG', 'RPE', 'Blood Vessels', 'INFL',  'Inner Layers', 'ONFL', 'Sklera'}, ...
                {'BScan #', 'OCTSEG', 'ONH', 'RPE', 'Blood Vessels', 'INFL', 'Inner Layers', 'ONFL', 'Sklera'}, ...
                };

global TABLE_FORMAT;
TABLE_FORMAT = {{'long', 'logical', 'char', 'char', 'char', 'char', 'char', 'char', 'char'}, ...
                {'long', 'logical', 'char', 'char', 'char', 'char', 'char', 'char'}, ...
                {'long', 'logical', 'char', 'char', 'char', 'char', 'char', 'char'}, ...
                {'long', 'logical', 'char', 'char', 'char', 'char', 'char', 'char', 'char'}, ...
                };
 
global TABLE_EDITABLE;
TABLE_EDITABLE = {[false false false false false false false false false], ...
                [false false false false false false false false], ...
                [false false false false false false false false], ...
                [false false false false false false false false false], ...
                };

% Table of meta tags
% A descriptor is followed in the same row by 
% (1) the associated automated segmentation tag
% (2) the associated manual segmentation tag
global TABLE_META_TAGS;
TABLE_META_TAGS = { 'ONH', 'ONHauto', 'ONHman'; ...
                    'Blood Vessels', 'BVauto', 'BVman'; ...
                    'INFL', 'INFLauto', 'INFLman'; ...
                    'Inner Layers', 'InnerLayersAuto', 'OCLman'; ...
                    'ICL', 'ICLauto', 'ICLman'; ...
                    'IPL', 'IPLauto', 'IPLman'; ...
                    'OPL', 'OPLauto', 'OPLman'; ...
                    'ONFL', 'ONFLauto', 'ONFLman'; ...
                    'Sklera', 'SkleraAuto', 'SkleraMan'; ...
                    'Medline', 'MedlineAuto', 'MedlineMan'; ...
                    'ONHCenter', 'ONHCenterAuto', 'ONHCenterMan'; ...
                    'ONHCircle', 'ONHCircleAuto', 'ONHCircleMan'; ...
                    'ONHRadius', 'ONHRadiusAuto', 'ONHRadiusMan'; ...
                    'RPE', 'RPEauto', 'RPEman'; ...
                    'RPEMULT', 'RPEMULTauto', 'RPEMULTman'; ...
                    'INFLMULT', 'INFLMULTauto', 'INFLMULTman'};
                
% Numeric representations of file types (used in examineOctFile and 
% the calling functions). Currently, the following descriptors are 
% supported:            
%   0: This is no OCT file
%   1: HE RAW-file (with .vol ending)
%   2: OCTSEG RAW-file (with .oct ending)
%   3: PNG File
%   4: TIF File
%   5: List of images
%   6: Other file
global FILETYPE;
FILETYPE.NOOCT = 0;
FILETYPE.HE = 1;
FILETYPE.RAW = 2;
FILETYPE.IMAGE = 3;
FILETYPE.LIST = 6;
FILETYPE.OTHER = 7;

% Numeric representations for the status of the processed files (used in
% checkFilesIfProcessed and the calling functions).
global PROCESSEDFILES;
PROCESSEDFILES.ALL = 2;
PROCESSEDFILES.SOME = 1;
PROCESSEDFILES.NONE = 0;

global PROCESSEDFILESANSWER;
PROCESSEDFILESANSWER.CANCEL = 0;
PROCESSEDFILESANSWER.ALL = 1;
PROCESSEDFILESANSWER.REMAINING = 2;

end