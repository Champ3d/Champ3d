%--------------------------------------------------------------------------
% This code is written by: Nora TODJIHOUNDE, H-K.Bui, 2025
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

classdef OxyTurnT00b < OxyTurn
    properties
        center = [0 0]
        z = 0
        ri = 0
        ro = 0
        dir = 0
        openi = 0
        openo = 0
        pole = +1
        rwire = 1e-6  % +1 or -1
        % ---
        wire
        dom
    end
    % --- tempo
    properties
        A
        flux
    end
    properties (Constant)
        rmin = 1e-4
    end
    properties (Hidden)
        rnum = 100
        onum = 100
    end
    % --- Constructors
    methods
        function obj = OxyTurnT00b(args)
            arguments
                args.center {mustBeNumeric} = [0 0]
                args.z {mustBeNumeric}      = 0
                args.ri {mustBePositive}    = 1e-4
                args.ro {mustBePositive}    = 0
                args.rwire {mustBePositive} = 1e-6
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
            obj.makedom;
        end
    end
    % ---
    methods
        % ------------------------------------------------------------------
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
            if isequal(obj,turn_obj)
                node = turn_obj.dom.interior.node;
                len  = turn_obj.dom.interior.len;
            else
                node = turn_obj.dom.mean.node;
                len  = turn_obj.dom.mean.len;
            end
            % ---
            A = obj.getanode("node",node,"I",args.I);
            turnflux = sum( A(1,:).*len(1,:) + A(2,:).*len(2,:) + A(3,:).*len(3,:) ) ...
                       .* turn_obj.pole; % ds = Oz = +1 (pole)
            % ---
            obj.A = A;
        end
        % ------------------------------------------------------------------
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
                A = A + obj.wire{i}.getanode("node", args.node, "I", args.I);
            end
        end
        % ------------------------------------------------------------------
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
            turnflux.B = obj.getbnode("node", turn_obj.dom.node, "I", args.I);
            turnflux.flux = sum(turnflux.B(3,:) .* turn_obj.dom.area) .* turn_obj.pole; % ds = Oz = +1 (pole)
        end
        % ------------------------------------------------------------------
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
                B = B + obj.wire{i}.getbnode("node", args.node, "I", args.I);
            end
        end
        % ------------------------------------------------------------------
        function Linterne = getlinterne(obj, args)
            arguments
                obj
                args.I = 1
            end
            % ---
            ri = obj.ri;
            ro = obj.ro;
            ai1 = - obj.openi/2;
            ao1 = - obj.openo/2;
            ai2 = + obj.openi/2;
            ao2 = + obj.openo/2;
            % ---
            P11 = [ri*cosd(ai1); ri*sind(ai1)];
            P12 = [ro*cosd(ao1); ro*sind(ao1)];
            P21 = [ri*cosd(ai2); ri*sind(ai2)];
            P22 = [ro*cosd(ao2); ro*sind(ao2)];
            % ---
            mu0 = 4*pi*1e-7;
            Linterne = (ri*obj.openi*(pi/180) + ro*obj.openo*(pi/180) + ...
                        norm(P11-P12) + norm(P21-P22)) * mu0 / (8*pi);
        end
    end

    % ---
    methods
        % ----------------------------------------------------------
        function rotate(obj, angle)
            obj.dir = obj.dir + angle;
        end
        % ----------------------------------------------------------
        function translate(obj, distance)
            obj.center = obj.center + distance(1:2);
            if length(distance) == 3
                obj.z = obj.z + distance(3);
            end
        end
        % ----------------------------------------------------------
        function scale(obj, args)
            arguments
                obj
                args.distance = 0
            end
            % --- XTODO
            % --- inverse sign w.r.t reduce()
            [obj.ri, obj.ro, obj.openi, obj.openo] = ...
                obj.reduce('distance',-args.distance);
            % ---
        end
        % ----------------------------------------------------------

        % ----------------------------------------------------------
        function plot(obj, args)
            arguments
                obj
                args.color = 'b'
                args.linewidth = 2
            end
            % ---
            obj.setup;
            % ---
            for i = 1:length(obj.wire)
                obj.wire{i}.plot('color', args.color, 'linewidth', args.linewidth); hold on
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
            % ---
            ai2 = obj.dir + obj.openi/2;
            ao2 = obj.dir + obj.openo/2;
            P21 = [obj.ri*cosd(ai2); obj.ri*sind(ai2)];
            P22 = [obj.ro*cosd(ao2); obj.ro*sind(ao2)];
            % -------------------------------------------------------------------
            dl_min = 10e-3;
            % ---
            l12 = norm(P12-P11);
            u12 = (P12 - P11)./l12;
            P0  = P11;
            P1  = P11;
            for il = 1:floor(l12/dl_min)
                wire01 = OxyStraightWire("P1", P0 + (il-1).*dl_min.*u12 + cen, ...
                                         "P2", P0 + il.*dl_min.*u12 + cen, ...
                                         "z", obj.z, "signI", +1*obj.pole);
                obj.wire{end+1} = wire01;
                % ---
                P1 = P0 + il.*dl_min.*u12;
            end
            if ~isequal(P1, P12)
                wire01 = OxyStraightWire("P1", P1 + cen, "P2", P12 + cen, "z", obj.z, "signI", +1*obj.pole);
                obj.wire{end+1} = wire01;
            end
            % ---
            l12 = norm(P22-P21);
            u12 = (P22 - P21)./l12;
            P0  = P21;
            P1  = P21;
            for il = 1:floor(l12/dl_min)
                wire01 = OxyStraightWire("P1", P0 + (il-1).*dl_min.*u12 + cen, ...
                                         "P2", P0 + il.*dl_min.*u12 + cen, ...
                                         "z", obj.z, "signI", -1*obj.pole);
                obj.wire{end+1} = wire01;
                % ---
                P1 = P0 + il.*dl_min.*u12;
            end
            if ~isequal(P1, P22)
                wire01 = OxyStraightWire("P1", P1 + cen, "P2", P22 + cen, "z", obj.z, "signI", -1*obj.pole);
                obj.wire{end+1} = wire01;
            end
            % -------------------------------------------------------------------
            da_min = 10;
            % ---
            phi1_  = ai1;
            while (phi1_ + da_min < ai2)
                wire03 = OxyArcWire("z", obj.z, "center", cen, "phi1", phi1_, "phi2", phi1_+da_min, "r", obj.ri, "signI", -1*obj.pole);
                obj.wire{end+1} = wire03;
                % ---
                phi1_ = phi1_ + da_min;
            end
            if phi1_ < ai2
                wire03 = OxyArcWire("z", obj.z, "center", cen, "phi1", phi1_, "phi2", ai2, "r", obj.ri, "signI", -1*obj.pole);
                obj.wire{end+1} = wire03;
            end
            % ---
            phi1_  = ao1;
            while (phi1_ + da_min < ao2)
                wire03 = OxyArcWire("z", obj.z, "center", cen, "phi1", phi1_, "phi2", phi1_+da_min, "r", obj.ro, "signI", +1*obj.pole);
                obj.wire{end+1} = wire03;
                % ---
                phi1_ = phi1_ + da_min;
            end
            if phi1_ < ao2
                wire03 = OxyArcWire("z", obj.z, "center", cen, "phi1", phi1_, "phi2", ao2, "r", obj.ro, "signI", +1*obj.pole);
                obj.wire{end+1} = wire03;
            end
        end
        % -----------------------------------------------------------------
        function makedom(obj)
            % --- mean dom
            obj.dom.mean = obj.caldom(obj.ri, obj.ro, obj.openi, obj.openo);
            % --- interior dom
            [ri, ro, openi, openo] = obj.reduce;
            obj.dom.interior = obj.caldom(ri, ro, openi, openo);
        end

        % -----------------------------------------------------------------
        function dom = caldom(obj,ri,ro,openi,openo)

            cen = f_tocolv(obj.center); cx = cen(1); cy = cen(2);

            rnum = obj.rnum;
            onum = obj.onum;

            ai1 = obj.dir - openi/2;
            ao1 = obj.dir - openo/2;
            ai2 = obj.dir + openi/2;
            ao2 = obj.dir + openo/2;

            P11 = [ri*cosd(ai1); ri*sind(ai1)] + cen;
            P12 = [ro*cosd(ao1); ro*sind(ao1)] + cen;
            P21 = [ri*cosd(ai2); ri*sind(ai2)] + cen;
            P22 = [ro*cosd(ao2); ro*sind(ao2)] + cen;

            X = []; Y = []; L = []; X_bord = []; Y_bord = [];

            % --- Arc externe (outter arc)

            n_ext = 2*onum;
            alphak_deg    = linspace(ao1, ao2, n_ext+1);
            alpha_mid_deg = 0.5*(alphak_deg(1:end-1) + alphak_deg(2:end));
            X = [X cx + ro * cosd(alpha_mid_deg)];
            Y = [Y cy + ro * sind(alpha_mid_deg)];
            xpoints = cx + ro*cosd(alphak_deg);
            ypoints = cy + ro*sind(alphak_deg);
            ux = diff(xpoints);
            uy = diff(ypoints);
            L = [L [ux; uy; zeros(size(uy))]];

            % --- Coté oblique haut (Up oblique side)

            xdroite = flip(linspace(P21(1), P22(1), rnum+1));
            ydroite = flip(linspace(P21(2), P22(2), rnum+1));
            X = [X (xdroite(1:end-1) + xdroite(2:end))/2];
            Y = [Y (ydroite(1:end-1) + ydroite(2:end))/2];
            ux = diff(xdroite);
            uy = diff(ydroite);
            L = [L [ux; uy; zeros(size(uy))]];

            % --- Arc interne (innner arc)

            alphak_deg = flip(linspace(ai1, ai2, onum+1));
            alpha_mid_deg = 0.5*(alphak_deg(1:end-1) + alphak_deg(2:end));
            X = [X cx + ri * cosd(alpha_mid_deg)];
            Y = [Y cy + ri * sind(alpha_mid_deg)];
            xpoints = cx + ri*cosd(alphak_deg);
            ypoints = cy + ri*sind(alphak_deg);
            ux = diff(xpoints);
            uy = diff(ypoints);
            L = [L [ux; uy; zeros(size(uy))]];

            % --- Coté oblique bas (Low oblique side)

            xdroite = linspace(P11(1), P12(1), rnum+1);
            ydroite = linspace(P11(2), P12(2), rnum+1);
            X = [X (xdroite(1:end-1) + xdroite(2:end))/2];
            Y = [Y (ydroite(1:end-1) + ydroite(2:end))/2];
            ux = diff(xdroite);
            uy = diff(ydroite);
            L = [L [ux; uy; zeros(size(uy))]];
            
            % --- Final
            dom.node = [X; Y; obj.z .* ones(1, length(X))];
            dom.len  = L;
            % ---
        end
        % -----------------------------------------------------------------
        function [ri, ro, openi, openo] = reduce(obj,args)
            arguments
                obj
                args.distance = []
            end
            % -------------------------------------------------------------
            ri1 = obj.ri;
            ro1 = obj.ro;
            oi1 = obj.openi;
            oo1 = obj.openo;
            % -------------------------------------------------------------
            if isempty(args.distance)
                d = obj.rwire;
            else
                d = args.distance;
            end
            % -------------------------------------------------------------
            if d <= 0
                ri = obj.ri;
                ro = obj.ro;
                openi = obj.openi;
                openo = obj.openo;
                return
            end
            % -------------------------------------------------------------
            ri = ri1 + d;               
            ro = ro1 - d;               
            % -------------------------------------------------------------
            if ri <= 0 || ro <= 0 || ri >= ro || d >= (ro1 - ri1)/2
                error('Please check dimensions ! #rwire may be too big !');
            end
            % -------------------------------------------------------------
            Pi1_haut = [ri1*cosd(oi1/2),  ri1*sind(oi1/2)];
            Pi1_bas  = [ri1*cosd(oi1/2), -ri1*sind(oi1/2)];
            Po1_haut = [ro1*cosd(oo1/2),  ro1*sind(oo1/2)];
            Po1_bas  = [ro1*cosd(oo1/2), -ro1*sind(oo1/2)];
            
            u_haut = (Po1_haut - Pi1_haut) / norm(Po1_haut - Pi1_haut);
            u_bas  = (Po1_bas  - Pi1_bas ) / norm(Po1_bas  - Pi1_bas );
            
            n_haut = [-u_haut(2),  u_haut(1)];
            n_bas  = [-u_bas(2),   u_bas(1)];
            
            c1_haut = dot(n_haut, Pi1_haut);
            c1_bas  = dot(n_bas,  Pi1_bas);
            
            c2_haut = c1_haut - d;
            c2_bas  = c1_bas  + d;
            
            % -------------------------------------------------------------
            dmax_haut = min(c1_haut + ri, c1_haut + ro); 
            dmax_bas  = min(ri - c1_bas , ro - c1_bas );
            dmax = min(dmax_haut, dmax_bas);
            if d < 0 || d > dmax
                error('#rwire too big !');
            end
            % -------------------------------------------------------------
            root = @(R2,C2) sqrt(R2 - C2.^2);
            
            Pi2_haut = c2_haut*n_haut + root(ri^2, c2_haut)*u_haut;
            Pi2_bas  = c2_bas *n_bas  + root(ri^2, c2_bas )*u_bas;  
            Po2_haut = c2_haut*n_haut + root(ro^2, c2_haut)*u_haut;
            Po2_bas  = c2_bas *n_bas  + root(ro^2, c2_bas )*u_bas;
            
            Li2 = norm(Pi2_bas - Pi2_haut);
            Lo2 = norm(Po2_bas - Po2_haut);
            arg_i = Li2/(2*ri);
            arg_o = Lo2/(2*ro);
            
            % --- angle interne
            x1 = Pi2_haut(1); 
            y1 = Pi2_haut(2);
            x2 = Pi2_bas(1); 
            y2 = Pi2_bas(2);
            openi = atan2d(abs(x1*y2 - y1*x2), x1*x2 + y1*y2);
            
            % --- angle externe
            x1 = Po2_haut(1);
            y1 = Po2_haut(2);
            x2 = Po2_bas(1);  
            y2 = Po2_bas(2);
            openo = atan2d(abs(x1*y2 - y1*x2), x1*x2 + y1*y2);
        end
        % -----------------------------------------------------------------
    end
end
