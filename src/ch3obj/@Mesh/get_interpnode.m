%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function node_i = get_interpnode(obj,node)

%-------------------------------------------------------------------------
if nargin <= 1
    node = obj.node;
end
%--------------------------------------------------------------------------
refelem = obj.refelem;
U = refelem.iU;
V = refelem.iV;
W = refelem.iW;
%--------------------------------------------------------------------------
obj.build_meshds;
%--------------------------------------------------------------------------
for3d = 0;
dim   = 2;
if size(node,1) == 3
    for3d = 1;
    dim   = 3;
end
%--------------------------------------------------------------------------
% Interpolation points
Wn = obj.wn('u',U,'v',V,'w',W);
%--------------------------------------------------------------------------
nbNo_inEl = refelem.nbNo_inEl;
realx = (reshape(node(1,obj.elem),nbNo_inEl,[])).';
realy = (reshape(node(2,obj.elem),nbNo_inEl,[])).';
if for3d
    realz = (reshape(node(3,obj.elem),nbNo_inEl,[])).';
end
nb_inode  = length(U);
node_i = cell(1,nb_inode);
for i = 1:nb_inode
    node_i{i} = zeros(obj.nb_elem,dim);
    node_i{i}(:,1) = sum(Wn{i} .* realx,2);
    node_i{i}(:,2) = sum(Wn{i} .* realy,2);
    if for3d
        node_i{i}(:,3) = sum(Wn{i} .* realz,2);
    end
end
%--------------------------------------------------------------------------
end