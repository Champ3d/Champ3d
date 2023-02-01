function design3d = f_build_mcon_aphi(design3d,varargin)
% F_BUILD_MCON_APHI returns the matrix system
% related to mconductor for A-phi formulation. 
%--------------------------------------------------------------------------
% System = F_BUILD_MCON_APHI(dom3D,option);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

nbElem = design3d.mesh.nbElem;
nbEdge = design3d.mesh.nbEdge;
nbFace = design3d.mesh.nbFace;
nbNode = design3d.mesh.nbNode;
con = f_connexion(design3d.mesh.elem_type);
%--------------------------------------------------------------------------
% TODO : loop for each mesh type
design3d.aphi.SWfnuWf = sparse(nbFace,nbFace);
design3d.aphi.SWfdnudbWf = sparse(nbFace,nbFace);
mu0 = 4*pi*1e-7;
id_elem_mc = [];
if isfield(design3d,'mconductor')
    nb_dom = length(design3d.mconductor);
    for idom = 1:nb_dom
        if isempty(design3d.aphi.MVP) || ...
           isa(design3d.mconductor(idom).mur.main_value.f,'function_handle')
            %--------------------------------------------------------------
            ltensor.main_value = f_calparam(design3d,design3d.mconductor(idom).mur.main_value,'id_elem',design3d.mconductor(idom).id_elem);
            ltensor.ort1_value = f_calparam(design3d,design3d.mconductor(idom).mur.ort1_value,'id_elem',design3d.mconductor(idom).id_elem);
            ltensor.ort2_value = f_calparam(design3d,design3d.mconductor(idom).mur.ort2_value,'id_elem',design3d.mconductor(idom).id_elem);
            ltensor.main_dir = f_calparam(design3d,design3d.mconductor(idom).mur.main_dir,'id_elem',design3d.mconductor(idom).id_elem);
            ltensor.ort1_dir = f_calparam(design3d,design3d.mconductor(idom).mur.ort1_dir,'id_elem',design3d.mconductor(idom).id_elem);
            ltensor.ort2_dir = f_calparam(design3d,design3d.mconductor(idom).mur.ort2_dir,'id_elem',design3d.mconductor(idom).id_elem);
            gtensor = f_gtensor(ltensor);
            design3d.mconductor(idom).gtensor = gtensor;
            %--------------------------------------------------------------
            nu = f_invtensor(mu0 .* design3d.mconductor(idom).gtensor);
            %--------------------------------------------------------------
            design3d.aphi.SWfnuWf = design3d.aphi.SWfnuWf + ...
                                  f_cwfwf(design3d.mesh,'coef',nu,...
                                  'id_elem',design3d.mconductor(idom).id_elem);
            %--------------------------------------------------------------
            id_elem_mc = [id_elem_mc design3d.mconductor(idom).id_elem];
            %--------------------------------------------------------------
        else
            % --- Flux
            Flux = design3d.mesh.R * design3d.aphi.MVP;
            % --- Flux density
            design3d.aphi.B = f_postpro3d(design3d.mesh,Flux,'W2');
            %--------------------------------------------------------------
            ltensor.main_value = ...
                spline(design3d.mconductor(idom).mur.main_value.b, ...
                       design3d.mconductor(idom).mur.main_value.murjw, ...
                       abs(f_norm(design3d.aphi.B(:,design3d.mconductor(idom).id_elem))));
            ltensor.ort1_value = ...
                spline(design3d.mconductor(idom).mur.ort1_value.b, ...
                       design3d.mconductor(idom).mur.ort1_value.murjw, ...
                       abs(f_norm(design3d.aphi.B(:,design3d.mconductor(idom).id_elem))));
            ltensor.ort2_value = ...
                spline(design3d.mconductor(idom).mur.ort2_value.b, ...
                       design3d.mconductor(idom).mur.ort2_value.murjw, ...
                       abs(f_norm(design3d.aphi.B(:,design3d.mconductor(idom).id_elem))));
            %--------------------------------------------------------------
            ltensor.main_dir = f_calparam(design3d,design3d.mconductor(idom).mur.main_dir,'id_elem',design3d.mconductor(idom).id_elem);
            ltensor.ort1_dir = f_calparam(design3d,design3d.mconductor(idom).mur.ort1_dir,'id_elem',design3d.mconductor(idom).id_elem);
            ltensor.ort2_dir = f_calparam(design3d,design3d.mconductor(idom).mur.ort2_dir,'id_elem',design3d.mconductor(idom).id_elem);
            %--------------------------------------------------------------
            gtensor = f_gtensor(ltensor);
            design3d.mconductor(idom).gtensor = gtensor;
            %--------------------------------------------------------------
            nu = f_invtensor(mu0 .* design3d.mconductor(idom).gtensor);
            %--------------------------------------------------------------
            design3d.aphi.SWfnuWf = design3d.aphi.SWfnuWf + ...
                                  f_cwfwf(design3d.mesh,'coef',nu,...
                                  'id_elem',design3d.mconductor(idom).id_elem);
            %--------------------------------------------------------------
            id_elem_mc = [id_elem_mc design3d.mconductor(idom).id_elem];
            %--------------------------------------------------------------
            %
            %              For Newton-Raphson
            %
            %--------------------------------------------------------------
            ltensor.main_value = ...
                spline(design3d.mconductor(idom).mur.main_value.b, ...
                       design3d.mconductor(idom).mur.main_value.dnurdbjw, ...
                       abs(f_norm(design3d.aphi.B(:,design3d.mconductor(idom).id_elem)))) ...
                     .*abs(f_norm(design3d.aphi.B(:,design3d.mconductor(idom).id_elem)))  ...
                     .*(1/mu0);
            ltensor.ort1_value = ...
                spline(design3d.mconductor(idom).mur.ort1_value.b, ...
                       design3d.mconductor(idom).mur.ort1_value.dnurdbjw, ...
                       abs(f_norm(design3d.aphi.B(:,design3d.mconductor(idom).id_elem)))) ...
                     .*abs(f_norm(design3d.aphi.B(:,design3d.mconductor(idom).id_elem)))  ...
                     .*(1/mu0);
            ltensor.ort2_value = ...
                spline(design3d.mconductor(idom).mur.ort2_value.b, ...
                       design3d.mconductor(idom).mur.ort2_value.dnurdbjw, ...
                       abs(f_norm(design3d.aphi.B(:,design3d.mconductor(idom).id_elem)))) ...
                     .*abs(f_norm(design3d.aphi.B(:,design3d.mconductor(idom).id_elem)))  ...
                     .*(1/mu0);
            %--------------------------------------------------------------
            ltensor.main_dir = f_calparam(design3d,design3d.mconductor(idom).mur.main_dir,'id_elem',design3d.mconductor(idom).id_elem);
            ltensor.ort1_dir = f_calparam(design3d,design3d.mconductor(idom).mur.ort1_dir,'id_elem',design3d.mconductor(idom).id_elem);
            ltensor.ort2_dir = f_calparam(design3d,design3d.mconductor(idom).mur.ort2_dir,'id_elem',design3d.mconductor(idom).id_elem);
            %--------------------------------------------------------------
            dnurdbxb = f_gtensor(ltensor);
            %--------------------------------------------------------------
            design3d.aphi.SWfdnudbWf = design3d.aphi.SWfdnudbWf + ...
                          f_cwfwf(design3d.mesh,'coef',dnurdbxb,...
                          'id_elem',design3d.mconductor(idom).id_elem);
        end
    end
end
id_elem_mc = unique(id_elem_mc);
%--------------------------------------------------------------------------















