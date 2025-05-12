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

classdef QuadMesh < Mesh2d
    properties
        lid_face
    end
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
        function obj = QuadMesh(args)
            arguments
                args.id
                args.node
                args.elem
            end
            % ---
            obj = obj@Mesh2d;
            obj.elem_type = 'quad';
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            QuadMesh.setup(obj);
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
            % ---
            obj.cal_flatnode;
            % ---
        end
    end
    methods (Access = public)
        function reset(obj)
            QuadMesh.setup(obj);
            % --- reset dependent objs
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
                args.field_value = []
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
            msh.Faces = obj.elem(1:4,:).';
            msh.FaceColor = face_color_;
            msh.EdgeColor = edge_color_; % [0.7 0.7 0.7] --> gray
            %--------------------------------------------------------------
            if ~isempty(args.field_value)
                msh.FaceVertexCData = f_tocolv(full(args.field_value));
            end
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
            refelem.nbNo_inEl = 4;
            refelem.nbNo_inEd = 2;
            refelem.EdNo_inEl = [1 2; 1 4; 2 3; 3 4];
            refelem.siNo_inEd = [-1, +1]; % w.r.t edge
            refelem.FaNo_inEl = refelem.EdNo_inEl; % face as edge
            %-----
            refelem.NoFa_ofEd = [2 3; 1 4; 1 4; 3 2]; % !!! F(i,~j) - circular
            %con.NoFa_ofFa = [6 3 4 5; 6 3 4 5; 6 1 4 2; 3 1 5 2; 4 1 6 2; 3 1 5 2]; % !!! F(i,~i+1) - circular
            %-----
            refelem.nbNo_inFa = [  2;   2;   2;   2];
            refelem.FaType    = [  1;   1;   1;   1];
            refelem.nbEd_inFa = [];
            refelem.EdNo_inFa = [];
            refelem.FaEd_inEl = [];
            refelem.siEd_inEl = [1; -1; 1; 1];
            refelem.siFa_inEl = refelem.siEd_inEl; % upperface convention
            refelem.siEd_inFa = [];
            %-----
            refelem.nbEd_inEl = size(refelem.EdNo_inEl,1);
            refelem.nbFa_inEl = size(refelem.FaNo_inEl,1);
            %----- Gauss points
            refelem.U     = 1/sqrt(3)*[-1 +1 +1 -1];
            refelem.V     = 1/sqrt(3)*[-1 -1 +1 +1];
            refelem.Weigh =           [ 1  1  1  1];
            refelem.cU  = 0;
            refelem.cV  = 0;
            refelem.cWeigh  = 4;
            refelem.nbG = length(refelem.U);
            % ---
            refelem.nbI = 5;
            e = 1e-6;
            refelem.nU = [-1 +1 +1 -1];
            refelem.nV = [-1 -1 +1 +1];
            refelem.iU = [(1-e) * refelem.nU    0];
            refelem.iV = [(1-e) * refelem.nV    0];
            % ---
            refelem.N{1} = @(u,v) 1/4 * (1-u) .* (1-v);
            refelem.N{2} = @(u,v) 1/4 * (1+u) .* (1-v);
            refelem.N{3} = @(u,v) 1/4 * (1+u) .* (1+v);
            refelem.N{4} = @(u,v) 1/4 * (1-u) .* (1+v);
            refelem.gradNx = @(u,v) [(-1+v)./4;  (1-v)./4; (1+v)./4; (-1-v)./4];
            refelem.gradNy = @(u,v) [(-1+u)./4; (-1-u)./4; (1+u)./4;  (1-u)./4];
            % ---
        end
    end
end