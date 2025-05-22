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

classdef VectorFaceField < FaceField
    % --- Contructor
    methods
        function obj = VectorFaceField()
            obj = obj@FaceField;
        end
    end
    % --- Utility Methods
    methods
        % -----------------------------------------------------------------
        function Vout = cmultiply(obj,tensor_array,gid_face)
            arguments
                obj
                tensor_array
                gid_face = []
            end
            % ---
            if nargin <= 2
                gid_face = 1:obj.parent_model.parent_mesh.nb_face;
            end
            % ---
            if isa(tensor_array,'TensorArray')
                % ---
                [gid_face, ~, lid_face] = intersect(gid_face,tensor_array.parent_dom.gid_face);
                % ---
                Vin = obj.cvalue(gid_face);
                T = tensor_array.getvalue(lid_face);
                array_type = tensor_array.type;
            elseif isnumeric(tensor_array)
                Vin = obj.cvalue(gid_face);
                [T, array_type] = Array.tensor(tensor_array);
            end
            % ---
            if isempty(T)
                Vout = [];
                return
            end
            % ---
            if strcmpi(array_type,'scalar')
                Vout = T .* Vin;
            elseif strcmpi(array_type,'tensor')
                Vout(:,1) = T(:,1,1) .* Vin(:,1) + ...
                            T(:,1,2) .* Vin(:,2) + ...
                            T(:,1,3) .* Vin(:,3);
                Vout(:,2) = T(:,2,1) .* Vin(:,1) + ...
                            T(:,2,2) .* Vin(:,2) + ...
                            T(:,2,3) .* Vin(:,3);
                Vout(:,3) = T(:,3,1) .* Vin(:,1) + ...
                            T(:,3,2) .* Vin(:,2) + ...
                            T(:,3,3) .* Vin(:,3);
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
                args.id_face = []
                args.show_dom = 1
            end
            % ---
            if isempty(args.id_meshdom)
                args.show_dom = 0;
                % ---
                if isempty(args.meshdom_obj)
                    if isempty(args.id_face)
                        text(0,0,'Nothing to plot !');
                    else
                        gid_face = args.id_face;
                    end
                else
                    dom = args.meshdom_obj;
                    if isa(dom,'SurfaceDom3d')
                        gid_face = dom.gid_face;
                    else
                        text(0,0,'Nothing to plot, dom must be a SurfaceDom3d !');
                    end
                end
            else
                dom = obj.parent_model.parent_mesh.dom.(args.id_meshdom);
                if isa(dom,'SurfaceDom3d')
                    gid_face = dom.gid_face;
                else
                    text(0,0,'Nothing to plot, dom must be a SurfaceDom3d !');
                end
            end
            % ---
            if args.show_dom
                dom.plot('alpha',0.5,'edge_color',[0.9 0.9 0.9],'face_color','none')
            end
            % ---
            node_ = obj.parent_model.parent_mesh.node;
            face_ = obj.parent_model.parent_mesh.face(:,gid_face);
            v_ = obj.cvalue(gid_face);
            if isreal(v_)
                f_patch('node',node_,'face',face_,'face_field',obj.cvalue(gid_face).');
            else
                for i = 1:3
                    subplot(130 + i);
                    if i == 1
                        title('Real part');
                        v__ = VectorArray.norm(real(v_));
                        f_patch('node',node_,'face',face_,'face_field',v__);
                    elseif i == 2
                        title('Imag part');
                        v__ = VectorArray.norm(imag(v_));
                        f_patch('node',node_,'face',face_,'face_field',v__);
                    elseif i == 3
                        title('Max');
                        v__ = VectorArray.norm(VectorArray.max(v_));
                        f_patch('node',node_,'face',face_,'face_field',v__);
                    end
                end
            end
        end
    end
end