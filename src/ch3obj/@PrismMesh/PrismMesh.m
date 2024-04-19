%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef PrismMesh < Mesh3d

    % --- Properties
    properties

    end

    % --- Dependent Properties
    properties (Dependent = true)

    end

    % --- Constructors
    methods
        function obj = PrismMesh(args)
            arguments
                args.node
                args.elem
            end
            % ---
            obj = obj@Mesh3d;
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
            % ---
        end
    end

    % --- setup
    methods
        function setup(obj)
            if obj.setup_done
                return
            end
            % ---
            obj.elem_type = 'prism';
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
            if isempty(obj.face)
                obj.build_meshds('get','face');
            end
            %--------------------------------------------------------------
            clear msh;
            %--------------------------------------------------------------
            boface = f_boundface(obj.elem,obj.node,'elem_type','prism');
            allfac = 1:size(boface,2);
            %--------------------------------------------------------------
            if f_strcmpi(args.coordinate_system,'global')
                %msh.Vertices = obj.moving_frame;
                msh.Vertices = obj.node.';
            else
                msh.Vertices = obj.node.';
            end
            %--------------------------------------------------------------
            msh.FaceColor = face_color_;
            msh.EdgeColor = edge_color_; % [0.7 0.7 0.7] --> gray
            %--------------------------------------------------------------
            id_tria = find(boface(4,:) == 0);
            id_quad = setdiff(allfac,id_tria);
            % ---
            msh.Faces = f_unique(boface(1:3,id_tria)).';
            patch(msh); hold on
            msh.Faces = f_unique(boface(1:4,id_quad)).';
            patch(msh); hold on
            % ---
            xlabel('x (m)'); ylabel('y (m)');
            if size(obj.node,1) == 3
                zlabel('z (m)'); 
            end
            axis equal; axis tight; alpha(alpha_); view(3); hold on
            %--------------------------------------------------------------
            f_chlogo;
        end
        % -----------------------------------------------------------------
    end

    % --- Methods
    methods (Static)
        function refelem = reference(obj)
            refelem.nbNo_inEl = 6;
            refelem.nbNo_inEd = 2;
            refelem.EdNo_inEl = [1 2; 1 3; 1 4; 2 3; 2 5; 3 6; 4 5; 4 6; 5 6];
            refelem.siNo_inEd = [+1, -1]; % w.r.t edge
            refelem.FaNo_inEl = [1 2 3 0; 4 5 6 0; 1 2 5 4; 1 3 6 4; 2 3 6 5]; % tri first then quad
            %-----
            refelem.NoFa_ofEd = [4 5; 3 5; 1 2; 3 4; 1 2; 1 2; 4 5; 3 5; 3 4]; % !!! F(i,~j) - circular
            refelem.NoFa_ofFa = [4 3 5 0; 4 3 5 0; 4 1 5 2; 3 1 5 2; 3 1 4 2]; % !!! F(i,~i+1) - circular
            %-----
            refelem.nbNo_inFa = [      3;       3;       4;       4;       4];
            refelem.FaType    = [      1;       1;       2;       2;       2];
            refelem.nbEd_inFa{1} = 3; % for FaType 1
            refelem.nbEd_inFa{2} = 4; % for FaType 2
            refelem.EdNo_inFa{1} = [1 2; 1 3; 2 3];      % for FaType 1
            refelem.EdNo_inFa{2} = [1 2; 1 4; 2 3; 3 4]; % for FaType 2
            refelem.FaEd_inEl = [];
            refelem.siFa_inEl = [];
            refelem.siEd_inEl = [];
            refelem.siEd_inFa{1} = [1 -1 1];   % w.r.t face for FaType 1
            refelem.siEd_inFa{2} = [1 -1 1 1]; % w.r.t face for FaType 2
            %-----
            refelem.nbEd_inEl = size(refelem.EdNo_inEl,1);
            refelem.nbFa_inEl = size(refelem.FaNo_inEl,1);
            %----- Gauss points
            refelem.U   =       1/2*[ 1  0  1  1  0  1];
            refelem.V   =       1/2*[ 1  1  0  1  1  0];
            refelem.W   = sqrt(3)/3*[-1 -1 -1  1  1  1];
            refelem.Weigh =     1/6*[ 1  1  1  1  1  1];
            refelem.cU  = 1/3;
            refelem.cV  = 1/3;
            refelem.cW  = 0;
            refelem.cWeigh  = 1;
            refelem.nbG = length(refelem.U);
            % ---
            refelem.nbI = 7;
            e = 1e-6;
            refelem.nU = [+0 +1 +0 +0 +1 +0];
            refelem.nV = [+0 +0 +1 +0 +0 +1];
            refelem.nW = [-1 -1 -1 +1 +1 +1];
            refelem.iU = [(1-e) * refelem.nU    1/3];
            refelem.iV = [(1-e) * refelem.nV    1/3];
            refelem.iW = [(1-e) * refelem.nW    0];
            %-----
            refelem.N{1} = @(u,v,w) 1/2.*(1-u-v).*(1-w);
            refelem.N{2} = @(u,v,w) 1/2.*(    u).*(1-w);
            refelem.N{3} = @(u,v,w) 1/2.*(    v).*(1-w);
            refelem.N{4} = @(u,v,w) 1/2.*(1-u-v).*(1+w);
            refelem.N{5} = @(u,v,w) 1/2.*(    u).*(1+w);
            refelem.N{6} = @(u,v,w) 1/2.*(    v).*(1+w);
            refelem.gradNx = @(u,v,w) [w/2 - 1/2;       1/2 - w/2;       0*u;      -w/2 - 1/2; w/2 + 1/2;       0*u];
            refelem.gradNy = @(u,v,w) [w/2 - 1/2;             0*v; 1/2 - w/2;      -w/2 - 1/2;       0*v; w/2 + 1/2];
            refelem.gradNz = @(u,v,w) [u/2 + v/2 - 1/2;      -u/2;      -v/2; 1/2 - u/2 - v/2;       u/2;       v/2];
            % ---
        end
    end
end



