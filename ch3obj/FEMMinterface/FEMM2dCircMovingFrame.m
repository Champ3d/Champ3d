%--------------------------------------------------------------------------
% Interface to FEMM
% FEMM (c) David Meeker 1998-2015
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

classdef FEMM2dCircMovingFrame < FEMM2dMovingFrame
    properties
        r
    end
    properties (Access = private)
        reset_group = 1
    end

    % --- Constructor
    methods
        function obj = FEMM2dCircMovingFrame(args)
            arguments
                args.ref_point = [0,0] % must be in Oxy coordinates
                args.cen_x = 0
                args.cen_y = 0
                args.cen_r = 0
                args.cen_theta = 0
                args.r = 0
            end
            % ---
            obj@FEMM2dMovingFrame;
            % ---
            obj <= args;
            % ---
            argu = f_to_namedarg(args);
            choosewindow = FEMM2dCircle(argu{:});
            % ---
            obj.center = choosewindow.center;
            obj.r = choosewindow.r;
            % ---
            clear choosewindow;
        end
    end

    % --- Methods/public
    methods (Access = public)
        function setup(obj)
            if obj.reset_group
                % ---
                mi_clearselected;
                % ---
                mi_seteditmode('group');
                mi_selectcircle(obj.center(1),obj.center(2),obj.r);
                % ---
                obj.id_group = f_str2code(['moveframe_' obj.id_moveframe],'code_type','integer');
                mi_seteditmode('group');
                mi_setgroup(obj.id_group);
                % ---
                id_dom_ = fieldnames(obj.parent_model.dom);
                nb_dom  = length(id_dom_);
                k = 0;
                for i = 1:nb_dom
                    % ---
                    vdom = obj.parent_model.dom.(id_dom_{i});
                    vpt  = [0;0];
                    vpt(1) = vdom.original_choosing_point.x - obj.center(1);
                    vpt(2) = vdom.original_choosing_point.y - obj.center(2);
                    d_r = norm(vpt);
                    % ---
                    if (d_r <= obj.r)
                        k = k + 1;
                        obj.id_dom{k} = id_dom_{i};
                    end
                end
                % ---
                obj.reset_group = 0;
            end
        end
        % ---
    end
end
