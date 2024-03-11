%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef Mesh2d < Mesh

    % --- Constructors
    methods
        function obj = Mesh2d()
            obj = obj@Mesh;
        end
    end

    % --- Methods
    methods
        % ---
        function add_vdom(obj,args)
            arguments
                obj
                % ---
                args.id char
                % ---
                args.id_xline = []
                args.id_yline = []
                % ---
                args.elem_code = []
                args.gid_elem = []
                args.condition char = []
            end
            % ---
            args.parent_mesh = obj;
            % ---
            argu = f_to_namedarg(args,'with_only',...
                         {'parent_mesh','id_xline','id_yline','elem_code',...
                          'gid_elem','condition'});
            vdom = VolumeDom2d(argu{:});
            obj.dom.(args.id) = vdom;
            % ---
        end
        % --- XTODO
        function add_sdom(obj,args)
            arguments
                obj
                % ---
                args.id char
                % ---
                args.mesh1d = []
                % ---
                args.id_xline = []
                args.id_yline = []
                % ---
                args.elem_code = []
                args.gid_elem = []
                args.condition char = []
            end
            % ---
            args.parent_mesh = obj;
            % ---
            argu = f_to_namedarg(args,'with_only',...
                         {'mesh1d','parent_mesh','id_xline','id_yline','elem_code',...
                          'gid_elem','condition'});
            vdom = VolumeDom2d(argu{:});
            obj.dom.(args.id) = vdom;
            % ---
        end
    end
    % --- Methods
    methods
        % -----------------------------------------------------------------
        function plot(obj,args)
            arguments
                obj
                args.edge_color = [0.4940 0.1840 0.5560]
                args.face_color = 'c'
                args.alpha {mustBeNumeric} = 0.9
                args.field_value = []
            end
            %--------------------------------------------------------------
            mshalone = 1;
            forcomplx   = 1;
            forvector   = 1;
            fval     = [];
            for3d    = 0;
            if ~isempty(args.field_value)
                mshalone = 0;
                fval = obj.column_format(args.field_value);
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
            edge_color_  = args.edge_color;
            face_color_  = args.face_color;
            alpha_       = args.alpha;
            %--------------------------------------------------------------
            clear msh;
            %--------------------------------------------------------------
            msh.Vertices = obj.node.';
            if isa(obj,'QuadMesh')
                msh.Faces = obj.elem(1:4,:).';
            elseif isa(obj,'TriMesh')
                msh.Faces = obj.elem(1:3,:).';
            end
            msh.FaceColor = face_color_;
            msh.EdgeColor = edge_color_; % [0.7 0.7 0.7] --> gray
            %--------------------------------------------------------------
            if mshalone
                patch(msh);
            else
                if forvector
                    if forcomplx
                        % ---
                        subplot(131);
                        msh.FaceVertexCData = (f_magnitude(fval.')).';
                        patch(msh,'DisplayName','magnitude');
                        % ---
                        subplot(132);
                        msh.FaceVertexCData = [];
                        patch(msh,'DisplayName','real-part'); hold on
                        f_quiver(obj.node,real(fval.'));
                        % ---
                        subplot(133);
                        msh.FaceVertexCData = [];
                        patch(msh,'DisplayName','imag-part'); hold on
                        f_quiver(obj.node,imag(fval.'));
                    else
                        % ---
                        subplot(121);
                        msh.FaceVertexCData = (f_magnitude(fval.')).';
                        patch(msh,'DisplayName','magnitude');
                        % ---
                        subplot(122);
                        msh.FaceVertexCData = [];
                        patch(msh,'DisplayName','vector-field'); hold on
                        f_quiver(obj.node,fval.');
                    end
                else
                    if forcomplx
                        % ---
                        subplot(121);
                        msh.FaceVertexCData = real(fval);
                        patch(msh,'DisplayName','real-part');
                        % ---
                        subplot(122);
                        msh.FaceVertexCData = imag(fval);
                        patch(msh,'DisplayName','imag-part');
                    else
                        msh.FaceVertexCData = fval;
                        patch(msh);
                    end
                end
            end
            %--------------------------------------------------------------
            xlabel('x (m)'); ylabel('y (m)');
            if size(obj.node,1) == 3
                zlabel('z (m)'); view(3);
            end
            axis equal; axis tight; alpha(alpha_); hold on
            %--------------------------------------------------------------
            f_chlogo;
        end
    end
end




