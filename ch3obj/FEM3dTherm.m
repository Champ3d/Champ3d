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
                args.parent_mesh {mustBeA(args.parent_mesh,'Mesh3d')}
                args.T0 = 0
            end
            % ---
            obj = obj@ThModel;
            % ---
            obj <= args;
            % ---
        end
    end
    % --- Methods/public
    methods
        %------------------------------------------------------------------
        function build(obj)
            obj.parent_mesh.build;
        end
        %------------------------------------------------------------------
        function assembly(obj)
            %--------------------------------------------------------------
            obj.build;
            %--------------------------------------------------------------
            % Preparation
            % /!\ init all matrix since always re-assembly
            parent_mesh = obj.parent_mesh;
            nb_edge = parent_mesh.nb_edge;
            nb_node = parent_mesh.nb_node;
            %---
            obj.matrix.id_node_t  = [];
            obj.matrix.lambdawewe = sparse(nb_edge,nb_edge);
            obj.matrix.rhocpwnwn  = sparse(nb_node,nb_node);
            obj.matrix.hwnwn      = sparse(nb_node,nb_node);
            obj.matrix.pswn       = sparse(nb_node,1);
            obj.matrix.pvwn       = sparse(nb_node,1);
            %---
            obj.matrix.id_elem_nomesh = [];
            %--------------------------------------------------------------
            allowed_physical_dom = ...
                {'thconductor','thcapacitor','convection','ps','pv'};
            %--------------------------------------------------------------
            obj.callsubfieldassembly('field_name',allowed_physical_dom);
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
                delta_t = obj.ltime.t_array(obj.ltime.it) - obj.ltime.t_array(obj.ltime.it - 1);
            end
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
                args.tol_out = 1e-3;    % tolerance of outer loop
                args.tol_in  = 1e-6;    % tolerance of inner loop
                args.maxniter_out = 5;  % maximum iteration of outer loop
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
            obj.dof{it}.T = NodeDof('parent_model',obj);
            % ---
            obj.field{it}.T.elem = ...
                NodeDofBasedScalarElemField('parent_model',obj,'dof',obj.dof{it}.T,...
                'reference_potential',obj.T0);
            obj.field{it}.T.face = ...
                NodeDofBasedScalarFaceField('parent_model',obj,'dof',obj.dof{it}.T,...
                'reference_potential',obj.T0);
            obj.field{it}.T.node = ...
                NodeDofBasedScalarNodeField('parent_model',obj,'dof',obj.dof{it}.T,...
                'reference_potential',obj.T0);
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
                improvement = 1;
                niter_out = 0;
                % ---
                while improvement > tol_out && niter_out < maxniter_out
                    % ---
                    obj.assembly;
                    % ---
                    niter_out = niter_out + 1;
                    f_fprintf(0,'--- iter-out',1,niter_out);
                    % ---
                    if niter_out == 1
                        if it == 1
                            x0 = obj.dof{it}.T.value(obj.matrix.id_node_t);
                        else
                            x0 = obj.dof{it-1}.T.value(obj.matrix.id_node_t);
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
                    % ---
                    obj.dof{it}.T.value = zeros(obj.parent_mesh.nb_node,1);
                    obj.dof{it}.T.value(obj.matrix.id_node_t) = x;
                    %------------------------------------------------------
                end
            end
        end
    end
end