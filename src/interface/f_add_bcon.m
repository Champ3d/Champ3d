function design3d = f_add_bcon(design3d,varargin)
% F_ADD_BCON ...
%--------------------------------------------------------------------------
% dom3D = F_ADD_BCON(dom3D,'defined_on','face','id_elem',':','bc_type','fixed','bc_value',0);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

if isempty(design3d)
    design3d.bcon = [];
end

if ~isfield(design3d,'bcon')
    iec = 0;
else
    iec = length(design3d.bcon);
end

%--------------------------------------------------------------------------
if nargin <= 1
    error('No boundary condition to add!');
end
%--------------------------------------------------------------------------
datin = [];
for i = 1:(nargin-1)/2
    datin.(lower(varargin{2*i-1})) = varargin{2*i};
    design3d.bcon(iec+1).(lower(varargin{2*i-1})) = varargin{2*i};
end

%--------------------------------------------------------------------------
if isfield(datin,'bc_type')
    design3d.bcon(iec+1).bc_type = datin.bc_type;
    %------------------------------------------------------
    switch datin.bc_type
        %--------------------------------------------------
        case 'fixed'
            if isfield(datin,'bc_value')
                design3d.bcon(iec+1).bc_value = datin.bc_value;
            else
                design3d.bcon(iec+1).bc_value = 0;
            end
        %--------------------------------------------------
        case 'neumann'
            if ~isfield(datin,'bc_coef')
                design3d.bcon(iec+1).bc_coef = 0;
            end
            if ~isfield(datin,'bc_value')
                design3d.bcon(iec+1).bc_value = 0;
            end
        %--------------------------------------------------
        case 'sibc'
            if ~isfield(datin,'bc_sigma')
                design3d.bcon(iec+1).bc_sigma = 0;
            end
        %--------------------------------------------------
        case 'periodic'
        %--------------------------------------------------
        case 'anti-periodic'
    end
end

%--------------------------------------------------------------------------
if ~isfield(datin,'sigma')
    design3d.bcon(iec+1).gtsigma = [1 0 0; 0 1 0; 0 0 1];
elseif length(datin.sigma) == 1 & ~isfield(datin.sigma,'main_value')
    design3d.bcon(iec+1).gtsigma = [datin.sigma 0 0; 0 datin.sigma 0; 0 0 datin.sigma];
elseif length(datin.sigma) == [3,3] & ~isfield(datin.sigma,'main_value')
    design3d.bcon(iec+1).gtsigma = datin.sigma;
elseif isfield(datin.sigma,'main_value')
    design3d.bcon(iec+1).gtsigma = f_gtensor(datin.sigma);
end

%--------------------------------------------------------------------------
if ~isfield(datin,'mur')
    design3d.bcon(iec+1).gtmur = [1 0 0; 0 1 0; 0 0 1];
elseif length(datin.mur) == 1 & ~isfield(datin.mur,'main_value')
    design3d.bcon(iec+1).gtmur = [datin.mur 0 0; 0 datin.mur 0; 0 0 datin.mur];
elseif length(datin.mur) == [3,3] & ~isfield(datin.mur,'main_value')
    design3d.bcon(iec+1).gtmur = datin.mur;
elseif isfield(datin.mur,'main_value')
    design3d.bcon(iec+1).gtmur = f_gtensor(datin.mur);
end

%--------------------------------------------------------------------------
con = f_connexion(design3d.mesh.elem_type);
nbNo_inFa_max = max(con.nbNo_inFa);
if isfield(datin,'defined_on')
    design3d.bcon(iec+1).defined_on = datin.defined_on;
end
%---------
if isfield(datin,'id_elem')
    datin.id_elem = unique(datin.id_elem);
else
    datin.id_elem = [];
end
%---------
if isfield(datin,'id_dom3d')
    design3d.bcon(iec+1).id_elem  = design3d.dom3d.(datin.id_dom3d).id_elem;
else
    design3d.bcon(iec+1).id_elem  = datin.id_elem;
end
%---------
bcmesh = f_make_mds(design3d.mesh.node,design3d.mesh.elem(:,design3d.bcon(iec+1).id_elem),design3d.mesh.elem_type);
%--------------------------------------------------------------------------
id_face = ...
    f_findvec(bcmesh.bound(1:nbNo_inFa_max,:),design3d.mesh.face(1:nbNo_inFa_max,:));
design3d.bcon(iec+1).id_face = id_face;
design3d.bcon(iec+1).s_face = f_measure(design3d.mesh.node,design3d.mesh.face(:,id_face),'face');
%--------------------------------------------------------------------------
nbEd_inFa_max = 0;
for i = 1:length(con.nbEd_inFa)
    nbEd_inFa_max = max([nbEd_inFa_max con.nbEd_inFa{i}]);
end
%--------------------------------------------------------------------------
id_edge = reshape(design3d.mesh.edge_in_face(1:nbEd_inFa_max,id_face),...
                  1,nbEd_inFa_max*length(id_face));
id_edge = unique(id_edge);
id_edge(id_edge == 0) = [];
design3d.bcon(iec+1).id_edge = id_edge;
%--------------------------------------------------------------------------
id_node = reshape(design3d.mesh.edge(1:2,id_edge),...
                  1,2*length(id_edge));
id_node = unique(id_node);
id_node(id_node == 0) = [];
design3d.bcon(iec+1).id_node = id_node;
%--------------------------------------------------------------------------

%%
% if strcmpi(datin.bc_type,'sibc')
%     %----------------------------------------------------------------------
%     [face,id_face_sibc] = f_filterface(dom3d.mesh.face(:,id_face));
%     for i = 1:length(face)
%         id_face_sibc{i} = id_face(id_face_sibc{i});
%     end
%     dom3d.bcon(iec+1).nb_face_type = length(face);
%     %----------------------------------------------------------------------
%     for i = 1:dom3d.bcon(iec+1).nb_face_type
%         [flatnode,flatface] = f_flatface(dom3d.mesh.node,...
%                                          dom3d.mesh.face(:,id_face_sibc{i}));
%         if size(flatface,1) == 3
%             mesh_sibc = f_mdstri(dom3d.mesh.node,flatface);
%             id_ledge = [];
%             id_gedge = [];
%             for j = 1:3
%                 id_ledge = [id_ledge mesh_sibc.edge_in_elem(j,:)];
%                 id_gedge = [id_gedge dom3d.mesh.edge_in_face(j,id_face_sibc{i})];
%             end
%             idgEdge = zeros(1,mesh_sibc.nbEdge);
%             idgEdge(id_ledge) = id_gedge;
%         elseif size(flatface,1) == 4
%             mesh_sibc = f_mdsquad(dom3d.mesh.node,flatface);
%             id_ledge = [];
%             id_gedge = [];
%             for j = 1:4
%                 id_ledge = [id_ledge mesh_sibc.edge_in_elem(j,:)];
%                 id_gedge = [id_gedge dom3d.mesh.edge_in_face(j,id_face_sibc{i})];
%             end
%             idgEdge = zeros(1,mesh_sibc.nbEdge);
%             idgEdge(id_ledge) = id_gedge;
%         end
%         mesh_sibc = f_intkit2d(mesh_sibc,'flatnode',flatnode);
%         mesh_sibc.idgEdge = idgEdge;
%         dom3d.bcon(iec+1).mesh_sibc{i} = mesh_sibc;
%     end
% end




end









