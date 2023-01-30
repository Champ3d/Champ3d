function design3d = f_build_coil_aphi(design3d,varargin)
% F_BUILD_COIL_APHI returns the matrix system
% related to econductor for A-phi formulation. 
%--------------------------------------------------------------------------
% System = F_BUILD_COIL_APHI(dom3D,option);
%--------------------------------------------------------------------------
% Questions and inquiries can be addressed to the author:
% Dr. H-K. Bui
% Lab. IREENA
% Dep. Mesures Physiques, IUT of Saint Nazaire
% University of Nantes, France
% Email : huu-kien.bui@univ-nantes.fr
% Copyright (c) 2019 Huu-Kien Bui. All Rights Reserved.
%--------------------------------------------------------------------------

nbElem = design3d.mesh.nbElem;
nbEdge = design3d.mesh.nbEdge;
nbFace = design3d.mesh.nbFace;
nbNode = design3d.mesh.nbNode;
con = f_connexion(design3d.mesh.elem_type);
%---------------------- Source - RHS - Coil -------------------------------
iNoPhi = [];
%--------------------------------------------------------------------------
design3d.aphi.coilRHS = zeros(nbEdge,1);
design3d.aphi.Alpha   = [];
if isfield(design3d,'coil')
    nb_coil = length(design3d.coil);
    for i = 1:nb_coil
        coil_model = lower(design3d.coil(i).coil_model);
        switch coil_model
            case 't1'
                cfield = f_build_coil_type_1(design3d.mesh,design3d.coil(i),design3d.bcon(design3d.coil(i).id_bcon));
                design3d.coil(i).N  = cfield.N;
                if strcmpi(design3d.coil(i).coil_mode,'transmitter')
                    design3d.coil(i).Js = cfield.Js;
                    design3d.aphi.coilRHS = design3d.aphi.coilRHS + cfield.cRHS;
                end
            case 't2'
                cfield = f_build_coil_type_2(design3d.mesh,design3d.coil(i),design3d.bcon(design3d.coil(i).id_bcon));
                design3d.coil(i).N  = cfield.N;
                if strcmpi(design3d.coil(i).coil_mode,'transmitter')
                    design3d.coil(i).Js = cfield.Js;
                    design3d.aphi.coilRHS = design3d.aphi.coilRHS + cfield.cRHS;
                end
            case 't3'
                cfield = f_build_coil_type_3(design3d.mesh,design3d.coil(i),design3d.bcon(design3d.coil(i).id_bcon));
                %dom3d.coil(i).N  = cfield.N;
                design3d.aphi.Alpha{i} = cfield.Alpha;
                design3d.coil(i).Js = cfield.Js;
                if strcmpi(design3d.coil(i).coil_mode,'transmitter')
                    %dom3d.coil(i).Js = cfield.Js;
                    for j = 1:length(design3d.coil(i).petrode)
                        iNoPhi = setdiff(iNoPhi,design3d.coil(i).petrode(j).id_node);
                    end
                    for j = 1:length(design3d.coil(i).netrode)
                        iNoPhi = setdiff(iNoPhi,design3d.coil(i).netrode(j).id_node);
                    end
                end
            case 't4'
                cfield = f_build_coil_type_4(design3d.mesh,design3d.coil(i),design3d.bcon(design3d.coil(i).id_bcon));
                %dom3d.coil(i).N  = cfield.N;
                design3d.aphi.Alpha{i} = cfield.Alpha;
                design3d.coil(i).Js = cfield.Js;
                if strcmpi(design3d.coil(i).coil_mode,'transmitter')
                    %dom3d.coil(i).Js = cfield.Js;
                    for j = 1:length(design3d.coil(i).petrode)
                        iNoPhi = setdiff(iNoPhi,design3d.coil(i).petrode(j).id_node);
                    end
                    for j = 1:length(design3d.coil(i).netrode)
                        iNoPhi = setdiff(iNoPhi,design3d.coil(i).netrode(j).id_node);
                    end
                end
            otherwise
        end
    end
end
%--------------------------------------------------------------------------
design3d.aphi.id_node_phi = unique([design3d.aphi.id_node_phi iNoPhi]);
%--------------------------------------------------------------------------









