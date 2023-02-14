function [node, id] = f_multisort(node,varargin)
% F_MULTISORT sorts layer by layer (row by row).
% field : [1 x nbElem]
% node  : [3 x nbElem]
% 'direction' : 'x', 'y' or 'z'
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'sort_order'};

% --- default input value
sort_order = [1 2 3];

% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end


%--------------------------------------------------------------------------
id = 1:size(node,2);
%--------------------------------------------------------------------------

c1 = node(sort_order(1),id);
c2 = node(sort_order(2),id);
c3 = node(sort_order(3),id);

%--------------------------------------------------------------------------
[c1, iz] = sort(c1);
c2 = c2(iz);
c3 = c3(iz);
id = id(iz);
dcz = [1  find(diff(c1))+1];
for i = 1 : length(dcz)
    if i <= length(dcz) - 1
        ix = dcz(i) : dcz(i+1)-1;
    else
        ix = dcz(i) : length(c1);
    end
    xc = c2(ix);
    [xc, ixc] = sort(xc);
    ixc = ix(ixc);
    c2(ix) = xc;
    c3(ix) = c3(ixc);
    id(ix) = id(ixc);
    dcx = [1  find(diff(xc))+1];
    for j = 1 : length(dcx)
        if j <= length(dcx)-1
            iy = ixc(dcx(j) : dcx(j+1)-1);
        else
            iy = ixc(dcx(j) : length(xc));
        end
        yc = c3(iy);
        [yc, iyc] = sort(yc);
        iyc = iy(iyc);
        c3(iy) = yc;
        id(iy) = id(iyc);
    end
end
%--------------------------------------------------------------------------
node  = node(:,id);
%--------------------------------------------------------------------------