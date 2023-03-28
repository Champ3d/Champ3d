function design3d = f_build_econ_aphi(design3d,varargin)
% F_BUILD_ECON_APHI_JW returns the matrix system
% related to econductor for A-phi formulation. 
%--------------------------------------------------------------------------
% System = F_BUILD_ECON_APHI_JW(dom3D,option);
%--------------------------------------------------------------------------
% Questions and inquiries can be addressed to the author:
% Dr. H-K. Bui
% Lab. IREENA
% Dep. Mesures Physiques, IUT of Saint Nazaire
% University of Nantes, France
% Email : huu-kien.bui@univ-nantes.fr
% Copyright (c) 2019 Huu-Kien Bui. All Rights Reserved.
%--------------------------------------------------------------------------



% --- valid argument list (to be updated each time modifying function)
arglist = {'id_dom3d'};

% --- default input value
id_dom3d = [];

% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
nbElem = design3d.mesh.nbElem;
nbEdge = design3d.mesh.nbEdge;
nbFace = design3d.mesh.nbFace;
nbNode = design3d.mesh.nbNode;
con = f_connexion(design3d.mesh.elem_type);
%--------------------------------------------------------------------------
if ~isfield(design3d.aphi,'SWeWe') || isempty(id_dom3d)
    design3d.aphi.SWeWe = sparse(nbEdge,nbEdge);
end
%--------------------------------------------------------------------------
% TODO : loop for each mesh type
iNoPhi = [];
if isfield(design3d,'econductor')
    nb_dom = length(design3d.econductor);
    if isempty(id_dom3d)
        for i = 1:nb_dom
            %---------------------------------------------
            fprintf(['Building econ ' design3d.econductor(i).id_dom3d '\n']);
            %---------------------------------------------
            IDElem = design3d.econductor(i).id_elem;
            iNoPhi = [iNoPhi reshape(design3d.mesh.elem(1:con.nbNo_inEl,IDElem),...
                                     1,con.nbNo_inEl*length(IDElem))];
            %---------------------------------------------
            sig = design3d.econductor(i).sigma;
            if isstruct(sig)
                ltensor.main_value = f_calparam(design3d,sig.main_value,'id_elem',IDElem);
                ltensor.ort1_value = f_calparam(design3d,sig.ort1_value,'id_elem',IDElem);
                ltensor.ort2_value = f_calparam(design3d,sig.ort2_value,'id_elem',IDElem);
                ltensor.main_dir   = f_calparam(design3d,sig.main_dir,'id_elem',IDElem);
                ltensor.ort1_dir   = f_calparam(design3d,sig.ort1_dir,'id_elem',IDElem);
                ltensor.ort2_dir   = f_calparam(design3d,sig.ort2_dir,'id_elem',IDElem);
                gtensor = f_gtensor(ltensor);
                design3d.econductor(i).gtensor = gtensor;
                design3d.aphi.SWeWe = design3d.aphi.SWeWe + ...
                        f_cwewe(design3d.mesh,'coef',design3d.econductor(i).gtensor,...
                          'id_elem',IDElem);
            elseif numel(sig) == 9
                design3d.econductor(i).gtensor = sig;
                design3d.aphi.SWeWe = design3d.aphi.SWeWe + ...
                        f_cwewe(design3d.mesh,'coef',design3d.econductor(i).gtensor,...
                          'id_elem',IDElem);
            end
        end
    else
        for i = 1:nb_dom
            if strcmpi(design3d.econductor(i).id_dom3d,id_dom3d)
                %---------------------------------------------
                fprintf(['Building econ ' design3d.econductor(i).id_dom3d '\n']);
                %---------------------------------------------
                IDElem = design3d.econductor(i).id_elem;
                iNoPhi = [iNoPhi reshape(design3d.mesh.elem(1:con.nbNo_inEl,IDElem),...
                                         1,con.nbNo_inEl*length(IDElem))];
                %---------------------------------------------
                sig = design3d.econductor(i).sigma;
                if isstruct(sig)
                    ltensor.main_value = f_calparam(design3d,sig.main_value,'id_elem',IDElem);
                    ltensor.ort1_value = f_calparam(design3d,sig.ort1_value,'id_elem',IDElem);
                    ltensor.ort2_value = f_calparam(design3d,sig.ort2_value,'id_elem',IDElem);
                    ltensor.main_dir   = f_calparam(design3d,sig.main_dir,'id_elem',IDElem);
                    ltensor.ort1_dir   = f_calparam(design3d,sig.ort1_dir,'id_elem',IDElem);
                    ltensor.ort2_dir   = f_calparam(design3d,sig.ort2_dir,'id_elem',IDElem);
                    gtensor = f_gtensor(ltensor);
                    design3d.econductor(i).gtensor = gtensor;
                    design3d.aphi.SWeWe = design3d.aphi.SWeWe + ...
                            f_cwewe(design3d.mesh,'coef',design3d.econductor(i).gtensor,...
                              'id_elem',IDElem);
                elseif numel(sig) == 9
                    design3d.econductor(i).gtensor = sig;
                    design3d.aphi.SWeWe = design3d.aphi.SWeWe + ...
                            f_cwewe(design3d.mesh,'coef',design3d.econductor(i).gtensor,...
                              'id_elem',IDElem);
                end
            end
        end
    end
    iNoPhi(iNoPhi == 0) = [];
    iNoPhi = unique(iNoPhi);
end
%--------------------------------------------------------------------------
design3d.aphi.id_node_phi = unique([design3d.aphi.id_node_phi iNoPhi]);
%--------------------------------------------------------------------------




