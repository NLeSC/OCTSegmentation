function [volume] = iterateImfilter(volume, mask, option)
% ITERATEIMFILTER iterates imfilter(volume,mask,option) along the smaller
% of YZ or XZ planes.
% VOLUME:  X x Y x Z  image matrix
% MASK:    1 x N array of weight values
%
% This algorithm replaces the usage of imfilter(A,H,option) in 
% SEGMENTRPEAUTO when used for very large 3D matrices.  It is expected to 
% enable processing of very large .vol files by reducing memory usage at 
% the cost of computional speed.
% 
% Writen by 
%  Kristopher G. Sheets
%  Retinal Cell Biology Lab, 
%  Neuroscience Center
%  LSU Health Sciences Center
%  New Orleans, LA, USA
%
% Version 1.0beta: 15 July, 2011 1430PST

% volume dim 1 = y; X
% volume dim 2 = x; Y
% volume dim 3 = Z: Z

% ensure mask is 1xN not Nx1
[M N] = size(mask);
if M>N
    mask = mask';
end


[Y X Z] = size(volume);

if Y > X % iterate through XZ planes
    nImgPlanes = Y;
else % iterate through YZ planes
    nImgPlanes = X;
end
for i = 1:nImgPlanes
    if Y > X % get each XZ imgPlane
        imgPlane(:,:) = volume(i,:,:);
        if nargin<3
            volume(i,:,:) = imfilter(imgPlane,mask);
        else
            volume(i,:,:) = imfilter(imgPlane,mask,option);
        end
    else % get each YZ imgPlane
        imgPlane(:,:) = volume(:,i,:);
        if nargin<3
            volume(:,i,:) = imfilter(imgPlane,mask);
        else
            volume(:,i,:) = imfilter(imgPlane,mask,option);
        end
    end
end
