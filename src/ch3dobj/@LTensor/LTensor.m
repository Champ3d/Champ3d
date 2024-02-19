%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef LTensor < Xhandle
    properties
        main_value
        main_dir
        ort1_value
        ort1_dir
        ort2_value
        ort2_dir
    end

    % --- Contructor
    methods
        function obj = LTensor(args)
            arguments
                args.main_value = []
                args.main_dir = []
                args.ort1_value = []
                args.ort1_dir = []
                args.ort2_value = []
                args.ort2_dir = []
            end
            % ---
            obj <= args;
        end
    end

    % --- Methods
    methods
        function vout = evaluate_on(obj,dom)
            if obj.fvectorized
                vout = eval_fvectorized(obj,dom);
                vout = obj.column_format(vout);
            else
                vout = eval_fserial(obj,dom);
                vout = obj.column_format(vout);
            end
        end
    end
end