function medline = segmentMedlineCirc(bscan, params)
% SEGMENTMEDLINECIRC
%
% The algorithm (of which this function is a part) is described in 
% Markus A. Mayer, Joachim Hornegger, Christian Y. Mardin, Ralf P. Tornow:
% Retinal Nerve Fiber Layer Segmentation on FD-OCT Scans of Normal Subjects
% and Glaucoma Patients, Biomedical Optics Express, Vol. 1, Iss. 5, 
% 1358-1383 (2010). Note that modifications have been made to the
% algorithm since the paper publication.
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg
%
% First final Version: June 2010

bscan(bscan > 1) = 0; 
medline = findmedline(bscan, params);
medline = linesweeter(medline, params.MEDLINE_LINESWEETER);
medline = floor(medline);
medline(medline < 1) = 1;

end