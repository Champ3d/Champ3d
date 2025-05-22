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

classdef VectorElemField < ElemField
    % --- Contructor
    methods
        function obj = VectorElemField()
            obj = obj@ElemField;
        end
    end
    % --- Utility Methods
    methods
        % -----------------------------------------------------------------
        function cmultiply(obj,tensor_array,gid_elem)
            arguments
                obj
                tensor_array
                gid_elem = []
            end
            % ---
            if isa(tensor_array,'TensorArray')
                % ---
                if isempty(gid_elem)
                    gid_elem = tensor_array.parent_dom.gid_elem;
                else
                    [gid_elem, ~, lid_elem] = intersect(gid_elem,tensor_array.parent_dom.gid_elem);
                end
                % ---
                V = obj.cvalue(gid_elem);
                T = tensor_array.value;
                % ---
                
            elseif isnumeric(tensor_array)
                
            end
            % ---
        end
        % -----------------------------------------------------------------
    end
    % --- plot
    methods
        % -----------------------------------------------------------------
        function plot(obj,args)
            arguments
                obj
                args.meshdom_obj = []
                args.id_meshdom = []
                args.id_elem = []
                args.show_dom = 1
            end
            % ---
            if isempty(args.id_meshdom)
                args.show_dom = 0;
                % ---
                if isempty(args.meshdom_obj)
                    if isempty(args.id_elem)
                        text(0,0,'Nothing to plot !');
                    else
                        gid_elem = args.id_elem;
                    end
                else
                    dom = args.meshdom_obj;
                    if isa(dom,'VolumeDom3d')
                        gid_elem = dom.gid_elem;
                    else
                        text(0,0,'Nothing to plot, dom must be a VolumeDom3d !');
                    end
                end
            else
                dom = obj.parent_model.parent_mesh.dom.(args.id_meshdom);
                if isa(dom,'VolumeDom3d')
                    gid_elem = dom.gid_elem;
                else
                    text(0,0,'Nothing to plot, dom must be a VolumeDom3d !');
                end
            end
            % ---
            if args.show_dom
                dom.plot('alpha',0.5,'edge_color',[0.9 0.9 0.9],'face_color','none')
            end
            % ---
            celem = obj.parent_model.parent_mesh.celem(:,gid_elem);
            v_ = obj.cvalue(gid_elem);
            if isreal(v_)
                % ---
                subplot(121)
                title('Vector');
                f_quiver(celem,obj.cvalue(gid_elem));
                % ---
                subplot(122)
                title('Norm');
                node_ = obj.parent_model.parent_mesh.node;
                elem = obj.parent_model.parent_mesh.elem(:,gid_elem);
                v__ = TensorArray.norm(v_);
                f_patch('node',node_,'elem',elem,'elem_field',v__);
            else
                for i = 1:4
                    % ---
                    subplot(220 + i);
                    if i == 1
                        title('Real part');
                        v__ = real(v_);
                        f_quiver(celem,v__);
                    elseif i == 2
                        title('Imag part');
                        v__ = imag(v_);
                        f_quiver(celem,v__);
                    elseif i == 3
                        title('Max');
                        v__ = TensorArray.maxvector(v_);
                        f_quiver(celem,v__);
                    elseif i == 4
                        title('Max');
                        % ---
                        node_ = obj.parent_model.parent_mesh.node;
                        elem = obj.parent_model.parent_mesh.elem(:,gid_elem);
                        v__ = TensorArray.norm(TensorArray.maxvector(v_));
                        f_patch('node',node_,'elem',elem,'elem_field',v__);
                    end
                    % ---
                end
            end
        end
        % -----------------------------------------------------------------
    end
end