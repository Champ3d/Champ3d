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

classdef OxyTurnT00 < OxyTurn
    properties
        center = [0 0]
        z = 0
        ri = 0
        ro = 0
        dir = 0
        openi = 0
        openo = 0
        pole = +1       % +1 or -1
        % ---
        wire
        dom
    end
    % --- tempo
    properties
        B
        flux
    end
    properties (Constant)
        rmin = 1e-4
    end
    properties (Hidden)
        rnum = 10
        onum = 10
    end
    % --- Constructors
    methods
        function obj = OxyTurnT00(args)
            arguments
                args.center {mustBeNumeric} = [0 0]
                args.z {mustBeNumeric}      = 0
                args.ri {mustBePositive}    = 1e-4
                args.ro {mustBePositive}    = 0
                args.dir {mustBeNumeric}    = 0         % angle in deg
                args.openi {mustBePositive} = 0         % angle in deg
                args.openo {mustBePositive} = 0         % angle in deg
                args.pole {mustBeNumeric}   = +1        % +1 or -1
            end
            % ---
            obj@OxyTurn;
            % ---
            if args.ro <= args.ri
                error("#ro must be > #ri");
            end
            % ---
            obj <= args;
            % ---
        end
    end
    % ---
    methods
        function setup(obj)
            obj.makewire;
        end
    end
    % ---
    methods
        function turnflux = getflux(obj, args)
            arguments
                obj
                args.turn_obj {mustBeA(args.turn_obj,"OxyTurn")}
                args.I = 1
            end
            % ---
            if isfield(args,"turn_obj")
                turn_obj = args.turn_obj;
                % ---
                obj.setup;
                turn_obj.setup;
            else
                turn_obj = obj;
                % ---
                obj.setup;
            end
            % ---
            turnflux.B = obj.getbnode("node",turn_obj.dom.node,"I",args.I);
            turnflux.flux = sum(turnflux.B(3,:) .* turn_obj.dom.area) .* turn_obj.pole; % ds = Oz = +1 (pole)
        end
        function B = getbnode(obj, args)
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
            B = 0;
            for i = 1:length(obj.wire)
                B = B + obj.wire{i}.getbnode("node",args.node,"I",args.I);
            end
        end
    end
    % ---
    methods
        function rotate(obj,angle)
            obj.dir = obj.dir + angle;
        end
        function translate(obj,distance)
            obj.center = obj.center + distance(1:2);
            if length(distance) == 3
                obj.z = obj.z + distance(3);
            end
        end
        function scale(obj,distance)
            % ---
            ri0 = obj.ri;
            ro0 = obj.ro;
            % ---
            argleni = ri0 * obj.openi/180*pi;
            argleno = ro0 * obj.openo/180*pi;
            if argleno <= 2*distance || ro0 <= ri0 + 2*distance
                obj = OxyTurn;
                return
            end
            % ---
            a1 = argleni;
            a2 = argleno;
            % ---
            b1 = a1*(ro0 - ri0)/(a2 - a1);
            axi = 2*distance;
            b2 = (axi - a1)*b1/a1;
            % ---
            ri_ = ri0 + b2;
            if ri_ <= obj.ri + distance
                obj.ri = obj.ri + distance;
            else
                obj.ri = ri_;
            end
            % ---
            axi = a1*(b1 + (obj.ri - ri0))/b1;
            % ---
            obj.ro = obj.ro - distance;
            % ---
            oai = interp1([a1/ri0, a2/ro0], [sind(obj.openi), sind(obj.openo)], axi/obj.ri);
            oai = asind(oai);
            % ---
            axo = a1*(b1 + (obj.ro - ri0))/b1;
            oao = interp1([a1/ri0, a2/ro0], [sind(obj.openi), sind(obj.openo)], axo/obj.ro);
            oao = asind(oao);
            % ---
            obj.openi = oai - distance/axi*oai;
            obj.openo = oao - distance/axo*oao;
            % ---
        end
        function plot(obj,args)
            arguments
                obj
                args.color = 'b'
                args.linewidth = 2
            end
            % ---
            obj.setup;
            % ---
            for i = 1:length(obj.wire)
                obj.wire{i}.plot('color',args.color,'linewidth',args.linewidth); hold on
            end
        end
    end
    % ---
    methods (Access = protected)
        function makewire(obj)
            % --- WIRE
            obj.wire = {};
            % ---
            cen = f_tocolv(obj.center);
            ai1 = obj.dir - obj.openi/2;
            ao1 = obj.dir - obj.openo/2;
            P11 = [obj.ri*cosd(ai1); obj.ri*sind(ai1)];
            P12 = [obj.ro*cosd(ao1); obj.ro*sind(ao1)];
            wire01 = OxyStraightWire("P1",P11+cen,"P2",P12+cen,"z",obj.z,"signI",+1*obj.pole);
            % ---
            obj.wire{end+1} = wire01;
            % ---
            ai2 = obj.dir + obj.openi/2;
            ao2 = obj.dir + obj.openo/2;
            P21 = [obj.ri*cosd(ai2); obj.ri*sind(ai2)];
            P22 = [obj.ro*cosd(ao2); obj.ro*sind(ao2)];
            wire02 = OxyStraightWire("P1",P21+cen,"P2",P22+cen,"z",obj.z,"signI",-1*obj.pole);
            % ---
            obj.wire{end+1} = wire02;
            % -------------------------------------------------------------------
            wire03 = OxyArcWire("z",obj.z,"center",cen,"phi1",ai1,"phi2",ai2,"r",obj.ri,"signI",-1*obj.pole);
            % ---
            obj.wire{end+1} = wire03;
            % ---
            wire04 = OxyArcWire("z",obj.z,"center",cen,"phi1",ao1,"phi2",ao2,"r",obj.ro,"signI",+1*obj.pole);
            % ---
            obj.wire{end+1} = wire04;
            % -------------------------------------------------------------------
            % --- DOM
            P21 = f_rotaroundaxis(P21,"axis_origin",[0 0 0],"rot_axis",[0 0 1],"rot_angle",-obj.dir);
            P22 = f_rotaroundaxis(P22,"axis_origin",[0 0 0],"rot_axis",[0 0 1],"rot_angle",-obj.dir);
            x1 = linspace(P21(1), P22(1), obj.rnum + 1);
            y1 = linspace(P21(2), P22(2), obj.rnum + 1);
            % ---
            r1 = sqrt(x1.^2 + y1.^2);
            a1 = 2.*acosd(x1./r1);
            % ---
            x2 = (x1(1:end-1) + x1(2:end))./2;
            y2 = (y1(1:end-1) + y1(2:end))./2;
            % ---
            r2 = sqrt(x2.^2 + y2.^2);
            a2 = 2.*acosd(x2./r2);
            % ---
            x_ = [];
            y_ = [];
            s_ = [];
            % ---
            for i = 1:obj.rnum
                a3 = linspace(obj.dir - a2(i)/2, obj.dir + a2(i)/2, obj.onum + 1);
                a3 = (a3(1:end-1) + a3(2:end))./2;
                % ---
                x_ = [x_, r2(i) .* cosd(a3)];
                y_ = [y_, r2(i) .* sind(a3)];
                % ---
                a4 = linspace(obj.dir - a1(i)/2, obj.dir + a1(i)/2, obj.onum + 1);
                a5 = linspace(obj.dir - a1(i+1)/2, obj.dir + a1(i+1)/2, obj.onum + 1);
                a4 = diff(a4);
                a5 = diff(a5);
                % --- approximation
                s_ = [s_, 1/2 .* (r1(i+1) - r1(i)) .* (a5.*(pi/180).*r1(i+1) + a4.*(pi/180).*r1(i))];
                %s_ = [s_, 1/2 .* (r1(i+1) - r1(i)) .* (2.*sind(a5./2).*r1(i+1) + 2.*sind(a4./2).*r1(i))];
            end
            z_ = obj.z .* ones(size(x_));
            % ---
            obj.dom.node = [x_+cen(1); y_+cen(2); z_];
            obj.dom.area = s_;
            % ---
        end
    end
end


