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
            argslist = {'parent_mesh','Temp0'};
        end
    end
    % --- Contructor
    methods
        function obj = FEM3dTherm(args)
            arguments
                args.parent_mesh = []
                args.Temp0 = 0
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
            tic;
            f_fprintf(0,'Build',1,class(obj),0,'\n');
            f_fprintf(0,'   ');
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
            %--------------------------------------------------------------------------
            %obj.build_done = 1;
            %--------------------------------------------------------------------------
        end
        %--------------------------------------------------------------------------
        function assembly(obj)
            %--------------------------------------------------------------------------
            tic;
            f_fprintf(0,'Assembly',1,class(obj),0,'\n');
            %--------------------------------------------------------------------------
            obj.build;
            %--------------------------------------------------------------------------
%             if obj.assembly_done
%                 return
%             end
            %--------------------------------------------------------------------------
            parent_mesh = obj.parent_mesh;
            nb_edge = parent_mesh.nb_edge;
            nb_node = parent_mesh.nb_node;
            %--------------------------------------------------------------------------
            obj.matrix.id_node_t  = [];
            obj.matrix.lambdawewe = sparse(nb_edge,nb_edge);
            obj.matrix.rhocpwnwn  = sparse(nb_node,nb_node);
            obj.matrix.hwnwn      = sparse(nb_node,nb_node);
            obj.matrix.pswn       = sparse(nb_node,1);
            obj.matrix.pvwn       = sparse(nb_node,1);
            obj.dof.temp          = sparse(nb_node,1);
            %--------------------------------------------------------------------------
            obj.matrix.id_elem_nomesh = [];
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
                    phydom = obj.(phydom_type).(id_phydom);
                    % ---
                    f_fprintf(0,['Assembly #' phydom_type],1,id_phydom,0,'\n');
                    % ---
                    phydom.reset;
                    phydom.assembly;
                end
            end
            %--------------------------------------------------------------------------
            id_node_t = unique(obj.matrix.id_node_t);
            %--------------------------------------------------------------------------
            %
            %               MATRIX SYSTEM
            %
            %--------------------------------------------------------------------------
            Temp_prev = obj.matrix.Temp_prev;
            delta_t = 1;
            %--------------------------------------------------------------------------
            % --- LSH
            LHS = (1./delta_t) .* obj.matrix.rhocpwnwn + ...
                obj.parent_mesh.discrete.grad.' * obj.matrix.lambdawewe * obj.parent_mesh.discrete.grad + ...
                obj.matrix.hwnwn;
            % ---
            LHS = LHS(id_node_t,id_node_t);
            %--------------------------------------------------------------------------
            % --- RHS
            RHS = obj.matrix.pvwn + obj.matrix.pswn + ...
                (1./delta_t) .* obj.matrix.rhocpwnwn * Temp_prev;
            % ---
            RHS = RHS(id_node_t,1);
            %--------------------------------------------------------------------------
            obj.matrix.LHS = LHS;
            obj.matrix.RHS = RHS;
            %--------------------------------------------------------------------------
            obj.assembly_done = 1;
            %--------------------------------------------------------------------------
        end
        % -----------------------------------------------------------------
        function solve(obj)
            %--------------------------------------------------------------------------
            f_fprintf(0,'Solve',1,class(obj),0,'\n');
            f_fprintf(0,'   ');
            %--------------------------------------------------------------------------
            erro0 = 1;
            tole0 = 1e-3;
            maxi0 = 3;
            erro1 = 1;
            tole1 = 1e-6;
            maxi1 = 1e3;
            %--------------------------------------------------------------------------
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
                    erro0 = norm(x0 - x)/norm(x0);
                    x0 = x;
                else
                    erro0 = 0;
                    x = x0;
                end
                % ---
                f_fprintf(0,'e',1,erro0,0,'\n');
                f_fprintf(0,'--- iter-in',1,niter,0,'relres',1,relres,0,'\n');
                %----------------------------------------------------------------------
                % --- postpro
                id_node_t = obj.matrix.id_node_t;
                nb_node = obj.parent_mesh.nb_node;
                %----------------------------------------------------------------------
                obj.dof.temp = zeros(nb_node,1);
                obj.dof.temp(id_node_t) = x;
                %----------------------------------------------------------------------
                obj.field.tempv = obj.parent_mesh.field_wn('dof',obj.dof.temp);
                obj.field.temp  = obj.dof.temp;
                Temp_prev = obj.dof.temp;
                %----------------------------------------------------------------------
                obj.postpro;
                %----------------------------------------------------------------------
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