function medline = findmedline(octimg, params)
% FINDMEDLINE Finds the "Black Region" inside a (circular) B-Scan.
% MEDLINE = findmedline(OCTIMG)
% Finds the "Black Region" inside a (circular) B-Scan. The line is placed
% somewhere between the outer plexiform layer and the outer nuclear layer.
% Very simple algorithm: Apply heavy smoothing, then detect the minimum
% between the two highest intensity maximas.
% OCTIMG: The input BScan (not intensity change applied yet) - raw data
% PARAMS: Parameter struct for the automated segmentation
%   In this function, the following parameters are currently used:
%   MEDLINE_SIGMA1: The gaussian smoothing sigma for finding the two
%   largest intensity maxima
%   MEDLINE_SIGMA2:  The gaussian smoothing sigma for finding minimum in
%   between the maxima
%   MEDLINE_LINESWEETER: Linesweeter smoothing parameters for the medline
% L: The resulting line.
% 
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg
%
% First final Version: June 2010

mindist = params.MEDLINE_MINDIST;

gsize = floor(params.MEDLINE_SIGMA1 * 1.5);
gsize = gsize + mod(gsize, 2) + 1;
gauss = fspecial('gaussian', gsize, params.MEDLINE_SIGMA1); 

g = imfilter(octimg, gauss, 'symmetric');
g = g ./ max(max(g));

lmax = extremafinder(g, 2, 'max pos');

lmax(:, abs(lmax(2,:) - lmax(1,:)) < mindist) = 0;
lmax =  round(linesweeter(lmax, params.MEDLINE_LINESWEETER));

gsize = floor(params.MEDLINE_SIGMA1 * 2);
gsize = gsize + mod(gsize, 2) + 1;
gauss = fspecial('gaussian', gsize, params.MEDLINE_SIGMA1);

g = imfilter(octimg, gauss, 'symmetric');
lmin = extremafinder(g, 1, 'low pos', lmax);
medline =  linesweeter(lmin, params.MEDLINE_LINESWEETER);

