function area = f_area(node,face,varargin)
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
area = zeros(1,size(face,2));

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if ~isempty(cdetJ)
    % ---
    elem_type = f_elemtype(face,'defined_on','face');
    % ---
    con = f_connexion(elem_type);
    cWeigh = con.cWeigh;
    % ---
    area = cdetJ{1} .* cWeigh;
    % ---
    return
end
%--------------------------------------------------------------------------
[grface,lid_face,face_elem_type] = f_filterface(face);
%--------------------------------------------------------------------------
for i = 1:length(grface)
    % ---
    elem_type = face_elem_type{i};
    % ---
    if any(f_strcmpi(elem_type,{'tri','triangle','quad'}))
        face = grface{i};
        % ---
        flat_node = [];
        if size(node,1) == 3
            [flat_node, ~] = f_flatface(node,face);
        end
        % ---
        con = f_connexion(elem_type);
        cU  = con.cU;
        cV  = con.cV;
        cWeigh = con.cWeigh;
        %------------------------------------------------------------------
        mesh.node = node;
        mesh.elem = face;
        mesh.elem_type = elem_type;
        [S, ~] = f_jacobien(mesh,'u',cU,'v',cV,'flat_node',flat_node);
        %------------------------------------------------------------------
        S = S{1} .* cWeigh;
        %------------------------------------------------------------------
        area(lid_face{i}) = S;
        %------------------------------------------------------------------
    end
end


