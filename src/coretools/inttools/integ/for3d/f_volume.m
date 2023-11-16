function vol = f_volume(node,elem,varargin)
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
% --- default ouptu value
vol = [];

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
elem_type = f_elemtype(elem,'defined_on','elem');
%--------------------------------------------------------------------------
if ~isempty(cdetJ)
    con = f_connexion(elem_type);
    cWeigh = con.cWeigh;
    % ---
    vol = cdetJ{1} .* cWeigh;
    % ---
    return
end
%--------------------------------------------------------------------------
if any(f_strcmpi(elem_type,{'tet','tetra','prism','hex','hexa'}))
    con = f_connexion(elem_type);
    cU  = con.cU;
    cV  = con.cV;
    cW  = con.cW;
    cWeigh = con.cWeigh;
    %----------------------------------------------------------------------
    mesh.node = node;
    mesh.elem = elem;
    mesh.elem_type = elem_type;
    [vol, ~] = f_jacobien(mesh,'u',cU,'v',cV,'w',cW);
    %----------------------------------------------------------------------
    vol = vol{1} .* cWeigh;
    %----------------------------------------------------------------------
end


