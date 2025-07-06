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

classdef MovingFrame < Xhandle
    
    properties
        parent_model
    end

    % --- Contructor
    methods
        function obj = MovingFrame()
            obj = obj@Xhandle;
        end
    end

    % --- Methods
    methods (Abstract)
        movenode(obj)
        inverse_movenode(obj)
        movevector(obj)
        inverse_movevector(obj)
    end

    % --- 
    methods
        function node = node(obj,t)
            arguments
                obj
                t = []
            end
            % ---
            node = obj.movenode(obj.parent_model.parent_mesh.node,t);
            % ---
        end
        function node = celem(obj,t)
            arguments
                obj
                t = []
            end
            % ---
            node = obj.movenode(obj.parent_model.parent_mesh.celem,t);
            % ---
        end
        function node = cface(obj,t)
            arguments
                obj
                t = []
            end
            % ---
            node = obj.movenode(obj.parent_model.parent_mesh.cface,t);
            % ---
        end
        function node = cedge(obj,t)
            arguments
                obj
                t = []
            end
            % ---
            node = obj.movenode(obj.parent_model.parent_mesh.cedge,t);
            % ---
        end
        function lbox = localbox(obj,id_elem,t)
            arguments
                obj
                id_elem = []
                t = []
            end
            % ---
            lbox = obj.parent_model.parent_mesh.localbox(id_elem);
            % ---
            xmin = lbox.xmin;
            xmax = lbox.xmax;
            ymin = lbox.ymin;
            ymax = lbox.ymax;
            zmin = lbox.zmin;
            zmax = lbox.zmax;
            % ---
            limnodes = obj.movenode([xmin xmax; ymin ymax; zmin zmax],t);
            % ---
            xmin = limnodes(1,1);
            xmax = limnodes(1,2);
            ymin = limnodes(2,1);
            ymax = limnodes(2,2);
            zmin = limnodes(3,1);
            zmax = limnodes(3,2);
            % ---
            lbox.xmin = min(xmin,xmax);
            lbox.xmax = max(xmin,xmax);
            lbox.ymin = min(ymin,ymax);
            lbox.ymax = max(ymin,ymax);
            lbox.zmin = min(zmin,zmax);
            lbox.zmax = max(zmin,zmax);
        end
    end

end