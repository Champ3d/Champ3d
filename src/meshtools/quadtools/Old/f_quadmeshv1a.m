%function qdom = f_quadmesh(qdom,varargin)

% %--------------------------------------------------------------------------
% % CHAMP3D PROJECT
% % Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% % Huu-Kien.Bui@univ-nantes.fr
% % Copyright (c) 2022 H-K. Bui, All Rights Reserved.
% %--------------------------------------------------------------------------
% cr = copyright();
% if ~strcmpi(cr(1:49), 'Champ3d Project - Copyright (c) 2022 Huu-Kien Bui')
%     error(' must add copyright file :( ');
% end
% %--------------------------------------------------------------------------
% 
% % --- valid argument list (to be updated each time modifying function)
% arglist = {'timeout'};
% 
% % --- default input value
timeout = 15;
% % --- check and update input
% for i = 1:(nargin-1)/2
%     if any(strcmpi(arglist,varargin{2*i-1}))
%         eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
%     else
%         error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
%     end
% end
%--------------------------------------------------------------------------
if isfield(qdom,'zone2d') & isfield(qdom,'line2d') & isfield(qdom,'p2d')
    zone2d = qdom.zone2d;
    line2d = qdom.line2d;
    p2d = qdom.p2d;
end
%--------------------------------------------------------------------------
node = [p2d(:).x ; p2d(:).y];
elem = [];
%--------------------------------------------------------------------------
nbzone = length(zone2d);
alllines = [];
for i = 1:nbzone
    alllines = [alllines zone2d(i).ibline zone2d(i).itline ...
                         zone2d(i).illine zone2d(i).irline];
end
alllines = sort(unique(alllines));
%--------------------------------------------------------------------------
% for i = 1:length(alllines)
%     line2d(i).divisible = 0;
% end
%--------------------------------------------------------------------------
tic
alldivisible = 0;
while ~alldivisible && (toc < timeout)
    for i = 1:nbzone
        if ~zone2d(i).divisible
            if strcmpi(zone2d(i).zonetype,'regular') || strcmpi(zone2d(i).zonetype,'reg')
                %----------------------------------------------------------
                zone2d(i).divisible = 1;
                %----------------------------------------------------------
                nbibot = sum([line2d(zone2d(i).ibline).nbi]);
                nbitop = sum([line2d(zone2d(i).itline).nbi]);
                nbilef = sum([line2d(zone2d(i).illine).nbi]);
                nbirig = sum([line2d(zone2d(i).irline).nbi]);
                %----------------------------------------------------------
                for ix = {'bottom-top','left-right'}
                    if strcmpi(ix,'bottom-top')
                        compatible = 1;
                        if nbibot > nbitop
                            tobemodified = 'itline';
                            ifnotapplicable = 'ibline';
                            nbilower = nbitop;
                            nbihigher = nbibot;
                            nbicompatible = nbihigher;
                            compatible = 0;
                        end
                        if nbibot < nbitop
                            tobemodified = 'ibline';
                            ifnotapplicable = 'itline';
                            nbilower = nbibot;
                            nbihigher = nbitop;
                            nbicompatible = nbihigher;
                            compatible = 0;
                        end
                    end
                    if strcmpi(ix,'left-right')
                        compatible = 1;
                        if nbilef > nbirig
                            tobemodified = 'irline';
                            ifnotapplicable = 'illine';
                            nbilower = nbirig;
                            nbihigher = nbilef;
                            nbicompatible = nbihigher;
                            compatible = 0;
                        end
                        if nbilef < nbirig
                            tobemodified = 'illine';
                            ifnotapplicable = 'irline';
                            nbilower = nbilef;
                            nbihigher = nbirig;
                            nbicompatible = nbihigher;
                            compatible = 0;
                        end
                    end
                    %------------------------------------------------------
                    if ~compatible
                        iltobemodified = zone2d(i).(tobemodified);
                        nl = length(iltobemodified);
                        ilfix = iltobemodified([line2d(iltobemodified).fixed] == 1);
                        ilfree = setdiff(iltobemodified,ilfix);
                        %--------------------------------------------------
                        if isempty(ilfree) % 1st attempt
                            vartemp  = tobemodified;
                            tobemodified = ifnotapplicable;
                            ifnotapplicable = vartemp;
                            nbicompatible = nbilower;
                            iltobemodified = zone2d(i).(tobemodified);
                            nl = length(iltobemodified);
                            ilfix = iltobemodified([line2d(iltobemodified).fixed] == 1);
                            ilfree = setdiff(iltobemodified,ilfix);
                        end
                        %--------------------------------------------------
                        if isempty(ilfree) % 2nd attempt, free all fixed lines
                            vartemp  = tobemodified; % return to higher config
                            tobemodified = ifnotapplicable;
                            ifnotapplicable = vartemp;
                            nbicompatible = nbihigher;
                            iltobemodified = zone2d(i).(tobemodified);
                            nl = length(iltobemodified);
                            ilfix = iltobemodified([line2d(iltobemodified).fixed] == 1);
                            line2d(ilfix).fixed = 0;
                            ilfix = [];
                            ilfree = setdiff(iltobemodified,ilfix);
                        end
                        %--------------------------------------------------
                        nbifix = sum([line2d(ilfix).nbi]);
                        nbirem = nbicompatible - nbifix; % = nbihigher for now
                        nlfree = length(ilfree);
                        nbidis = (nbirem - mod(nbirem,nlfree))/nlfree; % try to distribute equally
                        distributed = 0;
                        for il = 1:nlfree-1
                            if line2d(ilfree(il)).nbi < nbidis % if lower raise to nbidis
                                line2d(ilfree(il)).nbi = nbidis;
                                lz = [line2d(ilfree(il)).linezone];
                                for iz = 1:length(lz)
                                    zone2d(lz(iz)).divisible = 0; % change zone status
                                end
                            end
                            distributed = distributed + line2d(ilfree(il)).nbi;
                        end
                        if line2d(ilfree(end)).nbi ~= nbirem - distributed  % if ~= attribute the rest
                            line2d(ilfree(end)).nbi = nbirem - distributed; % could be negative ?
                            lz = [line2d(ilfree(end)).linezone];
                            for iz = 1:length(lz)
                                zone2d(lz(iz)).divisible = 0; % change zone status
                            end
                        end
                    end
                end
            end
        end
    end
    %[zone2d(:).divisible]
    alldivisible = all([zone2d(:).divisible]);
