%--------------------------------------------------------------------------
% Interface to FEMM
% FEMM (c) David Meeker 1998-2015
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef FEMM2dRectMovingFrame < FEMM2dMovingFrame
    properties
        len_x = 0
        len_y = 0
        len_r = 0
        len_theta = 0
        % ---
        topleft
        bottomright
    end
    properties (Access = private)
        reset_group = 1
    end

    % --- Constructor
    methods
        function obj = FEMM2dRectMovingFrame(args)
            arguments
                args.ref_point = [0,0] % must be in Oxy coordinates
                args.cen_x = []
                args.cen_y = []
                args.cen_r = []
                args.cen_theta = []
                args.len_x = []
                args.len_y = []
                args.len_r = []
                args.len_theta = []
            end
            % ---
            obj@FEMM2dMovingFrame;
            % ---
            obj <= args;
            % ---
            argu = f_to_namedarg(args);
            choosewindow = FEMM2dRectangle(argu{:});
            % ---
            obj.topleft = choosewindow.out_topleft;
            obj.bottomright = choosewindow.out_bottomright;
            % ---
            clear choosewindow;
            % ---
            obj.reset_group = 1;
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
                mi_selectrectangle(obj.topleft(1),obj.topleft(2),...
                                   obj.bottomright(1),obj.bottomright(2));
                % ---
                obj.id_group = f_str2code(['moveframe_' obj.id_moveframe],'code_type','integer');
                mi_seteditmode('group');
                mi_setgroup(obj.id_group);
                % ---
                id_dom_ = fieldnames(obj.parent_model.dom);
                nb_dom  = length(id_dom_);
                for i = 1:nb_dom
                    if obj.parent_model.dom.(id_dom_{i}).original_id_group ...
                            ~= obj.parent_model.dom.(id_dom_{i}).id_group
                        obj.id_dom{i} = id_dom_{i};
                    end
                end
                % ---
                obj.reset_group = 0;
            end
        end
        % ---
        function select(obj)
            obj.setup;
            mi_clearselected;
            mi_selectgroup(obj.id_group);
        end
    end
end
