%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef HexMesh < Mesh3d

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
            argslist = {'node','elem'};
        end
    end
    % --- Constructors
    methods
        function obj = HexMesh(args)
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
            HexMesh.setup(obj);
            % ---
        end
    end

    % --- setup/reset/build/assembly
    methods (Static)
        function setup(obj)
            % ---
            if obj.setup_done
                return
            end
            % ---
            setup@Mesh3d(obj);
            % ---
            obj.elem_type = 'hexa';
            % ---
            obj.setup_done = 1;
            obj.build_done = 0;
            % ---
        end
    end
    methods (Access = public)
        function reset(obj)
            % reset super
            reset@Mesh3d(obj);
            % ---
            obj.setup_done = 0;
            HexMesh.setup(obj);
            % --- reset dependent obj
            obj.reset_dependent_obj;
        end
    end
    methods
        function build(obj)
            % ---
            HexMesh.setup(obj);
            % --- call super
            build@Mesh3d(obj);
            % ---
            if obj.build_done
                return
            end
            % ---
            obj.build_done = 1;
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
                args.id_elem = []
                args.coordinate_system {mustBeMember(args.coordinate_system,{'local','global'})} = 'global'
            end
            edge_color_  = args.edge_color;
            face_color_  = args.face_color;
            alpha_       = args.alpha;
            %--------------------------------------------------------------
            %if isempty(obj.face)
            %    obj.build_meshds('get','face');
            %end
            %--------------------------------------------------------------
            clear msh;
            %--------------------------------------------------------------
            if isempty(args.id_elem)
                boface = f_boundface(obj.elem,obj.node,'elem_type','hexa');
            else
                boface = f_boundface(obj.elem(:,args.id_elem),obj.node,'elem_type','hexa');
            end
            %--------------------------------------------------------------
            if f_strcmpi(args.coordinate_system,'global')
                %msh.Vertices = obj.moving_frame;
                msh.Vertices = obj.node.';
            else
                msh.Vertices = obj.node.';
            end
            %--------------------------------------------------------------
            msh.Faces = f_unique(boface(1:4,:)).';
            msh.FaceColor = face_color_;
            msh.EdgeColor = edge_color_; % [0.7 0.7 0.7] --> gray
            %--------------------------------------------------------------
            patch(msh);
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
            refelem.nbNo_inEl = 8;
            refelem.nbNo_inEd = 2;
            refelem.EdNo_inEl = [1 2; 1 4; 1 5; 2 3; 2 6; 3 4; 3 7; 4 8; 5 6; 5 8; 6 7; 7 8];
            refelem.siNo_inEd = [+1, -1]; % w.r.t edge
            refelem.FaNo_inEl = [1 2 3 4; 5 6 7 8; 1 2 6 5; 2 3 7 6; 3 4 8 7; 1 4 8 5]; %
            % ---
            refelem.NoFa_ofEd = [6 4; 3 5; 1 2; 3 5; 1 2; 4 6; 1 2; 1 2; 6 4; 3 5; 3 5; 4 6]; % !!! F(i,~j) - circular
            refelem.NoFa_ofFa = [6 3 4 5; 6 3 4 5; 6 1 4 2; 3 1 5 2; 4 1 6 2; 3 1 5 2]; % !!! F(i,~i+1) - circular
            % ---
            refelem.nbNo_inFa = [      4;       4;       4;       4;       4;       4];
            refelem.FaType    = [      2;       2;       2;       2;       2;       2];
            refelem.nbEd_inFa{1} = 4; % for FaType 1
            refelem.nbEd_inFa{2} = 4; % for FaType 2
            refelem.EdNo_inFa{1} = [1 2; 1 4; 2 3; 3 4]; % for FaType 1
            refelem.EdNo_inFa{2} = [1 2; 1 4; 2 3; 3 4]; % for FaType 2
            refelem.FaEd_inEl = [];
            refelem.siFa_inEl = [];
            refelem.siEd_inEl = [];
            refelem.siEd_inFa{1} = [1 -1 1 1]; % w.r.t face for FaType 1
            refelem.siEd_inFa{2} = [1 -1 1 1]; % w.r.t face for FaType 2
            % ---
            refelem.nbEd_inEl = size(refelem.EdNo_inEl,1);
            refelem.nbFa_inEl = size(refelem.FaNo_inEl,1);
            % --- Gauss points
            refelem.U   = sqrt(3)/3*[-1 -1 -1 -1  1  1  1 1];
            refelem.V   = sqrt(3)/3*[-1 -1  1  1 -1 -1  1 1];
            refelem.W   = sqrt(3)/3*[-1  1 -1  1 -1  1 -1 1];
            refelem.Weigh =         [ 1  1  1  1  1  1  1 1];
            refelem.cU  = 0;
            refelem.cV  = 0;
            refelem.cW  = 0;
            refelem.cWeigh  = 8; % 2x2x2
            refelem.nbG = length(refelem.U);
            % ---
            refelem.nbI = 9;
            e = 1e-6;
            refelem.nU = [-1 +1 +1 -1 -1 +1 +1 -1];
            refelem.nV = [-1 -1 +1 +1 -1 -1 +1 +1];
            refelem.nW = [-1 -1 -1 -1 +1 +1 +1 +1];
            refelem.iU = [(1-e) * refelem.nU    0];
            refelem.iV = [(1-e) * refelem.nV    0];
            refelem.iW = [(1-e) * refelem.nW    0];
            % ---
            refelem.N{1} = @(u,v,w) 1/8.*(1-u).*(1-v).*(1-w);
            refelem.N{2} = @(u,v,w) 1/8.*(1+u).*(1-v).*(1-w);
            refelem.N{3} = @(u,v,w) 1/8.*(1+u).*(1+v).*(1-w);
            refelem.N{4} = @(u,v,w) 1/8.*(1-u).*(1+v).*(1-w);
            refelem.N{5} = @(u,v,w) 1/8.*(1-u).*(1-v).*(1+w);
            refelem.N{6} = @(u,v,w) 1/8.*(1+u).*(1-v).*(1+w);
            refelem.N{7} = @(u,v,w) 1/8.*(1+u).*(1+v).*(1+w);
            refelem.N{8} = @(u,v,w) 1/8.*(1-u).*(1+v).*(1+w);
            refelem.gradNx = @(u,v,w) [-1/8.*(1-v).*(1-w); +1/8.*(1-v).*(1-w); +1/8.*(1+v).*(1-w); -1/8.*(1+v).*(1-w); -1/8.*(1-v).*(1+w); +1/8.*(1-v).*(1+w); +1/8.*(1+v).*(1+w); -1/8.*(1+v).*(1+w);];
            refelem.gradNy = @(u,v,w) [-1/8.*(1-u).*(1-w); -1/8.*(1+u).*(1-w); +1/8.*(1+u).*(1-w); +1/8.*(1-u).*(1-w); -1/8.*(1-u).*(1+w); -1/8.*(1+u).*(1+w); +1/8.*(1+u).*(1+w); +1/8.*(1-u).*(1+w);];
            refelem.gradNz = @(u,v,w) [-1/8.*(1-u).*(1-v); -1/8.*(1+u).*(1-v); -1/8.*(1+u).*(1+v); -1/8.*(1-u).*(1+v); +1/8.*(1-u).*(1-v); +1/8.*(1+u).*(1-v); +1/8.*(1+u).*(1+v); +1/8.*(1-u).*(1+v);];
            % ---
        end
    end
end



