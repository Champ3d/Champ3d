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

classdef OxyTurnT01b < OxyTurn
    properties
        center = [0 0]
        z = 0
        r = 0
        pole = +1       % +1 or -1
        rwire = 1e-6;
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
        anum = 1000
    end
    % --- Constructors
    methods
        function obj = OxyTurnT01b(args)
            arguments
                args.center {mustBeNumeric} = [0 0]
                args.z {mustBeNumeric}      = 0
                args.r {mustBePositive}     = 1e-4
                args.rwire {mustBePositive} = 1e-6
                args.pole {mustBeNumeric}   = +1        % +1 or -1
            end
            % ---
            obj@OxyTurn;
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
            A = obj.getanode("node",turn_obj.dom.node,"I",args.I);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% !!!!!!!!!!!!!!!!!!!!!!!
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TO CHECK could be
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% turn_obj instead
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% of obj
            turnflux = sum( A(1,:).*obj.dom.len(1,:) + A(2,:).*obj.dom.len(2,:) + A(3,:).*obj.dom.len(3,:) ) ...
                       .* turn_obj.pole; % ds = Oz = +1 (pole)
        end
        function A = getanode(obj, args)
            arguments
                obj
                args.node (3,:) {mustBeNumeric}
                args.I = 1
            end
            % ---
            if ~isfield(args,"node")
                A = [];
                return
            end
            % ---
            A = 0;
            for i = 1:length(obj.wire)
                A = A + obj.wire{i}.getanode("node",args.node,"I",args.I);
            end
        end
        function turnflux = getbds(obj, args)
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
        function translate(obj,distance)
            obj.center = obj.center + distance(1:2);
            if length(distance) == 3
                obj.z = obj.z + distance(3);
            end
            obj.setup;
        end
        function scale(obj,distance)
            obj.r = obj.r + distance;
            obj.setup;
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
            % -------------------------------------------------------------------
            wire01 = OxyArcWire("z",obj.z,"center",cen,"phi1",0,"phi2",180,"r",obj.r,"signI",+1*obj.pole);
            % ---
            obj.wire{end+1} = wire01;
            % ---
            wire02 = OxyArcWire("z",obj.z,"center",cen,"phi1",180,"phi2",360,"r",obj.r,"signI",+1*obj.pole);
            % ---
            obj.wire{end+1} = wire02;
            % -------------------------------------------------------------------
            % --- DOM
            % x_ = [];
            % y_ = [];
            % s_ = [];
            % rdiv = linspace(0,obj.r - obj.rwire,obj.rnum);
            % dr = rdiv(2) - rdiv(1);
            % rcen = (rdiv(1:end-1) + rdiv(2:end))./2;
            % for i = 1:length(rcen)
            %     adiv = linspace(0, 2*pi, obj.anum + i);
            %     da = adiv(2) - adiv(1);
            %     x_ = [x_, rcen(i) .* cos(adiv)];
            %     y_ = [y_, rcen(i) .* sin(adiv)];
            %     s_ = [s_, ((rdiv(i+1)^2 - rdiv(i)^2) .* da/pi) .* ones(1,length(adiv))];
            % end
            % % ---
            % z_ = obj.z .* ones(size(x_));
            % obj.dom.node = [x_+cen(1); y_+cen(2); z_];
            % obj.dom.area = s_;
            % ---
            adiv = linspace(0, 2*pi, obj.anum);
            rdiv = obj.r - obj.rwire;
            x_ = rdiv .* cos(adiv) + cen(1);
            y_ = rdiv .* sin(adiv) + cen(2);
            % ---
            vdiv = zeros(3,length(adiv) - 1);
            vdiv(1,:) = x_(2:end) - x_(1:end-1);
            vdiv(2,:) = y_(2:end) - y_(1:end-1);
            % ---
            obj.dom.node = [x_(1:end-1) ; y_(1:end-1); obj.z .* ones(1,length(x_)-1)];
            obj.dom.len  = vdiv;
        end
    end
end
