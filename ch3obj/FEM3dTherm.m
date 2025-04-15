%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef FEM3dTherm < ThModel

    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'parent_mesh','T0'};
        end
    end
    % --- Contructor
    methods
        function obj = FEM3dTherm(args)
            arguments
                args.parent_mesh = []
                args.T0 = 0
            end
            % ---
            argu = f_to_namedarg(args,'for','ThModel');
            obj = obj@ThModel(argu{:});
            % ---
            obj <= args;
            % ---
        end
    end
    % --- Methods/public
    methods (Access = public)
        % -----------------------------------------------------------------
        function build(obj)
            %--------------------------------------------------------------------------
            % ---
            parent_mesh = obj.parent_mesh;
            % ---
            parent_mesh.build_meshds;
            parent_mesh.build_discrete;
            parent_mesh.build_intkit;
            %--------------------------------------------------------------------------
            allowed_physical_dom = {'thconductor','thcapacitor','convection',...
                'ps','pv'};
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
                    % ---
                    f_fprintf(0,['Build #' phydom_type],1,id_phydom,0,'\n');
                    % ---
                    phydom = obj.(phydom_type).(id_phydom);
                    % ---
                    phydom.reset;
                    phydom.build;
                end
            end
            %--------------------------------------------------------------
        end
        %------------------------------------------------------------------
        function assembly(obj)
            %--------------------------------------------------------------
            obj.build;
            %--------------------------------------------------------------
            parent_mesh = obj.parent_mesh;
            nb_edge = parent_mesh.nb_edge;
            nb_node = parent_mesh.nb_node;
            %--------------------------------------------------------------
            obj.matrix.id_node_t  = [];
            obj.matrix.lambdawewe = sparse(nb_edge,nb_edge);
            obj.matrix.rhocpwnwn  = sparse(nb_node,nb_node);
            obj.matrix.hwnwn      = sparse(nb_node,nb_node);
            obj.matrix.pswn       = sparse(nb_node,1);
            obj.matrix.pvwn       = sparse(nb_node,1);
            %--------------------------------------------------------------
            obj.matrix.id_elem_nomesh = [];
            %--------------------------------------------------------------
            allowed_physical_dom = {'thconductor','thcapacitor','convection',...
                'ps','pv'};
            %--------------------------------------------------------------
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
                    f_fprintf(0,['Assembly #' phydom_type],1,id_phydom,0,'\n');
                    % ---
                    phydom.reset;
                    phydom.assembly;
                end
            end
            %--------------------------------------------------------------
            id_node_t = unique(obj.matrix.id_node_t);
            obj.matrix.id_node_t = id_node_t;
            %--------------------------------------------------------------
            %
            %               MATRIX SYSTEM
            %
            %--------------------------------------------------------------
            if obj.ltime.it <= 1
                Tprev = 0;
            else
                Tprev = obj.dof{obj.ltime.it - 1}.T.value;
            end
            delta_t = 1;
            %--------------------------------------------------------------
            % --- LSH
            LHS = (1./delta_t) .* obj.matrix.rhocpwnwn + ...
                obj.parent_mesh.discrete.grad.' * obj.matrix.lambdawewe * obj.parent_mesh.discrete.grad + ...
                obj.matrix.hwnwn;
            % ---
            LHS = LHS(id_node_t,id_node_t);
            %--------------------------------------------------------------
            % --- RHS
            RHS = obj.matrix.pvwn + obj.matrix.pswn + ...
                (1./delta_t) .* obj.matrix.rhocpwnwn * f_tocolv(Tprev);
            % ---
            RHS = RHS(id_node_t,1);
            %--------------------------------------------------------------
            obj.matrix.LHS = LHS;
            obj.matrix.RHS = RHS;
            %--------------------------------------------------------------
        end
        % -----------------------------------------------------------------
        function solve(obj)
            obj.ltime.it = 0;
            while obj.ltime.t_now <= obj.ltime.t_end
                obj.ltime.it = obj.ltime.it + 1;
                obj.solveone;
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
            end
            %--------------------------------------------------------------
            if it == 1
                % ---
                obj.dof{it}.T = ...
                    NodeDof('parent_mesh',obj.parent_mesh,'value',0);
                % ---
                x0 = obj.dof{it}.T.value;
            else
                % ---
                obj.dof{it}.T = ...
                    NodeDof('parent_mesh',obj.parent_mesh);
                % ---
                x0 = obj.dof{it-1}.T.value;
            end
            % ---
            obj.field{it}.T.elem = ...
                ScalarElemField('parent_mesh',obj.parent_mesh,'dof',obj.dof{it}.T,...
                'reference_potential',obj.T0);
            obj.field{it}.T.node = ...
                ScalarNodeField('parent_mesh',obj.parent_mesh,'dof',obj.dof{it}.T,...
                'reference_potential',obj.T0);
            % ---
            id_node_t = obj.matrix.id_node_t;
            nb_node = obj.parent_mesh.nb_node;
            %--------------------------------------------------------------
            if it > 1
                %----------------------------------------------------------
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
                        x = x0;
                    end
                    % ---
                    f_fprintf(0,'e',1,erro,0,'\n');
                    f_fprintf(0,'--- iter-in',1,niter,0,'relres',1,relres,0,'\n');
                    %------------------------------------------------------
                    % --- update now, for assembly
                    %------------------------------------------------------
                    obj.dof{it}.T.value = zeros(nb_node,1);
                    obj.dof{it}.T.value(id_node_t) = x;
                    %------------------------------------------------------
                end
            end
        end
    end
    % --- Methods/protected
    methods (Access = protected)
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
    end
    % --- Methods/public
    methods (Access = private)
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
    end
end