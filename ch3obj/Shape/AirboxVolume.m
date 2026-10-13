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

classdef AirboxVolume < Xhandle
    properties
        volume_shape
        mesh_size = 0
    end
    properties (Dependent)
        id_number
    end
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'id'};
        end
    end
    % --- Constructors
    methods
        function obj = AirboxVolume(args)
            arguments
                args.id = ''
                args.volume_shape (1,1) {mustBeA(args.volume_shape,'VolumeShape')}
                args.mesh_size = 0
            end
            obj = obj@Xhandle;
            % ---
            if ~isfield(args,'volume_shape')
                error('#volume_shape must be given !');
            end
            % ---
            if isempty(args.id)
                args.id = 'by_default_air';
            end
            % ---
            if isnumeric(args.mesh_size)
                if args.mesh_size <= 0
                    args.mesh_size = 0;
                end
            end
            % ---
            obj <= args;
            % ---
            AirboxVolume.setup(obj);
            % ---
        end
    end
    % --- setup/reset
    methods (Static)
        function setup(obj)
            % ---
            obj.set_parameter;
            obj.volume_shape.is_defining_obj_of(obj);
            % ---
        end
    end
    methods (Access = public)
        function reset(obj)
            AirboxVolume.setup(obj);
            % --- reset dependent obj
            obj.reset_dependent_obj;
        end
    end

    % --- get
    methods
        function val = get.id_number(obj)
            val = f_str2code(obj.id,'code_type','integer');
        end
    end

    % --- Methods
    methods (Access = public)
        function geocode = geocode(obj)
            geocode = [newline '// --- airbox' newline ...
                       obj.volume_shape.geocode newline ...
                       GMSHWriter.finish_airboxvolume newline];
        end
    end

    % --- Methods
    methods (Access = protected)
        % -----------------------------------------------------------------
        function set_parameter(obj)
            % --- XTODO
            % should put list in config file ?
            paramlist = {'mesh_size'};
            % ---
            for i = 1:length(paramlist)
                param = paramlist{i};
                if isprop(obj,param)
                    if isnumeric(obj.(param))
                        if ~isempty(obj.(param))
                            obj.(param) = Parameter('f',obj.(param));
                        end
                    elseif ~isa(obj.(param),'Parameter')
                        f_fprintf(1,'/!\\',0,'parameter must be numeric or Parameter !\n');
                        error('Parameter error');
                    end
                end
            end
        end
        % -----------------------------------------------------------------
    end

    % --- Methods
    methods
        function plot(obj,args)
            % XTODO
        end
    end

end
