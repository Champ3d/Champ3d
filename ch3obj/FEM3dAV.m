%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
% as a contribution to Champ3d code.
%--------------------------------------------------------------------------
% Champ3d is copyright (c) 2023-2025 H-K. Bui.
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef FEM3dAV < FEM3dAphi
    properties (Access = private)
        build_done = 0
        basematrix_done = 0
    end
    properties (Access = private)
        idVIsCoil = []
    end
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'parent_mesh'};
        end
    end
    % --- Constructor
    methods
        function obj = FEM3dAV(args)
            arguments
                args.parent_mesh {mustBeA(args.parent_mesh,'Mesh3d')}
                args.airbox_bcon {mustBeMember(args.airbox_bcon,{'nullfield','free'})} = 'nullfield'
            end
            % ---
            obj@FEM3dAphi;
            % ---
            obj <= args;
            % ---
            obj.parent_mesh.is_defining_obj_of(obj);
            % ---
        end
    end

    % --- XTODO : setup/reset
    methods (Static)
        function setup(obj)
            obj.build_done = 0;
            obj.basematrix_done = 0;
        end
    end
    methods (Access = public)
        function reset(obj)
            FEM3dAV.setup(obj);
            % --- reset dependent obj
            % obj.reset_dependent_obj;
        end
    end

    % --- build
    methods
        %------------------------------------------------------------------
        function build(obj)
            % ---
            if obj.build_done
                return
            end
            % ---
            obj.parent_mesh.build;
            %--------------------------------------------------------------
            if isempty(obj.airbox)
                if ~isfield(obj.parent_mesh.dom,'whole_mesh_dom')
                    obj.parent_mesh.add_whole_mesh_dom;
                end
                obj.airbox.by_default_airbox = ...
                    Airbox('parent_model',obj,'id_dom3d','whole_mesh_dom');
            end
            %--------------------------------------------------------------
            obj.build_done = 1;
            % ---
        end
        %------------------------------------------------------------------
        function assembly(obj)
            %--------------------------------------------------------------
            it = obj.ltime.it;
            %--------------------------------------------------------------
            obj.build;
            %--------------------------------------------------------------
            % Preparation
            % /!\ init all matrix since always re-assembly
            %--------------------------------------------------------------
            parent_mesh = obj.parent_mesh;
            nb_elem = parent_mesh.nb_elem;
            nb_face = parent_mesh.nb_face;
            nb_edge = parent_mesh.nb_edge;
            nb_node = parent_mesh.nb_node;
            %--------------------------------------------------------------
            obj.matrix.id_edge_a = 1:nb_edge;
            obj.matrix.id_elem_nomesh = [];
            obj.matrix.id_inner_edge_nomesh = [];
            obj.matrix.id_inner_node_nomesh = [];
            obj.matrix.id_elem_airbox = [];
            obj.matrix.id_inner_edge_airbox = [];
            obj.matrix.id_edge_airbox = [];
            obj.matrix.id_node_phi = [];
            obj.matrix.id_elem_mcon = [];
            obj.matrix.id_node_petrode = [];
            obj.matrix.id_node_netrode = [];
            %obj.matrix.id_bound_node_airbox = [];
            %--------------------------------------------------------------
            obj.matrix.sigmawewe = sparse(nb_edge,nb_edge);
            obj.matrix.nu0nurwfwf = sparse(nb_face,nb_face);
            obj.matrix.sigmavwfxwe = sparse(nb_face,nb_edge);
            %--------------------------------------------------------------
            obj.matrix.t_js = zeros(nb_edge,1);
            obj.matrix.a_bs = zeros(nb_edge,1);
            obj.matrix.a_pm = zeros(nb_edge,1);
            %--------------------------------------------------------------
            allowed_physical_dom = {'nomesh','airbox','mconductor'};
            %--------------------------------------------------------------
            obj.callsubfieldassembly('field_name',allowed_physical_dom);
            %--------------------------------------------------------------
            if ~obj.basematrix_done
                obj.basematrix;
                obj.basematrix_done = 1;
            end
            %--------------------------------------------------------------
            allowed_physical_dom = {'econductor','sibc','bsfield','coil','pmagnet','embc'};
            %--------------------------------------------------------------
            obj.callsubfieldassembly('field_name',allowed_physical_dom);
            %--------------------------------------------------------------
            id_edge_in_face = parent_mesh.meshds.id_edge_in_face;
            id_face_in_elem = parent_mesh.meshds.id_face_in_elem;
            %--------------------------------------------------------------
            % --- nomesh
            id_elem_nomesh = unique(obj.matrix.id_elem_nomesh);
            id_inner_edge_nomesh = unique(obj.matrix.id_inner_edge_nomesh);
            id_inner_node_nomesh = unique(obj.matrix.id_inner_node_nomesh);
            %--------------------------------------------------------------
            % --- airbox
            id_elem_airbox = unique(obj.matrix.id_elem_airbox);
            id_inner_edge_airbox = unique(obj.matrix.id_inner_edge_airbox);
            %id_bound_node_airbox = unique(obj.matrix.id_bound_node_airbox);
            %--------------------------------------------------------------
            id_node_phi = unique(obj.matrix.id_node_phi);
            id_elem_mcon = unique(obj.matrix.id_elem_mcon);
            id_node_netrode = unique(obj.matrix.id_node_netrode);
            id_node_petrode = unique(obj.matrix.id_node_petrode);
            %--------------------------------------------------------------
            id_edge_a_unknown   = setdiff(id_inner_edge_airbox,id_inner_edge_nomesh);
            id_node_phi_unknown = setdiff(id_node_phi,...
                [id_inner_node_nomesh id_node_netrode id_node_petrode]);
            %--------------------------------------------------------------
            %
            %               MATRIX SYSTEM
            %
            %--------------------------------------------------------------
            % --- LSH
            id_elem_air = setdiff(id_elem_airbox,[id_elem_nomesh id_elem_mcon]);
            id_face_in_elem_air = f_uniquenode(id_face_in_elem(:,id_elem_air));
            mu0 = 4 * pi * 1e-7;
            nu0wfwf = (1/mu0) .* obj.matrix.wfwfx;
            % ---
            obj.matrix.nu0nurwfwf(id_face_in_elem_air,id_face_in_elem_air) = ...
                obj.matrix.nu0nurwfwf(id_face_in_elem_air,id_face_in_elem_air) + ...
                nu0wfwf(id_face_in_elem_air,id_face_in_elem_air);
            % ---
            % S11  = obj.parent_mesh.discrete.rot.' * obj.matrix.nu0nurwfwf * obj.parent_mesh.discrete.rot;
            % S12  = obj.parent_mesh.discrete.rot.' * obj.matrix.sigmavwfxwe * obj.parent_mesh.discrete.grad;
            % S22  = obj.parent_mesh.discrete.grad.' * obj.matrix.sigmawewe * obj.parent_mesh.discrete.grad;
            % % --- dirichlet remove
            % S11 = S11(id_edge_a_unknown,id_edge_a_unknown);
            % S12 = S12(id_edge_a_unknown,:);
            % S12 = S12(:,id_node_phi_unknown);
            % S22 = S22(id_node_phi_unknown,id_node_phi_unknown);
            % % ---
            % LHS = S11;              clear S11;
            % LHS = [LHS  S12];
            % LHS = [LHS; S12.' S22]; clear S12 S22;
            % ---
            S11  = obj.parent_mesh.discrete.rot.' * obj.matrix.nu0nurwfwf * obj.parent_mesh.discrete.rot;
            S11  = S11 + obj.parent_mesh.discrete.rot.' * obj.matrix.sigmavwfxwe;
            S12  = (obj.parent_mesh.discrete.grad.' * obj.matrix.sigmawewe).';
            S21  = (obj.parent_mesh.discrete.rot.' * obj.matrix.sigmavwfxwe * obj.parent_mesh.discrete.grad).';
            S22  = obj.parent_mesh.discrete.grad.' * obj.matrix.sigmawewe * obj.parent_mesh.discrete.grad;
            % --- dirichlet remove
            S11 = S11(id_edge_a_unknown,id_edge_a_unknown);
            S22 = S22(id_node_phi_unknown,id_node_phi_unknown);
            S12 = S12(id_edge_a_unknown,:);
            S12 = S12(:,id_node_phi_unknown);
            S21 = S21(id_node_phi_unknown,:);
            S21 = S21(:,id_edge_a_unknown);
            % ---
            % LHS = blkdiag(S11,S22); clear S11 S22;
            LHS = [S11, S12; S21, S22];
            %--------------------------------------------------------------
            % --- RHS
            bsfieldRHS = obj.parent_mesh.discrete.rot.' * ...
                obj.matrix.nu0nurwfwf * ...
                obj.parent_mesh.discrete.rot * obj.matrix.a_bs;
            % ---
            pmagnetRHS = obj.parent_mesh.discrete.rot.' * ...
                ((1/mu0).* obj.matrix.wfwf) * ...
                obj.parent_mesh.discrete.rot * obj.matrix.a_pm;
            % ---
            jscoilRHS = obj.parent_mesh.discrete.rot.' * obj.matrix.wewf.' * obj.matrix.t_js;
            % ---
            %--------------------------------------------------------------
            RHS = bsfieldRHS + pmagnetRHS + jscoilRHS;
            RHS = RHS(id_edge_a_unknown,1);
            RHS = [RHS; zeros(length(id_node_phi_unknown),1)];
            %--------------------------------------------------------------
            %--------------------------------------------------------------
            obj.matrix.id_edge_a_unknown = id_edge_a_unknown;
            obj.matrix.id_node_phi_unknown = id_node_phi_unknown;
            %--------------------------------------------------------------
            obj.matrix.LHS = LHS; clear LHS;
            obj.matrix.RHS = RHS; clear RHS;
            %--------------------------------------------------------------
        end
    end
    % --- Methods/public
    methods (Access = public)
        % -----------------------------------------------------------------
        function solve(obj,args)
            arguments
                obj
                args.tol_out = 1e-3; % tolerance of outer loop
                args.tol_in  = 1e-6; % tolerance of inner loop
                args.maxniter_out = 5; % maximum iteration of outer loop
                args.maxniter_in = 1e3; % maximum iteration of inner loop
            end
            % ---
            obj.ltime.it = 0;
            while obj.ltime.t_now < obj.ltime.t_end
                obj.ltime.it = obj.ltime.it + 1;
                obj.solveone('tol_out',args.tol_out,'tol_in',args.tol_in,...
                    'maxniter_out',args.maxniter_out,'maxniter_in',args.maxniter_in);
            end
        end
        %------------------------------------------------------------------
        function solveone(obj,args)
            arguments
                obj
                args.it = []
                args.tol_out = 1e-3; % tolerance of outer loop
                args.tol_in  = 1e-6; % tolerance of inner loop
                args.maxniter_out = 5; % maximum iteration of outer loop
                args.maxniter_in = 1e3; % maximum iteration of inner loop
            end
            % --- which it
            if isempty(args.it)
                it = obj.ltime.it;
            else
                it = args.it;
                obj.ltime.it = it;
            end
            %--------------------------------------------------------------
            % ---
            obj.parent_mesh.build;
            % ---
            if it > length(obj.dof)
                obj.dof{it}.A = EdgeDof('parent_model',obj);
                obj.dof{it}.V = NodeDof('parent_model',obj);
                obj.dof{it}.B = FaceDof('parent_model',obj);
                obj.dof{it}.E = EdgeDof('parent_model',obj);
            end
            %-----------------------------------------------------------------
            obj.field{it}.A.elem = ...
                EdgeDofBasedVectorElemField('parent_model',obj,'dof',obj.dof{it}.A);
            obj.field{it}.V.node = ...
                NodeDofBasedScalarNodeField('parent_model',obj,'dof',obj.dof{it}.V);
            obj.field{it}.B.elem = ...
                FaceDofBasedVectorElemField('parent_model',obj,'dof',obj.dof{it}.B);
            % obj.field{it}.E.elem = ...
            %     EdgeDofBasedVectorElemField('parent_model',obj,'dof',obj.dof{it}.E);
            % obj.field{it}.E.face = ...
            %     EdgeDofBasedVectorFaceField('parent_model',obj,'dof',obj.dof{it}.E);
            %-----------------------------------------------------------------
            % obj.field{it}.H.elem = ...
            %     HAphiElemField('parent_model',obj,'Bfield',obj.field{it}.B.elem);
            % obj.field{it}.J.elem = ...
            %     JAphiElemField('parent_model',obj,'Efield',obj.field{it}.E.elem);
            % obj.field{it}.J.face = ...
            %     JAphiFaceField('parent_model',obj,'Efield',obj.field{it}.E.face);
            % obj.field{it}.P.elem = ...
            %     PAphiElemField('parent_model',obj,'Efield',obj.field{it}.E.elem,...
            %     'Jfield',obj.field{it}.J.elem);
            % obj.field{it}.P.face = ...
            %     PAphiFaceField('parent_model',obj,'Efield',obj.field{it}.E.face,...
            %     'Jfield',obj.field{it}.J.face);
            %------------------------------------------------------------------
            % obj.field{it}.Wm.elem = ...
            %     WmAphiElemField('parent_model',obj,'Bfield',obj.field{it}.B.elem,...
            %     'Hfield',obj.field{it}.H.elem);
            %------------------------------------------------------------------
            if it > 1
                %--------------------------------------------------------------
                f_fprintf(0,'Solveone',1,class(obj),0,'it ---',1,num2str(it),0,'\n');
                %--------------------------------------------------------------
                tol_out = args.tol_out;
                maxniter_out = args.maxniter_out;
                tol_in = args.tol_in;
                maxniter_in = args.maxniter_in;
                %--------------------------------------------------------------
                improvement = 1;
                niter_out = 0;
                % ---
                while improvement > tol_out && niter_out < maxniter_out
                    % ---
                    obj.assembly;
                    % ---
                    niter_out = niter_out + 1;
                    f_fprintf(0,'--- iter-out',1,niter_out);
                    %----------------------------------------------------------
                    % --- size
                    id_edge_a_unknown = obj.matrix.id_edge_a_unknown;
                    id_node_phi_unknown = obj.matrix.id_node_phi_unknown;
                    nb_edge = obj.parent_mesh.nb_edge;
                    nb_node = obj.parent_mesh.nb_node;
                    % ---
                    len_sol = length(obj.matrix.RHS);
                    len_a_unknown = length(id_edge_a_unknown);
                    len_phi_unknown = length(id_node_phi_unknown);
                    len_dphi_unknown = len_sol - (len_a_unknown + len_phi_unknown);
                    %----------------------------------------------------------
                    % ---
                    if niter_out == 1
                        if it == 1
                            x0 = [obj.dof{it}.A.value(id_edge_a_unknown); ...
                                  obj.dof{it}.V.value(id_node_phi_unknown); ...
                                  zeros(len_dphi_unknown,1)];
                        else
                            if any(obj.dof{it}.A.value) || any(obj.dof{it}.V.value)
                                x0 = [obj.dof{it}.A.value(id_edge_a_unknown); ...
                                      obj.dof{it}.V.value(id_node_phi_unknown); ...
                                      zeros(len_dphi_unknown,1)];
                            else
                                x0 = [obj.dof{it-1}.A.value(id_edge_a_unknown); ...
                                      obj.dof{it-1}.V.value(id_node_phi_unknown); ...
                                      zeros(len_dphi_unknown,1)];
                            end
                        end
                    end
                    % --- qmr + jacobi
                    M = sqrt(diag(diag(obj.matrix.LHS)));
                    [x,flag,relres,niter,resvec] = ...
                        qmr(obj.matrix.LHS, obj.matrix.RHS, ...
                            tol_in, maxniter_in, M.', M, x0);
                    % ---
                    if niter_out == 1
                        % out-loop one more time
                        if any(x0)
                            improvement = norm(x0 - x)/norm(x0);
                        else
                            improvement = 1;
                        end
                        x0 = x;
                    elseif niter >= 1
                        % for linear prob, niter = 0 for 2nd out-loop
                        improvement = norm(x0 - x)/norm(x0);
                        x0 = x;
                    else
                        improvement = 0;
                    end
                    % ---
                    f_fprintf(0,'improvement',1,improvement*100,0,'%% \n');
                    f_fprintf(0,'--- iter-in',1,niter,0,'relres',1,relres,0,'\n');
                    %------------------------------------------------------
                    % --- update now, for assembly
                    %------------------------------------------------------
                    obj.dof{it}.A.value(id_edge_a_unknown) ...
                        = x(1:len_a_unknown);
                    %----------------------------------------------------------------------
                    Vvalue = zeros(obj.parent_mesh.nb_node,1);
                    Vvalue(id_node_phi_unknown) = x(len_a_unknown+1 : len_a_unknown+len_phi_unknown);
                    %----------------------------------------------------------------------
                    obj.dof{it}.V.value = Vvalue; % + 1/jome .* alphaV;
                    %----------------------------------------------------------------------
                    obj.dof{it}.B.value = obj.parent_mesh.discrete.rot * obj.dof{it}.A.value;
                    %----------------------------------------------------------------------
                end
            end
        end
        % -------------------------------------------------------------------------
        function postpro(obj)
            %----------------------------------------------------------------------
            it = obj.ltime.it;
            %----------------------------------------------------------------------

            %----------------------------------------------------------------------
            id_coil__ = {};
            if ~isempty(obj.coil)
                id_coil__ = fieldnames(obj.coil);
            end
            % --- VsCoil
            for iec = 1:length(id_coil__)
                %------------------------------------------------------------------
                id_phydom = id_coil__{iec};
                coil = obj.coil.(id_phydom);
                %------------------------------------------------------------------
                if isa(coil,'VsCoil')
                    alpha  = coil.matrix.alpha;
                    coil.I(it) = - (obj.matrix.sigmawewe * obj.dof{it}.E.value).' ...
                                 * (obj.parent_mesh.discrete.grad * alpha);
                end
                if isa(coil,'IsCoil')
                    alpha  = coil.matrix.alpha;
                    coil.I(it) = - (obj.matrix.sigmawewe * obj.dof{it}.E.value).' ...
                                 * (obj.parent_mesh.discrete.grad * alpha);
                end
                %------------------------------------------------------------------
                coil.getcircuitquantity;
                %------------------------------------------------------------------
            end
            %----------------------------------------------------------------------
        end
    end
end