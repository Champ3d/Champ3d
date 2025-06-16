function [node, id] = f_multisort(node,varargin)
% F_MULTISORT sorts layer by layer (row by row).
% field : [1 x nbElem]
% node  : [3 x nbElem]
% 'direction' : 'x', 'y' or 'z'
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to Champ3d code.
%--------------------------------------------------------------------------
% Champ3d is copyright (c) 2023-2025 H-K. Bui.
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'sort_order'};

% --- default input value
sort_order = [1 2 3];

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
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
dcz = find(diff([c1(1)+1   c1   c1(end)+1]));
for i = 1 : length(dcz)-1
    ix = dcz(i) : dcz(i+1)-1;
    xc = c2(ix);
    [xc, ixc] = sort(xc);
    ixc = ix(ixc);
    c2(ix) = xc;
    c3(ix) = c3(ixc);
    id(ix) = id(ixc);
    dcx = find(diff([xc(1)+1   xc  xc(end)+1]));
    for j = 1 : length(dcx)-1
        iy = ix(dcx(j) : dcx(j+1)-1);
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