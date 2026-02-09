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

classdef OxyArcWire < Xhandle
    properties
        center = [0 0]
        r = 0
        z = 0
        phi1 = 0
        phi2 = 0
        signI = +1
    end
    % --- Constructors
    methods
        function obj = OxyArcWire(args)
            arguments
                args.z {mustBeNumeric}      = 0
                args.center {mustBeNumeric} = [0 0]
                args.r {mustBePositive}
                args.phi1 {mustBeNumeric}
                args.phi2 {mustBeNumeric}
                args.signI {mustBeNumeric}  = 1 % +1 or -1
            end
            % ---
            obj@Xhandle;
            % ---
            obj <= args;
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
            rho = sqrt(lnode(1,:).^2 + lnode(2,:).^2);
            % ---
            phi = acos(lnode(1,:)./rho) .* sign(lnode(2,:));
            dz  = lnode(3,:);
            % ---
            c1 = (obj.r + rho).^2 + dz.^2;
            m = 4*obj.r.*rho ./ c1;
            % ---
            c2 = obj.r^2 + rho.^2 + dz.^2;
            f3_phi1 = 1./sqrt(c2 - 2*obj.r.*rho .* cos(obj.phi1/180*pi - phi));
            f3_phi2 = 1./sqrt(c2 - 2*obj.r.*rho .* cos(obj.phi2/180*pi - phi));
            % ---
            aph1_ = (obj.phi1/180*pi - phi - pi)./2;
            aph2_ = (obj.phi2/180*pi - phi - pi)./2;
            % ---
            elPi_phi1 = mpEllipticPi(aph1_,m,m);
            elPi_phi2 = mpEllipticPi(aph2_,m,m);
            elF_phi1  = mpEllipticF(aph1_,m);
            elF_phi2  = mpEllipticF(aph2_,m);
            % ---
            f4_phi1 = c2./c1.^(3/2) .* elPi_phi1 - 1./sqrt(c1) .* elF_phi1;
            f4_phi2 = c2./c1.^(3/2) .* elPi_phi2 - 1./sqrt(c1) .* elF_phi2;
            % ---
            c3 = rho.^2 - obj.r.^2 + dz.^2;
            f5_phi1 = -c3./c1.^(3/2) .* elPi_phi1 + 1./sqrt(c1) .* elF_phi1;
            f5_phi2 = -c3./c1.^(3/2) .* elPi_phi2 + 1./sqrt(c1) .* elF_phi2;
            % ---
            c4 = dz ./ (rho);
            mu0 = 4*pi*1e-7;
            Bx = mu0*obj.signI*I/(4*pi) .*c4 .* ( ( cos(phi).*f4_phi2 + sin(phi) .* f3_phi2 ) ...
                                                 -( cos(phi).*f4_phi1 + sin(phi) .* f3_phi1 ) );
            By = mu0*obj.signI*I/(4*pi) .*c4 .* ( (-cos(phi).*f3_phi2 + sin(phi) .* f4_phi2 ) ...
                                                 -(-cos(phi).*f3_phi1 + sin(phi) .* f4_phi1 ) );
            Bz = mu0*obj.signI*I/(4*pi) .* (f5_phi2 - f5_phi1);
            % ---
            B = [Bx;By;Bz];
        end
        % ---
        function A = getanode(obj,args)
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
            node = args.node;
            I = args.I;
            % ---
            lnode = obj.local_node(node);
            % ---
            rho = sqrt(lnode(1,:).^2 + lnode(2,:).^2);
            % ---
            phi = atan2(lnode(2,:),lnode(1,:));
            % ---
            dz  = lnode(3,:);
            % ---
            c1 = (obj.r + rho).^2 + dz.^2;
            c2 = (obj.r).^2 + rho.^2 + dz.^2;
            m  = 4*obj.r.*rho ./ c1;
            % --- m must be in (0,1)
            m(m >= 1-1e-6) = 1-1e-6;
            m(m <= 1e-6) = 1e-6;
            % ---
            aph1_ = (obj.phi1/180*pi - phi - pi)./2;
            aph2_ = (obj.phi2/180*pi - phi - pi)./2;
            % ---
            elF_phi1  = mpEllipticF(aph1_,m);
            elF_phi2  = mpEllipticF(aph2_,m);
            elE_phi1  = mpEllipticE(aph1_,m);
            elE_phi2  = mpEllipticE(aph2_,m);
            % ---
            f1_phi1 = sqrt(c2-2.*rho.*obj.r.*cos(obj.phi1/180*pi-phi));
            f1_phi2 = sqrt(c2-2.*rho.*obj.r.*cos(obj.phi2/180*pi-phi));
            % ---
            f2_phi1 = (c2./sqrt(c1)).*elF_phi1-sqrt(c1).*elE_phi1 ;
            f2_phi2 = (c2./sqrt(c1)).*elF_phi2-sqrt(c1).*elE_phi2 ;
            mu0 = 4*pi*1e-7;
            cst = mu0*obj.signI*I./(4*pi*rho);
            % ---
            Ax = cst.*(-f1_phi2.*cos(phi)-f2_phi2.*sin(phi)+f1_phi1.*cos(phi)+f2_phi1.*sin(phi));
            Ay = cst.*(-f1_phi2.*sin(phi)+f2_phi2.*cos(phi)+f1_phi1.*sin(phi)-f2_phi1.*cos(phi));
            Az = zeros(size(Ax));
            A = [Ax; Ay; Az];
        end
        % ---
        function plot(obj,args)
            arguments
                obj
                args.color = 'b'
                args.linewidth = 2
            end
            % ---
            cen = f_tocolv(obj.center);
            z0 = obj.z;
            arccv = @(r,a) [r*cosd(a);  r*sind(a); z0.*ones(size(a))];
            coord = arccv(obj.r, linspace(obj.phi1, obj.phi2, 20));
            plot3(coord(1,:)+cen(1), coord(2,:)+cen(2), coord(3,:), ...
                  'Color',args.color,'LineWidth',args.linewidth);
            axis equal
            % ---
        end
    end
    % ---
    methods (Access = protected)
        function lnode = local_node(obj,node)
            lnode = zeros(size(node));
            lnode(1,:) = node(1,:) - obj.center(1);
            lnode(2,:) = node(2,:) - obj.center(2);
            lnode(3,:) = node(3,:) - obj.z;
        end
    end
end