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

classdef VectorFaceField < FaceField & VectorField
    % --- Contructor
    methods
        function obj = VectorFaceField()
            obj = obj@FaceField;
            obj = obj@VectorField;
        end
    end
    % --- Utility Methods
    methods

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
                        gindex = args.id_face;
                    end
                else
                    dom = args.meshdom_obj;
                    if isa(dom,'SurfaceDom3d')
                        gindex = dom.gindex;
                    else
                        text(0,0,'Nothing to plot, dom must be a SurfaceDom3d !');
                    end
                end
            else
                dom = obj.parent_model.parent_mesh.dom.(args.id_meshdom);
                if isa(dom,'SurfaceDom3d')
                    gindex = dom.gindex;
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
            face_ = obj.parent_model.parent_mesh.face(:,gindex);
            v_ = obj.cvalue(gindex);
            if isreal(v_)
                f_patch('node',node_,'face',face_,'face_field',obj.cvalue(gindex).');
            else
                for i = 1:3
                    subplot(130 + i);
                    if i == 1
                        title('Real part');
                        v__ = Array.norm(real(v_));
                        f_patch('node',node_,'face',face_,'face_field',v__);
                    elseif i == 2
                        title('Imag part');
                        v__ = Array.norm(imag(v_));
                        f_patch('node',node_,'face',face_,'face_field',v__);
                    elseif i == 3
                        title('Max');
                        v__ = Array.norm(VectorArray.max(v_));
                        f_patch('node',node_,'face',face_,'face_field',v__);
                    end
                end
            end
        end
    end
end