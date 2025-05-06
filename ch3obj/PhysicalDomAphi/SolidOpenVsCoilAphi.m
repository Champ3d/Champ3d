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

classdef SolidOpenVsCoilAphi < OpenCoilAphi & SolidCoilAphi & VsCoilAphi
    
    % --- entry
    properties
        v_coil = 0
        coil_mode = 'tx'
    end

    % --- computed
    properties
        j_coil
        i_coil
        z_coil
        L0
    end

    % --- computed
    properties (Access = private)
        build_done = 0
        assembly_done = 0
    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'parent_model','id_dom2d','id_dom3d','etrode_equation', ...
                        'sigma','i_coil','coil_mode'};
        end
    end
    % --- Contructor
    methods
        function obj = SolidOpenVsCoilAphi(args)
            arguments
                args.parent_model
                args.id_dom2d
                args.id_dom3d
                args.etrode_equation
                % ---
                args.sigma
                args.v_coil
                args.coil_mode {mustBeMember(args.coil_mode,{'tx','rx'})}
            end
            % ---
            obj@OpenCoilAphi;
            obj@SolidCoilAphi;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            obj.setup;
        end
    end

    % --- setup
    methods
        function setup(obj)
            setup@OpenCoilAphi(obj);
            setup@SolidCoilAphi(obj);
            % ---
            if isempty(obj.v_coil)
                obj.coil_mode = 'rx';
            elseif isnumeric(obj.v_coil)
                if obj.v_coil == 0
                    obj.coil_mode = 'rx';
                end
            end
            % ---
        end
    end

    % --- build
    methods
        function build(obj)
            % ---
            obj.setup;
            % ---
            if obj.build_done
                return
            end
            % ---
            build@OpenCoilAphi(obj);
            build@VsCoilAphi(obj);
            % ---
            obj.build_done = 1;
        end
    end

    % --- reset
    methods
        function reset(obj)
            if isprop(obj,'setup_done')
                obj.setup_done = 0;
            end
            if isprop(obj,'build_done')
                obj.build_done = 0;
            end
            if isprop(obj,'assembly_done')
                obj.assembly_done = 0;
            end
            % ---
            reset@SolidCoilAphi(obj);
            reset@OpenCoilAphi(obj);
            reset@VsCoilAphi(obj);
            % ---
        end
    end

end