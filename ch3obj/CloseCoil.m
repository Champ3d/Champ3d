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

classdef CloseCoil < Coil

    % --- entry
    properties (SetObservable)
        etrode_equation
    end

    % --- computed
    properties
        electrode_dom
        shape_dom
    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs(fname)
            if nargin < 1
                argslist = {'parent_model','id_dom2d','id_dom3d','etrode_equation'};
            elseif ischar(fname)
                if f_strcmpi(fname,'plot')
                    argslist = {'edge_color','face_color','alpha'};
                end
            end
        end
    end
    % --- Contructor
    methods
        function obj = CloseCoil(args)
            arguments
                args.parent_model
                args.id_dom2d
                args.id_dom3d
                args.etrode_equation
            end
            % ---
            obj@Coil;
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
            % ---
            setup@Coil(obj);
            % ---
            obj.etrode_equation = f_to_scellargin(obj.etrode_equation);
            obj.etrode_equation = obj.etrode_equation{1};
            % ---
            obj.get_electrode;
            % ---
        end
    end
    % --- Methods
    methods
        % -----------------------------------------------------------------
        function get_electrode(obj)
            % ---
            args4cv3.parent_mesh = obj.parent_model.parent_mesh;
            args4cv3.id_dom3d = obj.id_dom3d;
            args4cv3.cut_equation = obj.etrode_equation;
            % ---
            argu = f_to_namedarg(args4cv3,'for','CutVolumeDom3d');
            % ---
            obj.electrode_dom = CutVolumeDom3d(argu{:});
            % ---
            coilshape = obj.dom - obj.electrode_dom;
            % ---
            obj.shape_dom = eval(class(obj.electrode_dom));
            obj.shape_dom <= coilshape;
            % ---
            obj.shape_dom.gid_side_node_1 = obj.electrode_dom.gid_side_node_2;
            obj.shape_dom.gid_side_node_2 = obj.electrode_dom.gid_side_node_1;
        end
        % -----------------------------------------------------------------
        function plot(obj,args)
            arguments
                obj
                args.edge_color = 'none'
                args.face_color = 'c'
                args.alpha {mustBeNumeric} = 0.9
            end
            % ---
            argu = f_to_namedarg(args);
            plot@Coil(obj,argu{:}); hold on
            % ---
            etrode = obj.electrode_dom;
            etrode.plot('face_color',f_color(100));
        end
        % -----------------------------------------------------------------
    end
end