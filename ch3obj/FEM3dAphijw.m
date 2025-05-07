%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
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

classdef FEM3dAphijw < FEM3dAphi
    properties (Access = private)
        build_done = 0
        base_matrix_done = 0
    end
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'parent_mesh','frequency'};
        end
    end
    % --- Constructor
    methods
        function obj = FEM3dAphijw(args)
            arguments
                args.parent_mesh {mustBeA(args.parent_mesh,'Mesh3d')}
                args.frequency = 0
            end
            % ---
            obj@FEM3dAphi;
            % ---
            obj <= args;
            % ---
            
            % ---
        end
    end
    % --- setup
    methods (Static)
        function setup(obj)
            obj.build_done = 0;
            obj.base_matrix_done = 0;
            obj.parent_mesh.is_defining_obj_of(obj);
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
            % ---
            if ~obj.base_matrix_done
                obj.build_base_matrix;
                obj.base_matrix_done = 1;
            end
            %---
            obj.build_done = 1;
            % ---
        end
        %------------------------------------------------------------------
        function assembly(obj)
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
            obj.matrix.id_node_phi = [];
            obj.matrix.id_elem_mcon = [];
            obj.matrix.id_node_petrode = [];
            obj.matrix.id_node_netrode = [];
            obj.matrix.sigmawewe = sparse(nb_edge,nb_edge);
            obj.matrix.nu0nurwfwf = sparse(nb_face,nb_face);
            obj.dof.t_js = sparse(nb_edge,1);
            obj.dof.a_bs = sparse(nb_edge,1);
            obj.dof.a_pm = sparse(nb_edge,1);
            %--------------------------------------------------------------
            if isempty(obj.airbox)
                if ~isfield(obj.parent_mesh.dom,'whole_mesh_dom')
                    obj.parent_mesh.add_whole_mesh_dom;
                end
                obj.airbox.by_default_airbox = ...
                    AirboxAphi('parent_model',obj,'id_dom3d','whole_mesh_dom');
            end
            %--------------------------------------------------------------
            allowed_physical_dom = {'econductor','mconductor','airbox','sibc',...
                'bsfield','coil','nomesh','pmagnet','embc'};
            %--------------------------------------------------------------
            obj.callsubfieldassembly('field_name',allowed_physical_dom);
            %--------------------------------------------------------------
            id_edge_in_face = parent_mesh.meshds.id_edge_in_face;
            id_face_in_elem = parent_mesh.meshds.id_face_in_elem;
            %--------------------------------------------------------------
            % --- nomesh
            id_elem_nomesh = obj.matrix.id_elem_nomesh;
            id_inner_edge_nomesh = obj.matrix.id_inner_edge_nomesh;
            id_inner_node_nomesh = obj.matrix.id_inner_node_nomesh;
            %--------------------------------------------------------------
            % --- airbox
            id_elem_airbox = obj.matrix.id_elem_airbox;
            id_inner_edge_airbox = obj.matrix.id_inner_edge_airbox;
            %--------------------------------------------------------------
            id_node_phi = obj.matrix.id_node_phi;
            id_elem_mcon = obj.matrix.id_elem_mcon;
            id_node_netrode = obj.matrix.id_node_netrode;
            id_node_petrode = obj.matrix.id_node_petrode;
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
            freq = obj.frequency;
            jome = 1j*2*pi*freq;
            S11  = obj.parent_mesh.discrete.rot.' * obj.matrix.nu0nurwfwf * obj.parent_mesh.discrete.rot;
            S11  = S11 + jome .* obj.matrix.sigmawewe;
            S12  = jome .* obj.matrix.sigmawewe * obj.parent_mesh.discrete.grad;
            S22  = jome .* obj.parent_mesh.discrete.grad.' * obj.matrix.sigmawewe * obj.parent_mesh.discrete.grad;
            % --- dirichlet remove
            S11 = S11(id_edge_a_unknown,id_edge_a_unknown);
            S12 = S12(id_edge_a_unknown,:);
            S12 = S12(:,id_node_phi_unknown);
            S22 = S22(id_node_phi_unknown,id_node_phi_unknown);
            % ---
            LHS = S11;              clear S11;
            LHS = [LHS  S12];
            LHS = [LHS; S12.' S22]; clear S12 S22;
            %--------------------------------------------------------------
            % --- RHS
            bsfieldRHS = - obj.parent_mesh.discrete.rot.' * ...
                obj.matrix.nu0nurwfwf * ...
                obj.parent_mesh.discrete.rot * obj.dof.a_bs;
            pmagnetRHS =   obj.parent_mesh.discrete.rot.' * ...
                ((1/mu0).* obj.matrix.wfwf) * ...
                obj.parent_mesh.discrete.rot * obj.dof.a_pm;
            jscoilRHS  =   obj.parent_mesh.discrete.rot.' * obj.matrix.wewf.' * obj.dof.t_js;
            %--------------------------------------------------------------
            RHS = bsfieldRHS + pmagnetRHS + jscoilRHS;
            RHS = RHS(id_edge_a_unknown,1);
            RHS = [RHS; zeros(length(id_node_phi_unknown),1)];
            %--------------------------------------------------------------
            id_coil__ = {};
            if ~isempty(obj.coil)
                id_coil__ = fieldnames(obj.coil);
            end
            % ---
            for iec = 1:length(id_coil__)
                %----------------------------------------------------------
                id_phydom = id_coil__{iec};
                coil = obj.coil.(id_phydom);
                %----------------------------------------------------------
                if isa(coil,'IsCoilAphi')
                    %------------------------------------------------------
                    f_fprintf(0,'--- #coil/iscoil',1,id_phydom,0,'\n');
                    %------------------------------------------------------
                    alpha  = coil.matrix.alpha;
                    i_coil = coil.matrix.i_coil;
                    %------------------------------------------------------
                    S13 = jome * (obj.matrix.sigmawewe * obj.parent_mesh.discrete.grad * alpha);
                    S23 = jome * (obj.parent_mesh.discrete.grad.' * obj.matrix.sigmawewe * obj.parent_mesh.discrete.grad * alpha);
                    S33 = jome * (alpha.' * obj.parent_mesh.discrete.grad.' * obj.matrix.sigmawewe * obj.parent_mesh.discrete.grad * alpha);
                    S13 = S13(id_edge_a_unknown,1);
                    S23 = S23(id_node_phi_unknown,1);
                    LHS = [LHS [S13;  S23]];
                    LHS = [LHS; S13.' S23.' S33];
                    RHS = [RHS; i_coil];
                    %------------------------------------------------------
                elseif isa(coil,'VsCoilAphi')
                    %------------------------------------------------------
                    f_fprintf(0,'--- #coil/vscoil',1,id_phydom,0,'\n');
                    %------------------------------------------------------
                    Voltage  = coil.matrix.v_coil;
                    alpha    = coil.matrix.alpha;
                    %------------------------------------------------------
                    vRHSed = - obj.matrix.sigmawewe * obj.parent_mesh.discrete.grad * (alpha .* Voltage);
                    vRHSed = vRHSed(id_edge_a_unknown);
                    %------------------------------------------------------
                    vRHSno = - obj.parent_mesh.discrete.grad.'  * obj.matrix.sigmawewe * ...
                        obj.parent_mesh.discrete.grad * (alpha .* Voltage);
                    vRHSno = vRHSno(id_node_phi_unknown);
                    %------------------------------------------------------
                    RHS = RHS + [vRHSed; vRHSno];
                end
            end
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
        function solve(obj)
            %--------------------------------------------------------------
            f_fprintf(0,'Solve',1,class(obj),0,'\n');
            f_fprintf(0,'   ');
            %--------------------------------------------------------------
            erro0 = 1;
            tole0 = 1e-3;
            maxi0 = 10;
            erro1 = 1;
            tole1 = 1e-6;
            maxi1 = 1e3;
            %--------------------------------------------------------------
            nite0 = 0;
            % ---
            while erro0 > tole0 & nite0 < maxi0
                % ---
                obj.build_done = 0;
                obj.assembly_done = 0;
                obj.assembly;
                % ---
                nite0 = nite0 + 1;
                f_fprintf(0,'--- iter-out',1,nite0);
                % ---
                if nite0 == 1
                    x0 = [];
                end
                % ---
                M = sqrt(diag(diag(obj.matrix.LHS)));
                [x,flag,relres,niter,resvec] = ...
                    qmr(obj.matrix.LHS,obj.matrix.RHS,tole1,maxi1,M.',M,x0);
                % ---
                if nite0 == 1
                    erro0 = 1;
                    x0 = x;
                elseif niter > 1
                    erro0 = norm(x - x0)/norm(x);
                    x0 = x;
                else
                    erro0 = 0;
                    x = x0;
                end
                % ---
                f_fprintf(0,'e',1,erro0,0,'\n');
                f_fprintf(0,'--- iter-in',1,niter,0,'relres',1,relres,0,'\n');
                
            end
        end
        %------------------------------------------------------------------
        function solveone(obj,args)
            arguments
                obj
                args.it = []
                args.tol_out = 1e-3; % tolerance of outer loop
                args.tol_in  = 1e-6; % tolerance of inner loop
                args.maxniter_out = 3; % maximum iteration of outer loop
                args.maxniter_in = 1e3; % maximum iteration of inner loop
            end
            % --- which it
            if isempty(args.it)
                it = obj.ltime.it; % it = obj.gtime.it ??
            else
                it = args.it;
                obj.ltime.it = it;
            end
            %--------------------------------------------------------------
            % ---
            obj.dof{it}.A = ...
                EdgeDof('parent_model',obj);
            obj.dof{it}.Phi = ...
                NodeDof('parent_model',obj);
            % ---
            if it == 1
                x0 = [obj.dof{it}.A.value, obj.dof{it}.Phi.value].';
            else
                x0 = [obj.dof{it-1}.A.value, obj.dof{it-1}.Phi.value].';
            end
            %--------------------------------------------------------------
            obj.field{it}.A.elem = ...
                AelemField('parent_model',obj,'dof',obj.dof{it}.A);
            obj.field{it}.A.face = ...
                AfaceField('parent_model',obj,'dof',obj.dof{it}.A);
            %--------------------------------------------------------------
            f_fprintf(0,'Solveone',1,class(obj),0,'it ---',1,num2str(it),0,'\n');
            %----------------------------------------------------------
            tol_out = args.tol_out;
            maxniter_out = args.maxniter_out;
            tol_in = args.tol_in;
            maxniter_in = args.maxniter_in;
            %----------------------------------------------------------
            erro = 1;
            niter_out = 0;
            % ---
            while erro > tol_out && niter_out < maxniter_out
                % ---
                obj.assembly;
                % ---
                niter_out = niter_out + 1;
                f_fprintf(0,'--- iter-out',1,niter_out);
                % ---
                if niter_out == 1
                    x0 = [];
                end
                % --- qmr + jacobi
                M = sqrt(diag(diag(obj.matrix.LHS)));
                [x,flag,relres,niter,resvec] = ...
                    qmr(obj.matrix.LHS, obj.matrix.RHS, ...
                        tol_in, maxniter_in, M.', M, x0);
                % ---
                if niter_out == 1
                    % out-loop one more time
                    erro = 1;
                    x0 = x;
                elseif niter > 1
                    % for linear prob, niter = 0 for 2nd out-loop
                    erro = norm(x0 - x)/norm(x0);
                    x0 = x;
                else
                    erro = 0;
                end
                % ---
                f_fprintf(0,'e',1,erro,0,'\n');
                f_fprintf(0,'--- iter-in',1,niter,0,'relres',1,relres,0,'\n');
                %------------------------------------------------------
                % --- update now, for assembly
                %------------------------------------------------------
                % ---
                obj.dof{it}.T.value = zeros(obj.parent_mesh.nb_node,1);
                obj.dof{it}.T.value(obj.matrix.id_node_t) = x;
                %----------------------------------------------------------------------
                % --- postpro
                id_edge_a_unknown = obj.matrix.id_edge_a_unknown;
                id_node_phi_unknown = obj.matrix.id_node_phi_unknown;
                nb_edge = obj.parent_mesh.nb_edge;
                nb_node = obj.parent_mesh.nb_node;
                % ---
                len_sol = length(x);
                len_a_unknown = length(id_edge_a_unknown);
                len_phi_unknown = length(id_node_phi_unknown);
                % ---
                obj.dof.a   = zeros(nb_edge,1);
                obj.dof.phi = zeros(nb_node,1);
                obj.dof.a(id_edge_a_unknown)     = x(1:len_a_unknown);
                obj.dof.phi(id_node_phi_unknown) = x(len_a_unknown+1 : ...
                    len_a_unknown+len_phi_unknown);
                %----------------------------------------------------------------------
                obj.dof.dphiv = 0;
                if (len_a_unknown + len_phi_unknown) < len_sol
                    obj.dof.dphiv = x(len_a_unknown+len_phi_unknown+1 : len_sol);
                end
                %----------------------------------------------------------------------
                freq = obj.frequency;
                jome = 1j*2*pi*freq;
                % ---
                obj.dof.b = obj.parent_mesh.discrete.rot * obj.dof.a;
                obj.dof.e = -jome .* (obj.dof.a + obj.parent_mesh.discrete.grad * obj.dof.phi);
                %----------------------------------------------------------------------
                %------------------------------------------------------
            end
        end
        % -----------------------------------------------------------------------------
        function postpro(obj)
            %--------------------------------------------------------------------------
            parent_mesh = obj.parent_mesh;
            nb_elem = parent_mesh.nb_elem;
            nb_face = parent_mesh.nb_face;
            nb_edge = parent_mesh.nb_edge;
            nb_node = parent_mesh.nb_node;
            %--------------------------------------------------------------------------
            obj.field.av = obj.parent_mesh.field_we('dof',obj.dof.a);
            obj.field.bv = obj.parent_mesh.field_wf('dof',obj.dof.b);
            obj.field.ev = obj.parent_mesh.field_we('dof',obj.dof.e);
            obj.field.phiv = obj.parent_mesh.field_wn('dof',obj.dof.phi);
            obj.field.phi = obj.dof.phi;
            % -------------------------------------------------------------------------
            obj.field.jv = sparse(3,nb_elem);
            obj.field.pv = sparse(1,nb_elem);
            obj.field.js = sparse(2,nb_face);
            obj.field.ps = sparse(1,nb_face);
            %--------------------------------------------------------------------------
            %allowed_physical_dom = {'econductor','sibc','coil'};
            allowed_physical_dom = {'econductor','sibc'};
            %--------------------------------------------------------------------------
            for i = 1:length(allowed_physical_dom)
                phydom_type = allowed_physical_dom{i};
                % ---
                if isprop(obj,phydom_type)
                    if isempty(obj.(phydom_type))
                        continue
                    end
                else
                    continue
                end
                % ---
                allphydomid = fieldnames(obj.(phydom_type));
                for j = 1:length(allphydomid)
                    id_phydom = allphydomid{j};
                    phydom = obj.(phydom_type).(id_phydom);
                    % ---
                    f_fprintf(0,['--- #' phydom_type],1,id_phydom,0,'\n');
                    % ---
                    phydom.postpro;
                end
            end
            %--------------------------------------------------------------------------
        end
    end
end