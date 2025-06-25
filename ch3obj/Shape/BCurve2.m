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

classdef BCurve2 < CurveShape
    properties
        start_node = [0 0]
        type
        go = {}
        x
        y
        z
        flag
        fit = []
    end
    % --- Constructors
    methods
        function obj = BCurve2(args)
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
            BCurve2.set_parameter(obj);
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
            BCurve2.setup(obj);
            % --- reset dependent obj
            obj.reset_dependent_obj;
        end
    end
    % --- Methods / go
    methods
        %------------------------------------------------------------------
        function xgo(obj,args)
            arguments
                obj
                args.len (1,1) = 0
                args.dnum (1,1) = 1
                args.id char = ''
            end
            % ---
            if args.len ~= 0
                obj.go{end + 1} = struct('id',args.id,'type','xgo','len',args.len,'dnum',args.dnum);
            end
            % ---
        end
        %------------------------------------------------------------------
        function ygo(obj,args)
            arguments
                obj
                args.len (1,1) = 0
                args.dnum (1,1) = 1
                args.id char = ''
            end
            % ---
            if args.len ~= 0
                obj.go{end + 1} = struct('id',args.id,'type','ygo','len',args.len,'dnum',args.dnum);
            end
            % ---
        end
        %------------------------------------------------------------------
        function zgo(obj,args)
            arguments
                obj
                args.len (1,1) = 0
                args.dnum (1,1) = 1
                args.id char = ''
            end
            % ---
            if args.len ~= 0
                obj.go{end + 1} = struct('id',args.id,'type','zgo','len',args.len,'dnum',args.dnum);
            end
            % ---
        end
        %------------------------------------------------------------------
        function xygo(obj,args)
            arguments
                obj
                args.lenx (1,1) = 0
                args.leny (1,1) = 0
                args.dnum (1,1) = 1
                args.id char = ''
            end
            % ---
            if args.lenx ~= 0 || args.leny ~= 0
                obj.go{end + 1} = struct('id',args.id,'type','xygo','lenx',args.lenx,'leny',args.leny,'dnum',args.dnum);
            end
            % ---
        end
        %------------------------------------------------------------------
        function xzgo(obj,args)
            arguments
                obj
                args.lenx (1,1) = 0
                args.lenz (1,1) = 0
                args.dnum (1,1) = 1
                args.id char = ''
            end
            % ---
            if args.lenx ~= 0 || args.lenz ~= 0
                obj.go{end + 1} = struct('id',args.id,'type','xzgo','lenx',args.lenx,'lenz',args.lenz,'dnum',args.dnum);
            end
            % ---
        end
        %------------------------------------------------------------------
        function yzgo(obj,args)
            arguments
                obj
                args.leny (1,1) = 0
                args.lenz (1,1) = 0
                args.dnum (1,1) = 1
                args.id char = ''
            end
            % ---
            if args.leny ~= 0 || args.lenz ~= 0
                obj.go{end + 1} = struct('id',args.id,'type','yzgo','leny',args.leny,'lenz',args.lenz,'dnum',args.dnum);
            end
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
                args.id char = ''
            end
            % ---
            if args.lenx ~= 0 || args.leny ~= 0 || args.lenz ~= 0
                obj.go{end + 1} = struct('id',args.id,'type','xyzgo','lenx',args.lenx,'leny',args.leny,'lenz',args.lenz,'dnum',args.dnum);
            end
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
                args.id char = ''
            end
            % ---
            obj.go{end + 1} = struct('id',args.id,'type','ago_xy','angle',args.angle, ...
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
                args.id char = ''
            end
            % ---
            obj.go{end + 1} = struct('id',args.id,'type','ago_xz','angle',args.angle, ...
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
                args.id char = ''
            end
            % ---
            obj.go{end + 1} = struct('id',args.id,'type','ago_yz','angle',args.angle, ...
                'center',args.center,'dnum',args.dnum,'dir',args.dir);
            % ---
        end
    end

    % --- Methods / handling
    methods
        %------------------------------------------------------------------
        function flagfit(obj,args)
            arguments
                obj
                args.id_flag char
                args.destination
                args.orientation
                args.rotation = 0
            end
            % ---
            obj.fit = struct('id_flag',args.id_flag,...
                'destination',args.destination,'orientation',args.orientation, ...
                'rotation',args.rotation);
            % ---
        end
        %------------------------------------------------------------------
    end

    % --- Methods / geocode
    methods
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
    
    % --- private
    methods (Access = private)
        %------------------------------------------------------------------
        function div(obj,args)
            arguments
                obj
                args.id_flag char
                args.destination
                args.orientation
            end
            % ---
            obj.fit = struct('id_flag',args.id_flag,...
                'destination',args.destination,'orientation',args.orientation);
            % ---
        end
        %------------------------------------------------------------------
        function get_go(obj)
            % ---
            node = {[obj.start_node(1), obj.start_node(2), obj.start_node(3)]};
            flag_ = {};
            % ---
            for i = 1:length(obj.go)
                go_ = obj.go{i};
                switch go_.type
                    case 'xgo'
                        len = go_.len.getvalue;
                        go_.vlen = len .* [1 0 0];
                        go_.vi = go_.vlen ./ norm(go_.vlen);
                        go_.vf = go_.vi;
                    case 'ygo'
                        len = go_.len.getvalue;
                        go_.vlen = len .* [0 1 0];
                        go_.vi = go_.vlen ./ norm(go_.vlen);
                        go_.vf = go_.vi;
                    case 'zgo'
                        len = go_.len.getvalue;
                        go_.vlen = len .* [0 0 1];
                        go_.vi = go_.vlen ./ norm(go_.vlen);
                        go_.vf = go_.vi;
                    case 'xygo'
                        lenx = go_.lenx.getvalue;
                        leny = go_.leny.getvalue;
                        go_.vlen = [lenx, leny, 0];
                        go_.vi = go_.vlen ./ norm(go_.vlen);
                        go_.vf = go_.vi;
                    case 'xzgo'
                        lenx = go_.lenx.getvalue;
                        lenz = go_.lenz.getvalue;
                        go_.vlen = [lenx, 0, lenz];
                        go_.vi = go_.vlen ./ norm(go_.vlen);
                        go_.vf = go_.vi;
                    case 'yzgo'
                        leny = go_.leny.getvalue;
                        lenz = go_.lenz.getvalue;
                        go_.vlen = [0, leny, lenz];
                        go_.vi = go_.vlen ./ norm(go_.vlen);
                        go_.vf = go_.vi;
                    case 'xyzgo'
                        lenx = go_.lenx.getvalue;
                        leny = go_.leny.getvalue;
                        lenz = go_.lenz.getvalue;
                        go_.vlen = [lenx, leny, lenz];
                        go_.vi = go_.vlen ./ norm(go_.vlen);
                        go_.vf = go_.vi;
                    case {'ago_xy','ago_xz','ago_yz'}
                        angle = go_.angle.getvalue;
                        dir = go_.dir;
                        % ---
                        switch dir
                            case 'ccw'
                                angle = +abs(angle);
                            case 'clock'
                                angle = -abs(angle);
                        end
                        % ---
                        center = go_.center.getvalue;
                        % ---
                        p03d = node{end};
                        % ---
                        dx0 = 0; dy0 = 0; dz0 = 0;
                        dx1 = 0; dy1 = 0; dz1 = 0;
                        ddx = 0; ddy = 0; ddz = 0;
                        % ---
                end

                % --- continued...
                switch go_.type
                    case 'ago_xy'
                        center = center([1 2]);
                        p02d   = p03d([1 2]);
                        % ---
                        [dx, dy] = obj.calform_ago2d(angle,30,p02d,center); % 30 may be enough
                        dx0 = dx(1);   dy0 = dy(1);
                        dx1 = dx(end); dy1 = dy(end);
                        % ---
                        [ddx, ddy] = obj.calform_ago2d(angle,1,p02d,center);
                    case 'ago_xz'
                        center = center([1 3]);
                        p02d   = p03d([1 3]);
                        % ---
                        [dx, dz] = obj.calform_ago2d(angle,30,p02d,center);
                        dx0 = dx(1);   dz0 = dz(1);
                        dx1 = dx(end); dz1 = dz(end);
                        % ---
                        [ddx, ddz] = obj.calform_ago2d(angle,1,p02d,center);
                    case 'ago_yz'
                        center = center([2 3]);
                        p02d   = p03d([2 3]);
                        % ---
                        [dy, dz] = obj.calform_ago2d(angle,30,p02d,center);
                        dy0 = dy(1);   dz0 = dz(1);
                        dy1 = dy(end); dz1 = dz(end);
                        % ---
                        [ddy, ddz] = obj.calform_ago2d(angle,1,p02d,center);
                end

                % --- continued...
                switch go_.type
                    case {'ago_xy','ago_xz','ago_yz'}
                        dmove0 = [dx0, dy0, dz0];
                        dmove1 = [dx1, dy1, dz1];
                        go_.vi = dmove0; go_.vi = go_.vi ./ norm(go_.vi);
                        go_.vf = dmove1; go_.vf = go_.vf ./ norm(go_.vf);
                        % ---
                        ddmove = [ddx, ddy, ddz];
                        flagnode = p03d + ddmove./2;
                end

                % --- initial/final nodes
                go_.ni = node{end};
                switch go_.type
                    case {'xgo','ygo','zgo','xygo','xzgo','yzgo','xyzgo'}
                        node{end + 1} = node{end} + go_.vlen;
                    case {'ago_xy','ago_xz','ago_yz'}
                        node{end + 1} = node{end} + ddmove;
                end
                go_.nf = node{end};
                
                % --- flag
                idflag = length(flag_);
                switch go_.type
                    case {'xgo','ygo','zgo','xygo','xzgo','yzgo','xyzgo'}
                        fnode = node{end-1};
                        fvec = node{end} - node{end-1};
                        fvec = fvec ./ norm(fvec);
                    case 'ago_xy'
                        fnode = flagnode;
                        fvec = [0 0 1];
                    case 'ago_xz'
                        fnode = flagnode;
                        fvec = [0 1 0];
                    case 'ago_yz'
                        fnode = flagnode;
                        fvec = [1 0 0];
                end
                flag_{idflag+1}.node = fnode;
                flag_{idflag+1}.vector = fvec;
                flag_{idflag+1}.id = go_.id;
                % ---
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
            node = [x_; y_; z_];
            % ---
            if ~isempty(obj.fit)
                idflag = obj.fit.id_flag;
                for i = 1:length(flag_)
                    if strcmpi(flag_{i}.id,idflag)
                        node = node + f_tocolv(obj.fit.destination) - f_tocolv(flag_{i}.node);
                        % ---
                        fv  = flag_{i}.vector;
                        ori = obj.fit.orientation;
                        % ---
                        rot_angle = acosd(dot(fv,ori) / (norm(fv) * norm(ori)));
                        rot_axis = cross(ori,fv);
                        if norm(rot_axis) < 1e-12
                            rot_axis = [0 0 -sign(dot([1 0 0],[lOx 0]))];
                        end
                        % ---
                        node = f_rotaroundaxis(node,'rot_angle',rot_angle, ...
                            'rot_axis',rot_axis,'axis_origin',obj.fit.destination);
                        % ---
                    end
                end
            end
            % ---
            obj.x = node(1,:);
            obj.y = node(2,:);
            obj.z = node(3,:);
            obj.flag = flag_;
            % ---
        end
        %------------------------------------------------------------------
        function [dx, dy] = calform_ago2d(da,dnum,p0,center)
            % ---
            if dnum == 0 || norm(p0 - center) < 1e-9
                dx = zeros(1,dnum);
                dy = zeros(1,dnum);
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
            % ---
            dx = diff(obj.x); dy = diff(obj.y); dz = diff(obj.z);
            dmax = max(norm([dx;dy;dz]));
            for i = 1:length(obj.flag)
                id_flag = obj.flag{i}.id;
                if ~isempty(id_flag)
                    node = obj.flag{i}.node.';
                    vect = obj.flag{i}.vector.';
                    % ---
                    text(node(1),node(2),node(3),id_flag);
                    f_quiver(node,vect,'sfactor',dmax/20); colorbar off;
                end
            end
        end
    end
end