end
%--------------------------------------------------------------------------
% nbline = length(line2d);
% for i = 1:nbline
%     if isempty(line2d(i).linezone)
%         line2d(i).divisible = 1;
%     else
%         line2d(i).divisible = 0;
%     end
% end
%--------------------------------------------------------------------------
nbline = length(line2d);
for i = 1:nbline
    if ~isempty(line2d(i).linezone)
        line2d(i).divline = f_divideline('ps',[p2d(line2d(i).ips).x p2d(line2d(i).ips).y],...
                                         'pe',[p2d(line2d(i).ipe).x p2d(line2d(i).ipe).y],...
                                         'nbi',line2d(i).nbi,'dtype',line2d(i).dtype);
        %--- global id of node
        nbn = size(node,2);
        idnew = (nbn+1):1:(nbn+length(line2d(i).divline)-2); % - 2 end points
        line2d(i).idnglobal = [line2d(i).ips idnew line2d(i).ipe];
        %--- update node
        node = [node line2d(i).divline(:,2:end-1)]; % - 2 end points
    else
        % lines not in mesh
        line2d(i).divline = f_divideline('ps',[p2d(line2d(i).ips).x p2d(line2d(i).ips).y],...
                                         'pe',[p2d(line2d(i).ipe).x p2d(line2d(i).ipe).y],...
                                         'nbi',line2d(i).nbi,'dtype',line2d(i).dtype);
    end
end
%--------------------------------------------------------------------------

elem  = [];
idbline = {};
idtline = {};
idlline = {};
idrline = {};

iElem = 0;

