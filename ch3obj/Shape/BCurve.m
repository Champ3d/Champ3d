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

classdef BCurve < CurveShape
    properties
        start_node = [0 0]
        type
        go = {}
        x
        y
        z
        flag
    end
    % --- Constructors
    methods
        function obj = BCurve(args)
            arguments
                args.start_node = []
                args.type {mustBeMember(args.type,{'open','closed'})}
            end
            % ---
            obj = obj@CurveShape;
            % ---
            if isempty(args.start_node)
                error('#start_node must be given !');
            elseif length(args.start_node) ~= 3
                error('#start_node must be of dim 3 !');
            end
            % ---
            if ~isfield(args,'type')
                error('#type must be given !');
            end
            % ---
            obj <= args;
            % ---
        end
    end
    % --- setup/reset
    methods (Static)
        function setup(obj)
            obj.set_parameter;
        end
    end
    methods (Access = public)
        function reset(obj)
            BCurve.setup(obj);
            % --- reset dependent obj
            obj.reset_dependent_obj;
        end
    end
    % --- Methods
    methods
        %------------------------------------------------------------------
        function xgo(obj,args)
            arguments
                obj
                args.len (1,1) = 0
                args.dnum (1,1) = 1
            end
            % ---
            obj.go{end + 1} = struct('type','xgo','len',args.len,'dnum',args.dnum);
            % ---
        end
        %------------------------------------------------------------------
        function ygo(obj,args)
            arguments
                obj
                args.len (1,1) = 0
                args.dnum (1,1) = 1
            end
            % ---
            obj.go{end + 1} = struct('type','ygo','len',args.len,'dnum',args.dnum);
            % ---
        end
        %------------------------------------------------------------------
        function zgo(obj,args)
            arguments
                obj
                args.len (1,1) = 0
                args.dnum (1,1) = 1
            end
            % ---
            obj.go{end + 1} = struct('type','zgo','len',args.len,'dnum',args.dnum);
            % ---
        end
        %------------------------------------------------------------------
        function xygo(obj,args)
            arguments
                obj
                args.lenx (1,1) = 0
                args.leny (1,1) = 0
                args.dnum (1,1) = 1
            end
            % ---
            obj.go{end + 1} = struct('type','xygo','lenx',args.lenx,'leny',args.leny,'dnum',args.dnum);
            % ---
        end
        %------------------------------------------------------------------
        function xzgo(obj,args)
            arguments
                obj
                args.lenx (1,1) = 0
                args.lenz (1,1) = 0
                args.dnum (1,1) = 1
            end
            % ---
            obj.go{end + 1} = struct('type','xzgo','lenx',args.lenx,'lenz',args.lenz,'dnum',args.dnum);
            % ---
        end
        %------------------------------------------------------------------
        function yzgo(obj,args)
            arguments
                obj
                args.leny (1,1) = 0
                args.lenz (1,1) = 0
                args.dnum (1,1) = 1
            end
            % ---
            obj.go{end + 1} = struct('type','yzgo','leny',args.leny,'lenz',args.lenz,'dnum',args.dnum);
            % ---
        end
        %------------------------------------------------------------------
        function xyzgo(obj,args)
            arguments
                obj
                args.lenx (1,1) = 0
                args.leny (1,1) = 0
                args.lenz (1,1) = 0
                args.dnum (1,1) = 1
            end
            % ---
            obj.go{end + 1} = struct('type','xyzgo','lenx',args.lenx,'leny',args.leny,'lenz',args.lenz,'dnum',args.dnum);
            % ---
        end
        %------------------------------------------------------------------
        function ago_xy(obj,args)
            arguments
                obj
                args.angle (1,1) = 180
                args.center
                args.dnum (1,1) = 5
                args.dir {mustBeMember(args.dir,{'auto','ccw','clock'})} = 'auto'
            end
            % ---
            obj.go{end + 1} = struct('type','ago_xy','angle',args.angle, ...
                'center',args.center,'dnum',args.dnum,'dir',args.dir);
            % ---
        end
        %------------------------------------------------------------------
        function ago_xz(obj,args)
            arguments
                obj
                args.angle (1,1) = 180
                args.center
                args.dnum (1,1) = 5
                args.dir {mustBeMember(args.dir,{'auto','ccw','clock'})} = 'auto'
            end
            % ---
            obj.go{end + 1} = struct('type','ago_xz','angle',args.angle, ...
                'center',args.center,'dnum',args.dnum,'dir',args.dir);
            % ---
        end
        %------------------------------------------------------------------
        function ago_yz(obj,args)
            arguments
                obj
                args.angle (1,1) = 180
                args.center
                args.dnum (1,1) = 5
                args.dir {mustBeMember(args.dir,{'auto','ccw','clock'})} = 'auto'
            end
            % ---
            obj.go{end + 1} = struct('type','ago_yz','angle',args.angle, ...
                'center',args.center,'dnum',args.dnum,'dir',args.dir);
            % ---
        end
        %------------------------------------------------------------------
        function geocode = geocode(obj)
            obj.get_curve;
            % ---
            c = obj.center.getvalue;
            r = obj.r.getvalue;
            hei = obj.hei.getvalue;
            opening_angle = obj.opening_angle.getvalue;
            orientation = obj.orientation.getvalue;
            % ---
            geocode = GMSHWriter.bcylinder(c,r,hei,opening_angle,orientation);
            % ---
            geocode = obj.transformgeocode(geocode);
            % ---
        end
        %------------------------------------------------------------------
    end
    % --- 
    methods (Access = private)
        %------------------------------------------------------------------
        function get_curve(obj)
            x_ = {obj.start_node(1)};
            y_ = {obj.start_node(2)};
            z_ = {obj.start_node(3)};
            flag_ = {};
            for i = 1:length(obj.go)
                go_ = obj.go{i};
                switch go_.type
                    case 'xgo'
                        % --- XTODO for Parameter
                        len = go_.len;
                        if len ~= 0
                            x_{end + 1} = x_{end} + len;
                            y_{end + 1} = y_{end};
                            z_{end + 1} = z_{end};
                        end
                    case 'ygo'
                        len = go_.len;
                        if len ~= 0
                            x_{end + 1} = x_{end};
                            y_{end + 1} = y_{end} + len;
                            z_{end + 1} = z_{end};
                        end
                    case 'zgo'
                        len = go_.len;
                        if len ~= 0
                            x_{end + 1} = x_{end};
                            y_{end + 1} = y_{end};
                            z_{end + 1} = z_{end} + len;
                        end
                    case 'xygo'
                        lenx = go_.lenx;
                        leny = go_.leny;
                        if lenx ~= 0 || leny ~= 0
                            x_{end + 1} = x_{end} + lenx;
                            y_{end + 1} = y_{end} + leny;
                            z_{end + 1} = z_{end};
                        end
                    case 'xzgo'
                        lenx = go_.lenx;
                        lenz = go_.lenz;
                        if lenx ~= 0 || lenz ~= 0
                            x_{end + 1} = x_{end} + lenx;
                            y_{end + 1} = y_{end};
                            z_{end + 1} = z_{end} + lenz;
                        end
                    case 'yzgo'
                        leny = go_.leny;
                        lenz = go_.lenz;
                        if leny ~= 0 || lenz ~= 0
                            x_{end + 1} = x_{end};
                            y_{end + 1} = y_{end} + leny;
                            z_{end + 1} = z_{end} + lenz;
                        end
                    case 'xyzgo'
                        lenx = go_.lenx;
                        leny = go_.leny;
                        lenz = go_.lenz;
                        if lenx ~= 0 || leny ~= 0 || lenz ~= 0
                            x_{end + 1} = x_{end} + lenx;
                            y_{end + 1} = y_{end} + leny;
                            z_{end + 1} = z_{end} + lenz;
                        end
                    case 'ago_xy'
                        angle = go_.angle;
                        dir = go_.dir;
                        % ---
                        switch dir
                            case 'ccw'
                                angle = +abs(angle);
                            case 'clock'
                                angle = -abs(angle);
                        end
                        % ---
                        dnum   = go_.dnum;
                        da     = angle/dnum;
                        center = [go_.center(1) go_.center(2)];
                        p02d = [x_{end} y_{end}];
                        p03d = [x_{end} y_{end} z_{end}];
                        % ---
                        [dx, dy] = obj.cal_ago2d(da,dnum,p02d,center);
                        % ---
                        for idx = 1:length(dx)
                            x_{end + 1} = p02d(1) + dx(idx);
                            y_{end + 1} = p02d(2) + dy(idx);
                            z_{end + 1} = z_{end};
                        end
                        % ---
                        p13d = [x_{end} y_{end} z_{end}];
                        flagnode = (p03d + p13d)./2;
                        % ---
                    case 'ago_xz'
                        angle = go_.angle;
                        dir = go_.dir;
                        % ---
                        switch dir
                            case 'ccw'
                                angle = +abs(angle);
                            case 'clock'
                                angle = -abs(angle);
                        end
                        % ---
                        dnum   = go_.dnum;
                        da     = angle/dnum;
                        center = [go_.center(1) go_.center(3)];
                        p02d = [x_{end} z_{end}];
                        p03d = [x_{end} y_{end} z_{end}];
                        % ---
                        [dx, dz] = obj.cal_ago2d(da,dnum,p02d,center);
                        % ---
                        for idx = 1:length(dx)
                            x_{end + 1} = p02d(1) + dx(idx);
                            y_{end + 1} = y_{end};
                            z_{end + 1} = p02d(2) + dz(idx);
                        end
                        % ---
                        p13d = [x_{end} y_{end} z_{end}];
                        flagnode = (p03d + p13d)./2;
                        % ---
                    case 'ago_yz'
                        angle = go_.angle;
                        dir = go_.dir;
                        % ---
                        switch dir
                            case 'ccw'
                                angle = +abs(angle);
                            case 'clock'
                                angle = -abs(angle);
                        end
                        % ---
                        dnum   = go_.dnum;
                        da     = angle/dnum;
                        center = [go_.center(2) go_.center(3)];
                        p02d = [y_{end} z_{end}];
                        p03d = [x_{end} y_{end} z_{end}];
                        % ---
                        [dy, dz] = obj.cal_ago2d(da,dnum,p02d,center);
                        % ---
                        for idy = 1:length(dy)
                            x_{end + 1} = x_{end};
                            y_{end + 1} = p02d(1) + dy(idy);
                            z_{end + 1} = p02d(2) + dz(idy);
                        end
                        % ---
                        p13d = [x_{end} y_{end} z_{end}];
                        flagnode = (p03d + p13d)./2;
                        % ---
                end
                % --- flag
                switch go_.type
                    case {'xgo','ygo','zgo','xygo','xzgo','yzgo','xyzgo'}
                        % ---
                        idflag = length(flag_);
                        flag_{idflag+1}.node = ...
                            [x_{end-1} y_{end-1} z_{end-1}];
                        flag_{idflag+1}.vector = ...
                            [x_{end} y_{end} z_{end}] - [x_{end-1} y_{end-1} z_{end-1}];
                        flag_{idflag+1}.vector = ...
                            flag_{idflag+1}.vector ./ norm(flag_{idflag+1}.vector);
                        % ---
                    case 'ago_xy'
                        % ---
                        idflag = length(flag_);
                        flag_{idflag+1}.node = flagnode;
                        flag_{idflag+1}.vector = [0 0 1];
                        % ---
                    case 'ago_xz'
                        % ---
                        idflag = length(flag_);
                        flag_{idflag+1}.node = flagnode;
                        flag_{idflag+1}.vector = [0 1 0];
                        % ---
                    case 'ago_yz'
                        % ---
                        idflag = length(flag_);
                        flag_{idflag+1}.node = flagnode;
                        flag_{idflag+1}.vector = [1 0 0];
                        % ---
                end
            end
            % ---
            x_ = cell2mat(x_);
            y_ = cell2mat(y_);
            z_ = cell2mat(z_);
            % ---
            switch obj.type
                % --- XTODO : put tol in config
                case 'open'
                    if norm([x_(1) y_(1) z_(1)] - [x_(end) y_(end) z_(end)]) < 1e-9
                        f_fprintf(1,'/!\\',0,'bcurve terminals very close, d < 1e-9 !\n');
                    end
                case 'closed'
                    f_fprintf(1,'/!\\',0,'Champ3d has forced last node = first node !\n');
                    x_(end) = x_(1);
                    y_(end) = y_(1);
                    z_(end) = z_(1);
            end
            % ---
            obj.x = x_;
            obj.y = y_;
            obj.z = z_;
            obj.flag = flag_;
            % ---
        end
        %------------------------------------------------------------------
        function [dx, dy] = cal_ago2d(obj,da,dnum,p0,center)
            % ---
            if dnum == 0 || norm(p0 - center) < 1e-9
                dx = [];
                dy = [];
                return
            end
            % ---
            dx = zeros(1,dnum);
            dy = zeros(1,dnum);
            % ---
            for i = 1:dnum
                r = norm(p0 - center);
                lOx = (p0 - center);
                gOx = [1 0];
                rot_angle = acosd(dot(lOx,gOx) / (norm(lOx) * norm(gOx)));
                rot_axis = cross([1 0 0],[lOx 0]);
                if norm(rot_axis) < 1e-12
                    rot_axis = [0 0 -sign(dot([1 0 0],[lOx 0]))];
                end
                % ---
                lvmove = [r * cosd(i*da), r * sind(i*da)];
                % ---
                dv = lvmove - [r 0];
                dv = f_rotaroundaxis(dv.','rot_angle',rot_angle, ...
                    'rot_axis',rot_axis,'axis_origin',[0 0 0]);
                % ---
                dx(i) = dv(1);
                dy(i) = dv(2);
            end
        end
        %------------------------------------------------------------------
    end
    % --- Plot
    methods
        function plot(obj)
            obj.get_curve;
            plot3(obj.x,obj.y,obj.z,'-b','LineWidth',3); hold on;
            nbflag = length(obj.flag);
            node = zeros(3,nbflag);
            vect = zeros(3,nbflag);
            for i = 1:length(obj.flag)
                node(:,i) = obj.flag{i}.node.';
                vect(:,i) = obj.flag{i}.vector.';
            end
            % ---
            dx = diff(obj.x); dy = diff(obj.y); dz = diff(obj.z);
            dmax = max(norm([dx;dy;dz]));
            % ---
            f_quiver(node,vect,'sfactor',dmax/40); colorbar off;
        end
    end
end
