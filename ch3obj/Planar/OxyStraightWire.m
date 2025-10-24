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
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef OxyStraightWire < Xhandle
    properties
        P1 = [0 0]
        P2 = [0 0]
        z = 0
        signI = +1
    end
    properties (Hidden)
        rot_axis = [0; 0; 1]
    end
    properties (Hidden)
        tol = 1e-6;
    end
    properties (Dependent)
        rot_angle
        len
    end
    % --- Constructors
    methods
        function obj = OxyStraightWire(args)
            arguments
                args.P1 {mustBeNumeric}
                args.P2 {mustBeNumeric}
                args.z {mustBeNumeric}      = 0  
                args.signI {mustBeNumeric}  = 1 % +1 or -1
            end
            % ---
            obj@Xhandle;
            % ---
            if norm(args.P2 - args.P1) < obj.tol
                error('Wire is too short < 1um');
            end
            % ---
            obj <= args;
            % ---
        end
    end
    % --- set/get
    methods
        function rotangle = get.rot_angle(obj)
            % lOx_in_gcoor
            V12 = obj.P2 - obj.P1;
            lOx = V12./vecnorm(V12);
            % ---
            gOx = [1; 0];
            rotangle = atan2d(lOx(1)*gOx(2)-lOx(2)*gOx(1),lOx(1)*gOx(1)+lOx(2)*gOx(2));
        end
        function len = get.len(obj)
            V12 = obj.P2 - obj.P1;
            len = vecnorm(V12);
        end
    end
    % ---
    methods
        function B = getbnode(obj,args)
            arguments
                obj
                args.node (3,:) {mustBeNumeric}
                args.I = 1
            end
            % ---
            if ~isfield(args,"node")
                B = [];
                return
            end
            % ---
            node = args.node;
            I = args.I;
            % ---
            lnode = obj.local_node(node);
            % ---
            u  = lnode(2,:);
            v  = lnode(3,:);
            a2 = u.^2 + v.^2;
            w1 = lnode(1,:);
            w2 = lnode(1,:) - obj.len;
            % ---
            d1 = sqrt(a2 + w1.^2);
            d2 = sqrt(a2 + w2.^2);
            d1(d1 == 0) = 1e-8;
            d2(d2 == 0) = 1e-8;
            % ---
            mu0 = 4*pi*1e-7;
            By = mu0*obj.signI*I/(4*pi) .* ( v./a2 .* (w2./d2 - w1./d1));
            Bz = mu0*obj.signI*I/(4*pi) .* (-u./a2 .* (w2./d2 - w1./d1));
            Bx = zeros(size(By));
            % ---
            lfield = [Bx;By;Bz];
            B = obj.global_field(lfield);
        end
        function plot(obj,args)
            arguments
                obj
                args.color = 'b'
                args.linewidth = 2
            end
            % ---
            plot3([obj.P1(1); obj.P2(1)],[obj.P1(2); obj.P2(2)],[obj.z; obj.z], ...
                  'Color',args.color,'LineWidth',args.linewidth);
        end
    end
    % ---
    methods (Access = protected)
        function lnode = local_node(obj,node)
            lnode = zeros(size(node));
            lnode(1,:) = node(1,:) - obj.P1(1);
            lnode(2,:) = node(2,:) - obj.P1(2);
            lnode(3,:) = node(3,:) - obj.z;
            % ---
            lnode = f_rotaroundaxis(lnode,'rot_angle',+obj.rot_angle, ...
                    'rot_axis',obj.rot_axis,'axis_origin',[0; 0; 0]);
            % ---
        end
        % ---
        function gfield = global_field(obj,lfield)
            % ---
            gfield = f_rotaroundaxis(lfield,'rot_angle',-obj.rot_angle, ...
                    'rot_axis',obj.rot_axis,'axis_origin',[0; 0; 0]);
            % ---
        end
    end
end