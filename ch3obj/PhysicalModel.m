%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef PhysicalModel < Xhandle
    % --- computed
    properties
        matrix
        field
        dof
    end
    % --- subfields to build
    properties
        parent_mesh
        ltime
        moving_frame
    end
    % ---
    properties (Access = private)
        setup_done = 0
        build_done = 0
        assembly_done = 0
    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {};
        end
    end
    % --- Constructor
    methods
        function obj = PhysicalModel()
            % ---
            obj@Xhandle;
            % ---
            % call setup in constructor
            % ,,, for direct verification
            % ,,, setup must be static
            PhysicalModel.setup(obj);
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
            obj.ltime = LTime;
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
        end
    end
    methods
        function build(obj)
            % ---
            PhysicalModel.setup(obj);
            % ---
            if obj.build_done
                return
            end
            % ---
            obj.parent_mesh.build_meshds;
            obj.parent_mesh.build_discrete;
            obj.parent_mesh.build_intkit;
            % ---
            obj.build_done = 1;
            % ---
        end
    end
    methods
        function assembly(obj)
            % ---
            % may return to build of subclass obj
            % ... subclass build must call superclass build
            obj.build;
            % ---
        end
    end
end