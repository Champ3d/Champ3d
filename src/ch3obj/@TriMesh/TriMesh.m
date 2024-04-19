%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef TriMesh < Mesh2d

    % --- Properties
    properties
        lid_face
    end

    % --- Dependent Properties
    properties (Dependent = true)

    end

    % --- Constructors
    methods
        function obj = TriMesh(args)
            arguments
                args.node
                args.elem
            end
            % ---
            obj = obj@Mesh2d;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            obj.setup_done = 0;
            % ---
            obj.setup;
        end
    end

    % --- setup
    methods
        function setup(obj)
            % ---
            if obj.setup_done
                return
            end
            % ---
            obj.elem_type = 'tri';
            obj.cal_flatnode;
            % ---
            obj.setup_done = 1;
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
                args.coordinate_system {mustBeMember(args.coordinate_system,{'local','global'})} = 'global'
            end
            edge_color_  = args.edge_color;
            face_color_  = args.face_color;
            alpha_       = args.alpha;
            %--------------------------------------------------------------
            clear msh;
            %--------------------------------------------------------------
            if f_strcmpi(args.coordinate_system,'global')
                %msh.Vertices = obj.moving_frame;
                msh.Vertices = obj.node.';
            else
                msh.Vertices = obj.node.';
            end
            %--------------------------------------------------------------
            msh.Faces = obj.elem(1:3,:).';
            msh.FaceColor = face_color_;
            msh.EdgeColor = edge_color_; % [0.7 0.7 0.7] --> gray
            %--------------------------------------------------------------
            patch(msh);
            xlabel('x (m)'); ylabel('y (m)');
            if size(obj.node,1) == 3
                zlabel('z (m)'); view(3);
            end
            axis equal; axis tight; alpha(alpha_); hold on
            %--------------------------------------------------------------
            f_chlogo;
        end
        % -----------------------------------------------------------------
    end

    % --- Methods
    methods (Static)
        function refelem = reference(obj)
            refelem.nbNo_inEl = 3;
            refelem.nbNo_inEd = 2;
            refelem.EdNo_inEl = [1 2; 1 3; 2 3];
            refelem.siNo_inEd = [+1, -1]; % w.r.t edge
            refelem.FaNo_inEl = refelem.EdNo_inEl; % face as edge
            %-----
            refelem.NoFa_ofEd = [2 3; 1 3; 1 2]; % !!! F(i,~j) - circular
            %con.NoFa_ofFa = [6 3 4 5; 6 3 4 5; 6 1 4 2; 3 1 5 2; 4 1 6 2; 3 1 5 2]; % !!! F(i,~i+1) - circular
            %-----
            refelem.nbNo_inFa = [  2;   2;   2];
            refelem.FaType    = [  1;   1;   1];
            refelem.nbEd_inFa = [];
            refelem.EdNo_inFa = [];
            refelem.FaEd_inEl = [];
            refelem.siEd_inEl = [1; -1; 1];
            refelem.siFa_inEl = refelem.siEd_inEl; % upperface convention
            refelem.siEd_inFa = [];
            %-----
            refelem.nbEd_inEl = size(refelem.EdNo_inEl,1);
            refelem.nbFa_inEl = size(refelem.FaNo_inEl,1);
            %----- Gauss points
            refelem.U   =       [1/6  2/3  1/6];
            refelem.V   =       [1/6  1/6  2/3];
            refelem.Weigh =     [1/6  1/6  1/6];
            refelem.cU  = 1/3;
            refelem.cV  = 1/3;
            refelem.cWeigh  = 1/2;
            refelem.nbG = length(refelem.U);
            % ---
            refelem.nbI = 4;
            e = 1e-6;
            refelem.nU = [0 1 0];
            refelem.nV = [0 0 1];
            refelem.iU = [(1-e) * refelem.nU    1/3];
            refelem.iV = [(1-e) * refelem.nV    1/3];
            %-----
            refelem.N{1} = @(u,v) (1-u-v);
            refelem.N{2} = @(u,v) (    u);
            refelem.N{3} = @(u,v) (    v);
            refelem.gradNx = @(u,v) [-u./u;   u./u;   0*u];
            refelem.gradNy = @(u,v) [-u./u;    0*u;  u./u];
            % ---
        end
    end

end



