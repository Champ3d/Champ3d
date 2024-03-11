%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef HexMesh < Mesh3d

    % --- Properties
    properties

    end

    % --- Dependent Properties
    properties (Dependent = true)

    end

    % --- Constructors
    methods
        function obj = HexMesh(args)
            arguments
                args.node
                args.elem
            end
            % ---
            obj@Mesh3d;
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
            obj.elem_type = 'hexa';
            obj.reference;
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
                args.id_elem = []
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
            if isempty(args.id_elem)
                boface = f_boundface(obj.elem,obj.node,'elem_type','hexa');
            else
                boface = f_boundface(obj.elem(:,args.id_elem),obj.node,'elem_type','hexa');
            end
            %--------------------------------------------------------------
            msh.Vertices = obj.node.';
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
        function reference(obj)
            con.nbNo_inEl = 8;
            con.nbNo_inEd = 2;
            con.EdNo_inEl = [1 2; 1 4; 1 5; 2 3; 2 6; 3 4; 3 7; 4 8; 5 6; 5 8; 6 7; 7 8];
            con.siNo_inEd = [+1, -1]; % w.r.t edge
            con.FaNo_inEl = [1 2 3 4; 5 6 7 8; 1 2 6 5; 2 3 7 6; 3 4 8 7; 1 4 8 5]; %
            % ---
            con.NoFa_ofEd = [6 4; 3 5; 1 2; 3 5; 1 2; 4 6; 1 2; 1 2; 6 4; 3 5; 3 5; 4 6]; % !!! F(i,~j) - circular
            con.NoFa_ofFa = [6 3 4 5; 6 3 4 5; 6 1 4 2; 3 1 5 2; 4 1 6 2; 3 1 5 2]; % !!! F(i,~i+1) - circular
            % ---
            con.nbNo_inFa = [      4;       4;       4;       4;       4;       4];
            con.FaType    = [      2;       2;       2;       2;       2;       2];
            con.nbEd_inFa{1} = 4; % for FaType 1
            con.nbEd_inFa{2} = 4; % for FaType 2
            con.EdNo_inFa{1} = [1 2; 1 4; 2 3; 3 4]; % for FaType 1
            con.EdNo_inFa{2} = [1 2; 1 4; 2 3; 3 4]; % for FaType 2
            con.FaEd_inEl = [];
            con.siFa_inEl = [];
            con.siEd_inEl = [];
            con.siEd_inFa{1} = [1 -1 1 1]; % w.r.t face for FaType 1
            con.siEd_inFa{2} = [1 -1 1 1]; % w.r.t face for FaType 2
            % ---
            con.nbEd_inEl = size(con.EdNo_inEl,1);
            con.nbFa_inEl = size(con.FaNo_inEl,1);
            % --- Gauss points
            con.U   = sqrt(3)/3*[-1 -1 -1 -1  1  1  1 1];
            con.V   = sqrt(3)/3*[-1 -1  1  1 -1 -1  1 1];
            con.W   = sqrt(3)/3*[-1  1 -1  1 -1  1 -1 1];
            con.Weigh =         [ 1  1  1  1  1  1  1 1];
            con.cU  = 0;
            con.cV  = 0;
            con.cW  = 0;
            con.cWeigh  = 8; % 2x2x2
            con.nbG = length(con.U);
            % ---
            con.nbI = 9;
            e = 1e-6;
            con.nU = [-1 +1 +1 -1 -1 +1 +1 -1];
            con.nV = [-1 -1 +1 +1 -1 -1 +1 +1];
            con.nW = [-1 -1 -1 -1 +1 +1 +1 +1];
            con.iU = [(1-e) * con.nU    0];
            con.iV = [(1-e) * con.nV    0];
            con.iW = [(1-e) * con.nW    0];
            % ---
            con.N{1} = @(u,v,w) 1/8.*(1-u).*(1-v).*(1-w);
            con.N{2} = @(u,v,w) 1/8.*(1+u).*(1-v).*(1-w);
            con.N{3} = @(u,v,w) 1/8.*(1+u).*(1+v).*(1-w);
            con.N{4} = @(u,v,w) 1/8.*(1-u).*(1+v).*(1-w);
            con.N{5} = @(u,v,w) 1/8.*(1-u).*(1-v).*(1+w);
            con.N{6} = @(u,v,w) 1/8.*(1+u).*(1-v).*(1+w);
            con.N{7} = @(u,v,w) 1/8.*(1+u).*(1+v).*(1+w);
            con.N{8} = @(u,v,w) 1/8.*(1-u).*(1+v).*(1+w);
            con.gradNx = @(u,v,w) [-1/8.*(1-v).*(1-w); +1/8.*(1-v).*(1-w); +1/8.*(1+v).*(1-w); -1/8.*(1+v).*(1-w); -1/8.*(1-v).*(1+w); +1/8.*(1-v).*(1+w); +1/8.*(1+v).*(1+w); -1/8.*(1+v).*(1+w);];
            con.gradNy = @(u,v,w) [-1/8.*(1-u).*(1-w); -1/8.*(1+u).*(1-w); +1/8.*(1+u).*(1-w); +1/8.*(1-u).*(1-w); -1/8.*(1-u).*(1+w); -1/8.*(1+u).*(1+w); +1/8.*(1+u).*(1+w); +1/8.*(1-u).*(1+w);];
            con.gradNz = @(u,v,w) [-1/8.*(1-u).*(1-v); -1/8.*(1+u).*(1-v); -1/8.*(1+u).*(1+v); -1/8.*(1-u).*(1+v); +1/8.*(1-u).*(1-v); +1/8.*(1+u).*(1-v); +1/8.*(1+u).*(1+v); +1/8.*(1-u).*(1+v);];
            % ---
            obj.refelem = con;
        end
    end

end



