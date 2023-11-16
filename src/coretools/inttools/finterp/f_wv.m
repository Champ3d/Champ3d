function Wv = f_wv(mesh,varargin)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

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
if ~isfield(mesh,'elem') || ~isfield(mesh,'node')
    error([mfilename ' : #mesh3d/2d struct must contain .elem and .node']);
end
%--------------------------------------------------------------------------
if isfield(mesh,'elem_type')
    elem_type = mesh.elem_type;
else
    error([mfilename ' : #mesh struct must contain .elem_type']);
end
%--------------------------------------------------------------------------
node = mesh.node;
elem = mesh.elem;
%--------------------------------------------------------------------------
if any(f_strcmpi(elem_type,{'tri','triangle','quad'}))
    Wv{1} = 1./f_area(node,elem,'cdetJ',cdetJ);
elseif any(f_strcmpi(elem_type,{'tet','tetra','prism','hex','hexa'}))
    Wv{1} = 1./f_volume(node,elem,'cdetJ',cdetJ);
end
%--------------------------------------------------------------------------