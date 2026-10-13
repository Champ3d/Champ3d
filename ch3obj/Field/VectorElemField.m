%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
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

classdef VectorElemField < ElemField & VectorField
    % --- Contructor
    methods
        function obj = VectorElemField()
            obj = obj@ElemField;
            obj = obj@VectorField;
        end
    end
    % --- Utility Methods
    methods
        
    end
    % --- plot
    methods
        % -----------------------------------------------------------------
        function plot_real(obj,args)
            arguments
                obj
                args.meshdom_obj = []
                args.id_meshdom = []
                args.gindex = []
                args.show_dom = 1
                args.edge_color = [0.4940 0.1840 0.5560]
                args.face_color = 'c'
                args.alpha {mustBeNumeric} = 0.5
            end
            % ---
        end
        % -----------------------------------------------------------------
        function plot(obj,args)
            arguments
                obj
                args.meshdom_obj = []
                args.id_meshdom = []
                args.gindex = []
                args.show_dom = 0
                args.type {mustBeMember(args.type,{'vector-real','vector-image','norm','max'})} = 'norm'
            end
            % ---
            if isempty(args.id_meshdom)
                args.show_dom = 0;
                % ---
                if isempty(args.meshdom_obj)
                    if isempty(args.gindex)
                        text(0,0,'Nothing to plot !');
                    else
                        gindex = args.gindex;
                    end
                else
                    dom = args.meshdom_obj;
                    if isa(dom,'VolumeDom3d')
                        gindex = dom.gindex;
                    else
                        text(0,0,'Nothing to plot, dom must be a VolumeDom3d !');
                    end
                end
            else
                dom = obj.parent_model.parent_mesh.dom.(args.id_meshdom);
                if isa(dom,'VolumeDom3d')
                    gindex = dom.gindex;
                else
                    text(0,0,'Nothing to plot, dom must be a VolumeDom3d !');
                end
            end
            % ---
            if args.show_dom
                pmsh = obj.parent_model.parent_mesh;
                msh = Mesh.submesh(pmsh,gindex);
                % ---
                msh.plot('face_color','none', ...
                         'edge_color','k', ...
                         'alpha',0.5); hold on
                % ---
            end
            % ---
            celem = obj.parent_model.moving_frame.celem;
            celem = celem(:,gindex);
            v_ = obj.cvalue(gindex);
            switch args.type
                case 'norm'
                    if isreal(v_)
                        node_ = obj.parent_model.moving_frame.node;
                        elem = obj.parent_model.parent_mesh.elem(:,gindex);
                        v__ = Array.norm(v_);
                        f_patch('node',node_,'elem',elem,'elem_field',v__);
                    else
                        node_ = obj.parent_model.moving_frame.node;
                        elem = obj.parent_model.parent_mesh.elem(:,gindex);
                        v__ = Array.norm(VectorArray.max(v_));
                        f_patch('node',node_,'elem',elem,'elem_field',v__);
                    end
                case 'max'
                    if isreal(v_)
                        v__ = v_;
                    else
                        v__ = VectorArray.max(v_);
                    end
                    f_quiver(celem,v__);
                case 'vector-real'
                    v__ = real(v_);
                    f_quiver(celem,v__);
                case 'vector-imag'
                    v__ = imag(v_);
                    f_quiver(celem,v__);
            end
            % ---
            xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
        end
        % -----------------------------------------------------------------
    end
end