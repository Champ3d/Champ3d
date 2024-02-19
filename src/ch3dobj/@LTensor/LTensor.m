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
        function gtensor = evaluate_on(obj,dom)
            % ---
            if isa(dom,'VolumeDom')
                id_elem = dom.gid_elem;
            elseif isa(dom,'SurfaceDom')
                id_elem = dom.gid_face;
            elseif isprop(dom,'gid_elem')
                id_elem = dom.gid_elem;
            elseif isprop(dom,'gid_face')
                id_elem = dom.gid_face;
            end
            % ---
            nb_elem = length(id_elem);
            % ---
            fnames = {'main_value','main_dir','ort1_value','ort1_dir',...
                      'ort2_value','ort2_dir'};
            % ---
            ltensor = [];
            for i = 1:length(fnames)
                fn = fnames{i};
                ltfield = obj.(fn);
                if isnumeric(ltfield)
                    ltensor.(fn) = repmat(ltfield,nb_elem,1);
                elseif isa(ltfield,'Parameter')
                    ltensor.(fn) = ltfield.evaluate_on(dom);
                end
            end
            % ---
            gtensor = f_gtensor(ltensor);
            % ---
        end
    end
end