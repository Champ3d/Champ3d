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

classdef Sibc < PhysicalDom

    properties (SetObservable)
        sigma = 0
        mur = 1
        r_ht = 0
        r_et = 0
        cparam = 0
    end

    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'parent_model','id_dom2d','id_dom3d','sigma','mur', ...
                        'r_ht','r_et'};
        end
    end
    % --- Contructor
    methods
        function obj = Sibc(args)
            arguments
                args.parent_model
                args.id_dom2d
                args.id_dom3d
                args.sigma
                args.mur
                args.r_ht {mustBeNumeric}
                args.r_et {mustBeNumeric}
            end
            % ---
            obj = obj@PhysicalDom;
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
            setup@PhysicalDom(obj);
            % ---
            cparam_ = 0;
            if ~isempty(obj.r_ht) && ~isempty(obj.r_et)
                cparam_ = 1/obj.r_ht - 1/obj.r_et;
            elseif ~isempty(obj.r_ht)
                cparam_ = 1/obj.r_ht;
            elseif ~isempty(obj.r_et)
                cparam_ = - 1/obj.r_et;
            end
            % ---
            obj.cparam = Parameter('f',cparam_);
            % ---
        end
    end
end