for izone = 1:nbzone
    if strcmpi(zone2d(izone).zonetype,'regular') || strcmpi(zone2d(izone).zonetype,'reg')
        linenames = {'ibline','itline','illine','irline'};
        for iln = 1:length(linenames)
            theline = linenames{iln};
            if strcmpi(theline,'ibline') || strcmpi(theline,'itline')
                coor = 1;
            else
                coor = 2;
            end
            %-bline
            iline = zone2d(izone).(theline);
            nline = length(iline);
            %--sorted by x or y
            ddiv = [];
            idnglobal = [];
            idlines = {};
            itolineid = [];
            for il = 1:nline
                ddiv = [ddiv line2d(iline(il)).divline(coor,:)];
                idnglobal = [idnglobal line2d(iline(il)).idnglobal];
                idlines   = [idlines line2d(iline(il)).id];
                itolineid = [itolineid repmat(il,1,length(line2d(iline(il)).idnglobal))];
            end
            [ddiv,ing] = f_realunique(ddiv);
            idnglobal  = idnglobal(ing);
            itolineid  = itolineid(ing);
            [ddiv,ing] = sort(ddiv);
            idnglobal  = idnglobal(ing);
            itolineid  = itolineid(ing);
            zone.(theline).ddiv = ddiv;
            zone.(theline).idnglobal = idnglobal;
            zone.(theline).itolineid = itolineid;
            zone.(theline).idlines   = idlines;
        end
        %-------------- meshing -------------------------------------------
        nx = length(zone.ibline.ddiv);
        ny = length(zone.illine.ddiv);
        xmat = zeros(ny,nx);
        ymat = zeros(ny,nx);
        for inx = 1:nx
            xmat(:,inx) = linspace(zone.ibline.ddiv(inx),zone.itline.ddiv(inx),ny);
        end
        for iny = 1:ny
            ymat(iny,:) = linspace(zone.illine.ddiv(iny),zone.irline.ddiv(iny),nx);
        end
        %[xmat,ymat] = meshgrid(zone.ibline.ddiv,zone.illine.ddiv);
        %--- global id of node
        nbn = size(node,2);
        idnew = zeros(ny,nx);
        idnew(1,:)   = zone.ibline.idnglobal;
        idnew(end,:) = zone.itline.idnglobal;
        idnew(:,1)   = zone.illine.idnglobal;
        idnew(:,end) = zone.irline.idnglobal;
        %--- node coordinates
        xnew = [];
        ynew = [];
        lenn = nx - 2; % 2 known nodes
        for i = 2:ny-1 % number of layer y
            xnew = [xnew xmat(i,2:end-1)];
            ynew = [ynew ymat(i,2:end-1)];
            idnew(i,2:end-1) = nbn + ((lenn*(i-2)+1) : lenn*(i-1));
        end
        %--- update node
        node = [node [xnew;ynew]];
        %--- make elem
        el = zeros(5,(ny-1)*(nx-1));
        for iy = 1:ny-1      % number of layer y
            for ix = 1:nx-1  % number of layer x
                iElem = iElem+1;
                el(1,iElem) = idnew(iy,ix);
                el(2,iElem) = idnew(iy,ix+1);
                el(3,iElem) = idnew(iy+1,ix+1);
                el(4,iElem) = idnew(iy+1,ix);
                el(5,iElem) = izone;
                %idbl{iElem} = ;
            end
        end
        elem = [elem el];
        %idbline = [idbline idbl];
        %idtline = [idtline idtl];
        %idlline = [idlline idll];
        %idrline = [idrline idrl];
    end
end


%--------------------------------------------------------------------------
qdom.zone2d = zone2d;
qdom.line2d = line2d;
qdom.p2d = p2d;
qdom.mesh.node = node;
qdom.mesh.elem = elem;



%--------------------------------------------------------------------------
figure
f_view_meshquad(node,elem(1:4,:),elem(5,:)==1,'w'); hold on;
f_view_meshquad(node,elem(1:4,:),elem(5,:)==2,'r'); 
f_view_meshquad(node,elem(1:4,:),elem(5,:)==3,'b'); 
f_view_meshquad(node,elem(1:4,:),elem(5,:)==4,'gr'); 
f_view_meshquad(node,elem(1:4,:),elem(5,:)==5,'m'); 

f_plot_point2d(qdom.p2d); hold on
f_plot_line2d(qdom.line2d,qdom.p2d)

%--------------------------------------------------------------------------








