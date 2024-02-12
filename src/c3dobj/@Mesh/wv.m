%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function Wv = wv(obj,varargin)

% --- valid argument list (to be updated each time modifying function)
arglist = {'cdetJ'};

% --- default input value
cdetJ = [];

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
elem_type = obj.elem_type;
%--------------------------------------------------------------------------
node = obj.node;
elem = obj.elem;
%--------------------------------------------------------------------------
if any(f_strcmpi(elem_type,{'tri','triangle','quad'}))
    Wv{1} = 1./f_area(node,elem,'cdetJ',cdetJ);
elseif any(f_strcmpi(elem_type,{'tet','tetra','prism','hex','hexa'}))
    Wv{1} = 1./f_volume(node,elem,'cdetJ',cdetJ);
end
%--------------------------------------------------------------------------