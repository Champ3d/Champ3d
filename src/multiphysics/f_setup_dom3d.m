function dom3d = f_setup_dom3d(dom3d,varargin)
%--------------------------------------------------------------------------
% Questions and inquiries can be addressed to the author:
% Dr. H-K. Bui
% Lab. IREENA (Institut de recherche en Energie Electrique de Nantes Atlantique)
% Dep. Mesures Physiques, IUT of Saint Nazaire, University of Nantes
% 37, boulevard de l Universite, 44600 Saint Nazaire, France
% Email : huu-kien.bui@univ-nantes.fr
% Copyright (c) 2019 Huu-Kien Bui. All Rights Reserved.
%--------------------------------------------------------------------------



for i = 1:(nargin-1)/2
    datin.(lower(varargin{2*i-1})) = varargin{2*i};
end


nbElem = dom3d.mesh.nbElem;
nbEdge = dom3d.mesh.nbEdge;
nbFace = dom3d.mesh.nbFace;
nbNode = dom3d.mesh.nbNode;
con = f_connexion(dom3d.mesh.elem_type);

iNoTemp = [];
if isfield(dom3d,'tconductor')
    nb_dom = length(dom3d.tconductor);
    dom3d.Thermic.Temp = zeros(1,nbNode);
    dom3d.Thermic.elem_temp = zeros(1,nbElem);
    for i = 1:nb_dom
        %------------------------------------------------------------------
        iNoTemp = [iNoTemp reshape(dom3d.mesh.elem(1:con.nbNo_inEl,dom3d.tconductor(i).id_elem),...
            1,con.nbNo_inEl*length(dom3d.tconductor(i).id_elem))];
    end
    iNoTemp(iNoTemp == 0) = [];
    iNoTemp = unique(iNoTemp);
    %--------------------------------------------------------------------------
    dom3d.Thermic.id_node_temp = iNoTemp;
    dom3d.Thermic.Temp(1,dom3d.Thermic.id_node_temp) = datin.init_temp;
    dom3d.Thermic.elem_temp(1,:) = datin.init_temp;
    dom3d.Thermic.time = 0;
    dom3d.Thermic.step = 1;
    dom3d.Thermic.delta_t = [];
end
