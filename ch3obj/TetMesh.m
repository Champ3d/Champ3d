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

classdef TetMesh < Mesh3d
    properties (Access = private)
        build_done = 0
        % ---
        build_meshds_done = 0;
        build_discrete_done = 0;
        build_intkit_done = 0;
        build_prokit_done = 0;
    end
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'id','node','elem'};
        end
    end
    % --- Constructors
    methods
        function obj = TetMesh(args)
            arguments
                args.id
                args.node
                args.elem
            end
            % ---
            obj@Mesh3d;
            obj.elem_type = 'tetra';
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            TetMesh.setup(obj);
            % ---
        end
    end

    % --- setup
    methods (Static)
        function setup(obj)
            obj.build_done = 0;
            % ---
            obj.build_meshds_done = 0;
            obj.build_discrete_done = 0;
            obj.build_intkit_done = 0;
            obj.build_prokit_done = 0;
        end
    end
    methods (Access = public)
        function reset(obj)
            TetMesh.setup(obj);
            % --- reset dependent obj
            obj.reset_dependent_obj;
        end
    end
    % --- build
    methods
        function build(obj)
            % ---
            if obj.build_done
                return
            end
            % ---
            if ~obj.build_meshds_done
                obj.build_meshds;
                obj.build_meshds_done = 1;
            end
            if ~obj.build_discrete_done
                obj.build_discrete;
                obj.build_discrete_done = 1;
            end
            if ~obj.build_intkit_done
                obj.build_intkit;
                obj.build_intkit_done = 1;
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
                boface = f_boundface(obj.elem,obj.node,'elem_type','tetra');
            else
                boface = f_boundface(obj.elem(:,args.id_elem),obj.node,'elem_type','tetra');
            end
            %--------------------------------------------------------------
            if f_strcmpi(args.coordinate_system,'global')
                %msh.Vertices = obj.moving_frame;
                msh.Vertices = obj.node.';
            else
                msh.Vertices = obj.node.';
            end
            %--------------------------------------------------------------
            msh.Faces = f_unique(boface(1:3,:)).';
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
            refelem.nbNo_inEl = 4;
            refelem.nbNo_inEd = 2;
            refelem.EdNo_inEl = [1 2; 1 3; 1 4; 2 3; 2 4; 3 4];
            refelem.siNo_inEd = [-1, +1]; % w.r.t edge
            refelem.FaNo_inEl = [1 2 3; 1 2 4; 1 3 4; 2 3 4]; %
            %-----
            refelem.NoFa_ofEd = [3 4; 2 4; 1 4; 2 3; 1 3; 1 2]; % !!! F(i,~j) - circular
            refelem.NoFa_ofFa = [3 2 4; 3 1 4; 2 1 4; 2 1 3]; % !!! F(i,~i+1) - circular
            %-----
            refelem.nbNo_inFa = [    3;     3;     3;     3];
            refelem.FaType    = [    1;     1;     1;     1];
            refelem.nbEd_inFa{1} = 3; % for FaType 1
            refelem.nbEd_inFa{2} = 3; % for FaType 2
            refelem.EdNo_inFa{1} = [1 2; 1 3; 2 3]; % for FaType 1
            refelem.EdNo_inFa{2} = [1 2; 1 3; 2 3]; % for FaType 2
            refelem.FaEd_inEl = [];
            refelem.siFa_inEl = [];
            refelem.siEd_inEl = [];
            refelem.siEd_inFa{1} = [1 -1 1]; % w.r.t face for FaType 1
            refelem.siEd_inFa{2} = [1 -1 1]; % w.r.t face for FaType 2
            %-----
            refelem.nbEd_inEl = size(refelem.EdNo_inEl,1);
            refelem.nbFa_inEl = size(refelem.FaNo_inEl,1);
            %----- Gauss points
            a = (5 - sqrt(5)) / 20;
            b = (5 + 3 * sqrt(5)) / 20;
            refelem.U   = [a a a b];
            refelem.V   = [a a b a];
            refelem.W   = [a b a a];
            refelem.Weigh = 1/24 * [1  1  1  1];
            refelem.cU  = 1/4;
            refelem.cV  = 1/4;
            refelem.cW  = 1/4;
            refelem.cWeigh  = 1/6;
            refelem.nbG = length(refelem.U);
            % ---
            refelem.nbI = 5;
            e = 1e-6;
            refelem.nU = [ 0 +1  0  0];
            refelem.nV = [ 0  0 +1  0];
            refelem.nW = [ 0  0  0 +1];
            refelem.iU = [(1-e) * refelem.nU    1/4];
            refelem.iV = [(1-e) * refelem.nV    1/4];
            refelem.iW = [(1-e) * refelem.nW    1/4];
            %-----
            refelem.N{1} = @(u,v,w) 1-u-v-w;
            refelem.N{2} = @(u,v,w) u;
            refelem.N{3} = @(u,v,w) v;
            refelem.N{4} = @(u,v,w) w;
            refelem.gradNx = @(u,v,w) [-1 + 0*u; 1 + 0*u;     0*u;     0*u];
            refelem.gradNy = @(u,v,w) [-1 + 0*v;     0*v; 1 + 0*v;     0*v];
            refelem.gradNz = @(u,v,w) [-1 + 0*w;     0*w;     0*w; 1 + 0*w];
            % ---
        end
    end
end