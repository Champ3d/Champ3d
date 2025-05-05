%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef VisualSurface3d < Xhandle

    properties
        parent_model
        id_dom3d
        parallel_line_1
        parallel_line_2
        dtype_parallel
        dtype_orthogonal
        dnum_parallel
        dnum_orthogonal
        flog = 1.05;
        % ---
        mesh
        field
        % ---
        cut_equation
        %gid_elem
        %gid_side_node_1
        %gid_side_node_2
    end

    properties (Access = private)
        setup_done = 0
        build_done = 0
    end

    % --- Dependent Properties
    properties (Dependent = true)
        
    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'parent_model','parallel_line_1','parallel_line_2', ...
                        'dtype_parallel','dtype_orthogonal','dnum_parallel', ...
                        'dnum_orthogonal','flog','id_dom3d'};
        end
    end
    % --- Constructors
    methods
        function obj = VisualSurface3d(args)
            arguments
                % ---
                args.parent_model = []
                args.parallel_line_1 = []
                args.parallel_line_2 = []
                args.dtype_parallel {mustBeMember(args.dtype_parallel,{'lin','log+','log-','log+-','log-+','log='})} = 'lin'
                args.dtype_orthogonal {mustBeMember(args.dtype_orthogonal,{'lin','log+','log-','log+-','log-+','log='})} = 'lin'
                args.dnum_parallel = 6
                args.dnum_orthogonal = 6
                args.flog = 1.05;
                args.id_dom3d = []
            end
            % ---
            obj = obj@Xhandle;
            % ---
            obj <= args;
            % ---
            VisualSurface3d.setup(obj);
            % ---
        end
    end

    % ---
    methods (Static)
        % -----------------------------------------------------------------
        function setup(obj)
            % ---
            if obj.setup_done
                return
            end
            % ---
            if size(obj.parallel_line_1,1) == 3
                obj.parallel_line_1 = obj.parallel_line_1.';
            end
            if size(obj.parallel_line_2,1) == 3
                obj.parallel_line_2 = obj.parallel_line_2.';
            end
            % ---
            if any(f_strcmpi(obj.dtype_parallel,{'log+-','log-+','log='}))
                if mod(obj.dnum_parallel,2) ~= 0
                    obj.dnum_parallel = obj.dnum_parallel + 1;
                end
            end
            % ---
            if any(f_strcmpi(obj.dtype_orthogonal,{'log+-','log-+','log='}))
                if mod(obj.dnum_orthogonal,2) ~= 0
                    obj.dnum_orthogonal = obj.dnum_orthogonal + 1;
                end
            end
            % -------------------------------------------------------------
            obj.mesh = QuadMeshFrom3d('parallel_line_1',obj.parallel_line_1, ...
                                  'parallel_line_2',obj.parallel_line_2, ...
                                  'dnum_orthogonal',obj.dnum_orthogonal, ...
                                  'dnum_parallel',obj.dnum_parallel, ...
                                  'dtype_orthogonal',obj.dtype_orthogonal, ...
                                  'dtype_parallel',obj.dtype_parallel, ...
                                  'flog',obj.flog);
            % ---
            obj.setup_done = 1;
            obj.build_done = 0;
        end
        % -----------------------------------------------------------------
    end
    methods (Access = public)
        function reset(obj)
            % ---
            obj.setup_done = 0;
            VisualSurface3d.setup(obj);
            % --- reset dependent obj
            obj.reset_dependent_obj;
        end
    end
    % methods
    %     function build(obj)
    %         % ---
    %         VisualSurface3d.setup(obj);
    %         % ---
    %         if obj.build_done
    %             return
    %         end
    %         % ---
    %         obj.build_defining_obj;
    %         % ---
    %         obj.build_done = 1;
    %         % ---
    %     end
    % end

    % ---------------------------------------------------------------------
    methods
        function add_field(obj,args)
            arguments
                obj
                args.id = 'field01'
                args.field {mustBeA(args.field,{'ScalarNodeField'})}
            end
            % ---
            if isa(args.field,'ScalarNodeField')
                visfield = VisualScalarNodeField;
            end
            % ---
            obj.field.(args.id) = visfield;
            % ---
        end
    end

    % ---------------------------------------------------------------------
    methods
        % --- XTODO
        function get_cutelem(obj)
            % ---
            bl = obj.parallel_line_1(1,:);
            br = obj.parallel_line_1(2,:);
            tl = obj.parallel_line_2(1,:);
            % ---
            vec1 = br - bl;
            vec2 = tl - bl;
            % ---
            ci = cross(vec1,vec2);
            ci = f_normalize(f_tocolv(ci));
            % ---
            d = (ci(1)*bl(1) + ci(2)*bl(2) + ci(3)*bl(3));
            % ---
            obj.cut_equation = [num2str(ci(1)) '*x+' ...
                                num2str(ci(2)) '*y+' ...
                                num2str(ci(3)) '*z =' num2str(d)];
            % ---
            gid_elem_ = [];
            iddom3 = f_to_scellargin(obj.id_dom3d);
            for i = 1:length(iddom3)
                dom2cut = obj.parent_model.parent_mesh.dom.(iddom3{i});
                gid_e = dom2cut.get_cutelem('cut_equation',obj.cut_equation);
                gid_elem_ = [gid_elem_ gid_e];
            end
            % ---
            nbNo_inEl = size(obj.parent_mesh.elem,1);
            cx = reshape(obj.parent_mesh.node(1,obj.parent_mesh.elem(:,gid_elem_)),...
                         nbNo_inEl,[]);
            cy = reshape(obj.parent_mesh.node(2,obj.parent_mesh.elem(:,gid_elem_)),...
                         nbNo_inEl,[]);
            cz = reshape(obj.parent_mesh.node(3,obj.parent_mesh.elem(:,gid_elem_)),...
                         nbNo_inEl,[]);
            % ---
            xmin = min([obj.parallel_line_1(:,1);obj.parallel_line_2(:,1)]);
            ymin = min([obj.parallel_line_1(:,2);obj.parallel_line_2(:,2)]);
            zmin = min([obj.parallel_line_1(:,3);obj.parallel_line_2(:,3)]);
            xmax = max([obj.parallel_line_1(:,1);obj.parallel_line_2(:,1)]);
            ymax = max([obj.parallel_line_1(:,2);obj.parallel_line_2(:,2)]);
            zmax = max([obj.parallel_line_1(:,3);obj.parallel_line_2(:,3)]);
            % ---
            cx = sum(cx >= xmin - 1e-9 & cx <= xmax + 1e-9, 1);
            cy = sum(cy >= ymin - 1e-9 & cy <= ymax + 1e-9, 1);
            cz = sum(cz >= zmin - 1e-9 & cz <= zmax + 1e-9, 1);
            % ---
            gid_elem_ = gid_elem_(cx > 0 | cy > 0 | cz > 0);
            % ---
            obj.gid_elem = gid_elem_;
            % ---
        end
    end
    % ---------------------------------------------------------------------
    methods
        % --- XTODO
        function plot(obj,args)
            arguments
                obj
                args.edge_color = [0.4940 0.1840 0.5560]
                args.face_color = 'c'
                args.alpha {mustBeNumeric} = 0.9
                args.id_field = []
                args.showcutdom = 0
            end
            % ---
            mshalone  = 1;
            forcomplx = 1;
            forvector = 1;
            fval      = [];
            for3d     = 0;
            % ---
            id_field = args.id_field;
            if ~isempty(id_field)
                if isfield(obj.field,id_field)
                    fval = obj.field.(id_field);
                end
            end
            % ---
            if ~isempty(fval)
                mshalone = 0;
                fval = f_column_format(fval);
            end
            %--------------------------------------------------------------
            edge_color_  = args.edge_color;
            face_color_  = args.face_color;
            alpha_       = args.alpha;
            %--------------------------------------------------------------
            clear msh;
            %--------------------------------------------------------------
            node = obj.mesh.node.';
            elem = obj.mesh.elem.';
            %--------------------------------------------------------------
            msh.Vertices = node;
            msh.Faces = elem;
            msh.FaceColor = face_color_;
            msh.EdgeColor = edge_color_; % [0.7 0.7 0.7] --> gray
            %--------------------------------------------------------------
            if mshalone
                patch(msh);
                %---
                f_showaxis(3,3);
                alpha(alpha_); hold on
                %---
                if args.showcutdom
                    plot@VolumeDom3d(obj,'face_color','none','edge_color',[0.9 0.9 0.9]);
                end
                %---
                return
            end           
            %--------------------------------------------------------------
            % ---
            if isreal(fval)
                forcomplx = 0;
            end
            % ---
            if size(fval,2) == 1
                forvector = 0;
            end
            % ---
            if size(fval,2) == 3
                for3d = 1;
            end
            %--------------------------------------------------------------
            if forvector
                fx = fval(:,1);
                fy = fval(:,2);
                if for3d
                    fz = fval(:,3);
                end
            end
            %--------------------------------------------------------------
            if forvector
                if forcomplx
                    % ---
                    subplot(131);
                    msh.FaceColor = 'interp';
                    msh.FaceVertexCData = (f_magnitude(fval.')).';
                    patch(msh,'DisplayName','magnitude');
                    title('Magnitude');
                    %f_showaxis(3,3);
                    alpha(alpha_); hold on
                    % ---
                    subplot(132);
                    msh.FaceColor = 'none';
                    msh.FaceVertexCData = [];
                    patch(msh,'DisplayName','real-part'); hold on
                    f_quiver(node.',real(fval));
                    title('Real part')
                    f_showaxis(3,3);
                    alpha(alpha_); hold on
                    % ---
                    subplot(133);
                    msh.FaceColor = 'none';
                    msh.FaceVertexCData = [];
                    patch(msh,'DisplayName','imag-part'); hold on
                    f_quiver(node.',imag(fval));
                    title('Imag part')
                    f_showaxis(3,3);
                    alpha(alpha_); hold on
                else
                    % ---
                    subplot(121);
                    msh.FaceColor = 'none';
                    msh.FaceVertexCData = (f_magnitude(fval.')).';
                    patch(msh,'DisplayName','magnitude');
                    title('Magnitude');
                    f_showaxis(3,2);
                    alpha(alpha_); hold on
                    % ---
                    subplot(122);
                    msh.FaceVertexCData = [];
                    patch(msh,'DisplayName','vector-field'); hold on
                    f_quiver(node.',fval);
                    title(id_field);
                    f_showaxis(3,2);
                    alpha(alpha_); hold on
                end
            else
                if forcomplx
                    % ---
                    subplot(121);
                    msh.FaceColor = 'none';
                    msh.FaceVertexCData = real(fval);
                    patch(msh,'DisplayName','real-part');
                    title('Real part');
                    f_showaxis(3,2);
                    alpha(alpha_); hold on
                    % ---
                    subplot(122);
                    msh.FaceVertexCData = imag(fval);
                    patch(msh,'DisplayName','imag-part');
                    title('Imag part');
                    f_showaxis(3,2);
                    alpha(alpha_); hold on
                else
                    msh.FaceColor = 'none';
                    msh.FaceVertexCData = fval;
                    patch(msh);
                    title(id_field);
                    f_showaxis(3,2);
                    alpha(alpha_); hold on
                end
            end
        end
    end
    % ---------------------------------------------------------------------
    methods
        function fi = getfieldAphi(obj,field_name)
            % ---
            msh = obj.parent_mesh;
            model = obj.parent_model;
            nbI = msh.refelem.nbI;
            % ---
            vf = [];
            sf = [];
            % ---
            if any(f_strcmpi(field_name,{'b'}))
                vf = msh.field_wf('dof',model.dof.b,'on','interpolation_points');
            end
            % ---
            if any(f_strcmpi(field_name,{'e'}))
                vf = msh.field_we('dof',model.dof.e,'on','interpolation_points');
            end
            % ---
            if any(f_strcmpi(field_name,{'a'}))
                vf = msh.field_we('dof',model.dof.a,'on','interpolation_points');
            end
            % ---
            if any(f_strcmpi(field_name,{'j'}))
                % ---
                ev = msh.field_we('dof',model.dof.e,'on','interpolation_points');
                % ---
                if ~isempty(model.econductor)
                    id_econductor__ = fieldnames(model.econductor);
                end
                % ---
                for i = 1:nbI
                    vf{i} = sparse(3,msh.nb_elem);
                end
                % ---
                for i = 1:nbI
                    for iec = 1:length(id_econductor__)
                        %------------------------------------------------------
                        id_phydom = id_econductor__{iec};
                        %------------------------------------------------------
                        [coefficient, coef_array_type] = ...
                            f_column_format(model.econductor.(id_phydom).matrix.sigma_array);
                        %------------------------------------------------------
                        id_elem = model.econductor.(id_phydom).matrix.gid_elem;
                        %------------------------------------------------------
                        if any(f_strcmpi(coef_array_type,{'scalar'}))
                            %--------------------------------------------------
                            vf{i}(:,id_elem) = coefficient .* ev{i}(:,id_elem);
                            %--------------------------------------------------
                        elseif any(f_strcmpi(coef_array_type,{'tensor'}))
                            %--------------------------------------------------
                            vf{i}(1,id_elem) = coefficient(:,1,1).' .* ev{i}(1,id_elem) + ...
                                               coefficient(:,1,2).' .* ev{i}(2,id_elem) + ...
                                               coefficient(:,1,3).' .* ev{i}(3,id_elem);
                            vf{i}(2,id_elem) = coefficient(:,2,1).' .* ev{i}(1,id_elem) + ...
                                               coefficient(:,2,2).' .* ev{i}(2,id_elem) + ...
                                               coefficient(:,2,3).' .* ev{i}(3,id_elem);
                            vf{i}(3,id_elem) = coefficient(:,3,1).' .* ev{i}(1,id_elem) + ...
                                               coefficient(:,3,2).' .* ev{i}(2,id_elem) + ...
                                               coefficient(:,3,3).' .* ev{i}(3,id_elem);
                        end
                    end
                end
            end
            % -------------------------------------------------------------
            id_elem = obj.gid_elem;
            % -------------------------------------------------------------
            xi  = []; yi  = []; zi  = [];
            vfx = []; vfy = []; vfz = [];
            for i = 1:nbI
                xi = [xi; msh.prokit.node{i}(id_elem,1)];
                yi = [yi; msh.prokit.node{i}(id_elem,2)];
                zi = [zi; msh.prokit.node{i}(id_elem,3)];
                vfx = [vfx vf{i}(1,id_elem)];
                vfy = [vfy vf{i}(2,id_elem)];
                vfz = [vfz vf{i}(3,id_elem)];
            end
            % ---
            Fx = scatteredInterpolant(xi,yi,zi,full(vfx.'),'natural','linear');
            Fy = scatteredInterpolant(xi,yi,zi,full(vfy.'),'natural','linear');
            Fz = scatteredInterpolant(xi,yi,zi,full(vfz.'),'natural','linear');
            % ---
            xnode = obj.mesh.node(1,:);
            ynode = obj.mesh.node(2,:);
            znode = obj.mesh.node(3,:);
            nb_node = obj.mesh.nb_node;
            % ---
            fi = zeros(nb_node,3);
            fi(:,1) = Fx(xnode,ynode,znode);
            fi(:,2) = Fy(xnode,ynode,znode);
            fi(:,3) = Fz(xnode,ynode,znode);
            % ---
            fi = fi.';
        end
    end
    % ---------------------------------------------------------------------
    % ---------------------------------------------------------------------
end



