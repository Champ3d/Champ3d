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
        fit = []
        rmin = 0
        cutfactor = 2
    end
    % --- Constructors
    methods
        function obj = BCurve(args)
            arguments
                args.start_node = []
                args.type {mustBeMember(args.type,{'open','closed'})}
                args.rmin
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
    methods (Access = private)
        function setup(obj)
            obj.set_parameter;
        end
    end
    methods (Access = public)
        function reset(obj)
            obj.setup;
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
                obj.go{end + 1} = CurveGo('id',args.id,'type','xgo','len',args.len,'dnum',args.dnum);
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
                obj.go{end + 1} = CurveGo('id',args.id,'type','ygo','len',args.len,'dnum',args.dnum);
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
                obj.go{end + 1} = CurveGo('id',args.id,'type','zgo','len',args.len,'dnum',args.dnum);
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
                obj.go{end + 1} = CurveGo('id',args.id,'type','xygo','lenx',args.lenx,'leny',args.leny,'dnum',args.dnum);
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
                obj.go{end + 1} = CurveGo('id',args.id,'type','xzgo','lenx',args.lenx,'lenz',args.lenz,'dnum',args.dnum);
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
                obj.go{end + 1} = CurveGo('id',args.id,'type','yzgo','leny',args.leny,'lenz',args.lenz,'dnum',args.dnum);
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
                obj.go{end + 1} = CurveGo('id',args.id,'type','xyzgo','lenx',args.lenx,'leny',args.leny,'lenz',args.lenz,'dnum',args.dnum);
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
            obj.go{end + 1} = CurveGo('id',args.id,'type','ago_xy','angle',args.angle, ...
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
            obj.go{end + 1} = CurveGo('id',args.id,'type','ago_xz','angle',args.angle, ...
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
            obj.go{end + 1} = CurveGo('id',args.id,'type','ago_yz','angle',args.angle, ...
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
            obj.geonode;
            % ---
            if strcmpi(obj.type,'open')
                type_ = 0;
            else
                type_ = 1;
            end
            geocode = GMSHWriter.bcurve(obj.x, obj.y, obj.z, type_);
            % --- XTODO
            % geocode = obj.transformgeocode(geocode);
            % ---
        end
        %------------------------------------------------------------------
    end
    
    % --- private
    methods (Access = private)
        %------------------------------------------------------------------
        function geonode(obj)
            % ---
            obj.gobase;
            % ---
            node = [];
            for i = 1:length(obj.go)
                g = obj.go{i};
                node = [node, g.node];
            end
            dnode = vecnorm(diff(node,1,2));
            irm = find(dnode < 1e-9); % XTODO : tol
            node(:,irm) = [];
            % ---
            if ~isempty(obj.fit)
                idflag = obj.fit.id_flag;
                for i = 1:length(obj.flag)
                    if strcmpi(obj.flag{i}.id,idflag)
                        node = node + f_tocolv(obj.fit.destination) - f_tocolv(obj.flag{i}.node);
                        % ---
                        fv  = obj.flag{i}.vector;
                        ori = obj.fit.orientation;
                        % ---
                        rot_angle = acosd(dot(fv,ori) / (norm(fv) * norm(ori)));
                        rot_axis = cross(ori,fv);
                        if norm(rot_axis) < 1e-12
                            rot_axis = [0 0 -sign(dot([1 0 0],[fv(1) fv(2) 0]))];
                        end
                        % ---
                        node = f_rotaroundaxis(node,'rot_angle',rot_angle, ...
                            'rot_axis',rot_axis,'axis_origin',obj.fit.destination);
                        % ---
                        if obj.fit.rotation ~= 0
                            node = f_rotaroundaxis(node,'rot_angle',obj.fit.rotation, ...
                            'rot_axis',obj.fit.orientation,'axis_origin',obj.fit.destination);
                        end
                        % ---
                    end
                end
            end
            % ---
            obj.x = node(1,:);
            obj.y = node(2,:);
            obj.z = node(3,:);
            % ---
        end
        %------------------------------------------------------------------
        function gobase(obj)
            % ---
            obj.get_go;
            % ---
            rmin_ = obj.rmin.getvalue;
            cutfactor_ = obj.cutfactor.getvalue;
            % ---
            obj.where2cut;
            % ---
            nbp = 30; % XTODO : may be enough
            % ---
            lengo = length(obj.go);
            % ---
            for i = 1:lengo
                g = obj.go{i};
                % ---
                if rmin_ > norm(g.vlen)/(2*cutfactor_)
                    f_fprintf(1,'/!\\',0,'Too small angle corner too build volume curve !\n');
                    f_fprintf(0,'check go #',1,num2str(i),0,'\n');
                    return
                end
                % ---
                switch g.type
                    case {'xgo','ygo','zgo','xygo','xzgo','yzgo','xyzgo'}
                        ulen = g.vlen ./ norm(g.vlen);
                        if g.icut
                            nstart = g.ni + cutfactor_ * rmin_ .* ulen;
                        else
                            nstart = g.ni;
                        end
                        if g.fcut
                            nstop = g.nf - cutfactor_ * rmin_ .* ulen;
                        else
                            nstop = g.nf;
                        end
                        % ---
                        g.node = ...
                        [linspace(nstart(1),nstop(1),nbp); ...
                         linspace(nstart(2),nstop(2),nbp); ...
                         linspace(nstart(3),nstop(3),nbp)];
                        % ---
                    case {'ago_xy','ago_xz','ago_yz'}
                        angle = g.angle.getvalue;
                        dir = g.dir;
                        % ---
                        switch dir
                            case 'ccw'
                                angle = +abs(angle);
                            case 'clock'
                                angle = -abs(angle);
                        end
                        % ---
                        center = g.center.getvalue;
                        p03d = g.ni;
                        % ---
                        dx = zeros(1,nbp); dy = dx; dz = dx;
                        % ---
                end
                % --- continued
                switch g.type
                    case 'ago_xy'
                        center = center([1 2]);
                        p02d   = p03d([1 2]);
                        [dx, dy] = obj.calform_ago2d(angle,nbp,p02d,center);
                    case 'ago_xz'
                        center = center([1 3]);
                        p02d   = p03d([1 3]);
                        [dx, dz] = obj.calform_ago2d(angle,nbp,p02d,center);
                    case 'ago_yz'
                        center = center([2 3]);
                        p02d   = p03d([2 3]);
                        [dy, dz] = obj.calform_ago2d(angle,nbp,p02d,center);
                end
                % --- continued
                switch g.type
                    case {'ago_xy','ago_xz','ago_yz'}
                        ddiv = [dx; dy; dz];
                        % ---
                        if g.icut && rmin_ > 0
                            for idiv = 1:length(dx)
                                if norm(ddiv(:,idiv)) >= cutfactor_ * rmin_
                                    idiv0 = idiv;
                                    break
                                end
                            end
                        else
                            idiv0 = 1;
                        end
                        % ---
                        if g.fcut && rmin_ > 0
                            for idiv = length(dx):-1:1
                                if norm(g.vlen - ddiv(:,idiv)) >= cutfactor_ * rmin_
                                    idiv1 = idiv;
                                    break
                                end
                            end
                        else
                            idiv1 = length(dx);
                        end
                        % ---
                        node_ = {};
                        if ~g.icut || rmin_ == 0
                            node_{end+1} = g.ni;
                        end
                        for idiv = idiv0:idiv1
                            node_{end+1} = g.ni + ddiv(:,idiv);
                        end
                        if ~g.fcut || rmin_ == 0
                            node_{end+1} = g.nf;
                        end
                        % ---
                        g.node = cell2mat(node_);
                end
            end
        end
        %------------------------------------------------------------------
        function where2cut(obj)
            % ---
            lengo = length(obj.go);
            for i = 1:lengo
                % ---
                go0 = obj.go{i};
                % ---
                if i == lengo
                    if strcmpi(obj.type,'closed')
                        go1 = obj.go{1};
                    end
                    break
                else
                    go1 = obj.go{i+1};
                end
                % ---
                vf0 = go0.vf;
                vi1 = go1.vi;
                if dot(vf0,vi1) <= 0
                    go0.fcut = 1;
                    go1.icut = 1;
                end
                % ---
            end
        end
        %------------------------------------------------------------------
        function get_go(obj)
            % ---
            obj.setup;
            % ---
            node = {[obj.start_node(1); obj.start_node(2); obj.start_node(3)]};
            flag_ = {};
            % ---
            for i = 1:length(obj.go)
                g = obj.go{i};
                switch g.type
                    case 'xgo'
                        len = g.len.getvalue;
                        g.vlen = len .* [1; 0; 0];
                        g.vi = g.vlen ./ norm(g.vlen);
                        g.vf = g.vi;
                    case 'ygo'
                        len = g.len.getvalue;
                        g.vlen = len .* [0; 1; 0];
                        g.vi = g.vlen ./ norm(g.vlen);
                        g.vf = g.vi;
                    case 'zgo'
                        len = g.len.getvalue;
                        g.vlen = len .* [0; 0; 1];
                        g.vi = g.vlen ./ norm(g.vlen);
                        g.vf = g.vi;
                    case 'xygo'
                        lenx = g.lenx.getvalue;
                        leny = g.leny.getvalue;
                        g.vlen = [lenx; leny; 0];
                        g.vi = g.vlen ./ norm(g.vlen);
                        g.vf = g.vi;
                    case 'xzgo'
                        lenx = g.lenx.getvalue;
                        lenz = g.lenz.getvalue;
                        g.vlen = [lenx; 0; lenz];
                        g.vi = g.vlen ./ norm(g.vlen);
                        g.vf = g.vi;
                    case 'yzgo'
                        leny = g.leny.getvalue;
                        lenz = g.lenz.getvalue;
                        g.vlen = [0; leny; lenz];
                        g.vi = g.vlen ./ norm(g.vlen);
                        g.vf = g.vi;
                    case 'xyzgo'
                        lenx = g.lenx.getvalue;
                        leny = g.leny.getvalue;
                        lenz = g.lenz.getvalue;
                        g.vlen = [lenx; leny; lenz];
                        g.vi = g.vlen ./ norm(g.vlen);
                        g.vf = g.vi;
                    case {'ago_xy','ago_xz','ago_yz'}
                        angle = g.angle.getvalue;
                        dir = g.dir;
                        % ---
                        switch dir
                            case 'ccw'
                                angle = +abs(angle);
                            case 'clock'
                                angle = -abs(angle);
                        end
                        % ---
                        cen3d = g.center.getvalue;
                        % ---
                        p03d = node{end};
                        % ---
                        dx0 = 0; dy0 = 0; dz0 = 0;
                        dx1 = 0; dy1 = 0; dz1 = 0;
                        ddx = 0; ddy = 0; ddz = 0;
                        % ---
                end

                % --- continued...
                switch g.type
                    case 'ago_xy'
                        % ---
                        rot_axis = [0 0 1];
                        % ---
                        cen2d = cen3d([1 2]);
                        p02d  = p03d([1 2]);
                        % ---
                        [ddx, ddy] = obj.calform_ago2d(angle,1,p02d,cen2d);
                    case 'ago_xz'
                        % ---
                        rot_axis = [0 1 0];
                        % ---
                        cen2d = cen3d([1 3]);
                        p02d  = p03d([1 3]);
                        % ---
                        [ddx, ddz] = obj.calform_ago2d(angle,1,p02d,cen2d);
                    case 'ago_yz'
                        % ---
                        rot_axis = [1 0 0];
                        % ---
                        cen2d = cen3d([2 3]);
                        p02d  = p03d([2 3]);
                        % ---
                        [ddy, ddz] = obj.calform_ago2d(angle,1,p02d,cen2d);
                end

                % --- continued...
                switch g.type
                    case {'ago_xy','ago_xz','ago_yz'}
                        % ---
                        vi = cross(p03d - cen3d,rot_axis);
                        if angle > 0
                            vi = - vi;
                        end
                        g.vi = vi ./ norm(vi);
                        vf = f_rotaroundaxis(f_tocolv(vi),'rot_angle',angle,'rot_axis',rot_axis);
                        g.vf = vf ./ norm(vf);
                        % ---
                        ddmove = [ddx; ddy; ddz];
                        flagnode = p03d + ddmove./2;
                        % ---
                        g.vlen = ddmove;
                        % ---
                end

                % --- initial/final nodes
                g.ni = node{end};
                switch g.type
                    case {'xgo','ygo','zgo','xygo','xzgo','yzgo','xyzgo'}
                        node{end + 1} = node{end} + g.vlen;
                    case {'ago_xy','ago_xz','ago_yz'}
                        node{end + 1} = node{end} + ddmove;
                end
                g.nf = node{end};
                
                % --- flag
                idflag = length(flag_);
                switch g.type
                    case {'xgo','ygo','zgo','xygo','xzgo','yzgo','xyzgo'}
                        fnode = node{end-1};
                        fvec = node{end} - node{end-1};
                        fvec = fvec ./ norm(fvec);
                    case 'ago_xy'
                        fnode = flagnode;
                        fvec = [0; 0; 1];
                    case 'ago_xz'
                        fnode = flagnode;
                        fvec = [0; 1; 0];
                    case 'ago_yz'
                        fnode = flagnode;
                        fvec = [1; 0; 0];
                end
                flag_{idflag+1}.node = fnode;
                flag_{idflag+1}.vector = fvec;
                flag_{idflag+1}.id = g.id;
                % ---
                g.flag = flag_{idflag+1};
                % ---
            end

            % ---
            dtermnode = norm(obj.go{1}.ni - obj.go{end}.nf);
            switch obj.type
                % --- XTODO : put tol in config
                case 'open'
                    if  dtermnode < 1e-9
                        f_fprintf(1,'/!\\',0,'bcurve terminals too close for open-bcurve, d < 1e-9 !\n');
                    end
                case 'closed'
                    if dtermnode > 1e-9
                        f_fprintf(1,'/!\\',0,'bcurve terminals not really close for closed-bcurve !',...
                            0,'d = ',1,num2str(dtermnode,12),0,'\n');
                    end
            end
            % ---
            obj.flag = flag_;
            % ---
        end
        %------------------------------------------------------------------
        function [dx, dy] = calform_ago2d(obj,angle,dnum,p0,center)
            % ---
            if dnum == 0 || norm(p0 - center) < 1e-9
                dx = zeros(1,dnum);
                dy = zeros(1,dnum);
                return
            end
            % ---
            da = angle/dnum;
            dx = zeros(1,dnum);
            dy = zeros(1,dnum);
            % ---
            for i = 1:dnum
                r = norm(p0 - center);
                lOx = (p0 - center);
                gOx = [1; 0];
                rot_angle = acosd(dot(lOx,gOx) / (norm(lOx) * norm(gOx)));
                rot_axis = cross([1; 0; 0],[lOx; 0]);
                if norm(rot_axis) < 1e-12
                    rot_axis = [0; 0; -sign(dot([1; 0; 0],[lOx; 0]))];
                end
                % ---
                lvmove = [r * cosd(i*da); r * sind(i*da)];
                % ---
                dv = lvmove - [r; 0];
                dv = f_rotaroundaxis(dv,'rot_angle',rot_angle, ...
                    'rot_axis',rot_axis,'axis_origin',[0; 0; 0]);
                % ---
                dx(i) = dv(1);
                dy(i) = dv(2);
            end
        end
        %------------------------------------------------------------------
        function lmax = lmax(obj)
            lmax = 0;
            for i = 1:length(obj.go)
                if ~isempty(obj.go{i}.vlen)
                    lmax = max(lmax,norm(obj.go{i}.vlen));
                end
            end
        end
        %------------------------------------------------------------------
    end
    % --- Plot
    methods
        function plot(obj)
            % ---
            obj.get_go;
            obj.geonode;
            % ---
            plot3(obj.x,obj.y,obj.z,'-b','LineWidth',3); hold on;
            % ---
            for i = 1:length(obj.go)
                g = obj.go{i};
                plot3(g.node(1,:),g.node(2,:),g.node(3,:),'-r','LineWidth',3); hold on;
            end
            % ---
            for i = 1:length(obj.flag)
                id_flag = obj.flag{i}.id;
                if ~isempty(id_flag)
                    node = obj.flag{i}.node;
                    vect = obj.flag{i}.vector;
                    % ---
                    text(node(1),node(2),node(3),['   <---' id_flag],'Color','r');
                    f_quiver(node,vect,'sfactor',obj.lmax/20,'face_color','r'); colorbar off;
                end
            end
            % ---
            % obj.get_go;
            % x = []; y = []; z = [];
            % for i = 1:length(obj.go)
            %     g = obj.go{i};
            %     x = [x g.ni(1)]; y = [y g.ni(2)]; z = [z g.ni(3)];
            %     if i == length(obj.go)
            %         x = [x g.nf(1)]; y = [y g.nf(2)]; z = [z g.nf(3)];
            %     end
            % end
            % figure
            % plot3(x,y,z,'-b','LineWidth',3); hold on;
            % ---
        end
    end
end
