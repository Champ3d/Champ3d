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

classdef SolidOpenIsCoilAphi < OpenCoilAphi & SolidCoilAphi & IsCoilAphi
    
    % --- entry
    properties
        i_coil = 0
        coil_mode = 'tx'
    end

    % --- computed
    properties
        j_coil
        v_coil
        z_coil
        L0
    end

    properties (Access = private)
        setup_done = 0
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
        function obj = SolidOpenIsCoilAphi(args)
            arguments
                args.parent_model
                args.id_dom2d
                args.id_dom3d
                args.etrode_equation
                % ---
                args.sigma
                args.i_coil
                args.coil_mode {mustBeMember(args.coil_mode,{'tx','rx'})}
            end
            % ---
            obj@OpenCoilAphi;
            obj@SolidCoilAphi;
            obj@IsCoilAphi;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            SolidOpenIsCoilAphi.setup(obj);
            % ---
            % must reset build+assembly
            obj.build_done = 0;
            obj.assembly_done = 0;
        end
    end

    % --- setup/reset/build/assembly
    methods (Static)
        function setup(obj)
            % ---
            if obj.setup_done
                return
            end
            % ---
            setup@OpenCoilAphi(obj);
            setup@SolidCoilAphi(obj);
            setup@IsCoilAphi(obj);
            % --- update by-default coil mode
            if isempty(obj.i_coil)
                obj.coil_mode = 'rx';
            elseif isnumeric(obj.i_coil)
                if obj.i_coil == 0
                    obj.coil_mode = 'rx';
                end
            end
            % ---
            obj.setup_done = 1;
            % ---
        end
    end
    methods (Access = public)
        function reset(obj)
            % ---
            % must reset setup+build+assembly
            obj.setup_done = 0;
            obj.build_done = 0;
            obj.assembly_done = 0;
            % ---
            % must call super reset
            % ,,, with obj as argument
            reset@OpenCoilAphi(obj);
            reset@SolidCoilAphi(obj);
            reset@IsCoilAphi(obj);
        end
    end
    % --- build
    methods
        function build(obj)
            % ---
            SolidOpenIsCoilAphi.setup(obj);
            % ---
            build@OpenCoilAphi(obj);
            build@SolidCoilAphi(obj);
            build@IsCoilAphi(obj);
            % ---
            if obj.build_done
                return
            end
            % ---
            obj.build_done = 1;
        end
    end
end