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
% % may add free option that quadmesh can decide alone
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
            if strcmpi(zone2d(i).zonetype,'x') || strcmpi(zone2d(i).zonetype,'x')
                zone2d(i).divisible = 1;
            end
            if strcmpi(zone2d(i).zonetype,'regular') || strcmpi(zone2d(i).zonetype,'reg')
                %----------------------------------------------------------
                zone2d(i).divisible = 1;
                linesA = {'itline','ibline','irline','illine'};
                linesB = {'ibline','itline','illine','irline'};
                %----------------------------------------------------------
                % A|===|      B|====|
                % A|===|      B|====|--|
                % A|===|---|  B|====|--|
                % A|===|---|  B|====|
                %----------------------------------------------------------
                for ix = 1: length(linesA)
                    %------------------------------------------------------
                    compatible = 1;
                    %------------------------------------------------------
                    lineA = linesA{ix};
                    lineB = linesB{ix};
                    %------------------------------------------------------
                    ilineA = zone2d(i).(lineA);
                    ilineB = zone2d(i).(lineB);
                    ilfixA = ilineA([line2d(ilineA).fixed] == 1);
                    ilfixB = ilineB([line2d(ilineB).fixed] == 1);
                    nbifixA = sum([line2d(ilfixA).nbi]);
                    nbifixB = sum([line2d(ilfixB).nbi]);
                    ilfreeA = setdiff(ilineA,ilfixA);
                    ilfreeB = setdiff(ilineB,ilfixB);
                    % total nbi
                    nbilineA = sum([line2d(ilineA).nbi]);
                    nbilineB = sum([line2d(ilineB).nbi]);
                    %------------------------------------------------------
                    if isempty(ilfreeA) && isempty(ilfreeB) % all fixed - all fixed
                        if nbifixA < nbifixB
                            %fprintf(['May try to equalize the nbi of ' lineA ' and ' lineB '.\n']);
                            %error([mfilename ': must solve compability zone ' num2str(i) ' !']);
                            line2d = f_setproperty(line2d,'iline',ilfixA,'property','fixed','value',0);
                            warning([mfilename ': free restriction on ' lineA ' zone ' num2str(i) ' !']);
                        end
                    elseif isempty(ilfreeA) && ~isempty(ilfreeB) % all fixed - fixed+free
                        nbifixmin = nbifixB + length(ilfreeB);
                        if nbifixA < nbifixmin
                            %fprintf(['May try to increase the nbi of ' lineA ' to minimum ' num2str(nbifixmin) '.\n']);
                            %error([mfilename ': must solve compability zone ' num2str(i) ' !']);
                            line2d = f_setproperty(line2d,'iline',ilfixA,'property','fixed','value',0);
                            warning([mfilename ': free restriction on ' lineA ' zone ' num2str(i) ' !']);
                        else
                            compatible = 0;
                            iltobemodifiedfix = ilfixB;
                            iltobemodifiedfree = ilfreeB;
                            nbitobemodified = nbilineA;
                        end
                    else
                        % fixed+free - fixed+free, free-fixed+free, free-fixed, free-free
                        if nbilineA < nbilineB
                            compatible = 0;
                            iltobemodifiedfix = ilfixA;
                            iltobemodifiedfree = ilfreeA;
                            nbitobemodified = nbilineB;
                        end
                    end
                    %------------------------------------------------------
                    if ~compatible
                        line2d = f_redistributenbi(line2d,'ilfix',iltobemodifiedfix,...
                                                          'ilfree',iltobemodifiedfree,...
                                                          'nbi',nbitobemodified);
                        lz = [line2d(iltobemodifiedfree).linezone];
                        for iz = 1:length(lz)
                            zone2d(lz(iz)).divisible = 0; % change zone status
                        end
                    end
                end
            end
        end
    end
    %---
    alldivisible = all([zone2d(:).divisible]);
end

%--------------------------------------------------------------------------
if ~alldivisible
    error([mfilename ': sorry but impossible to resolve compability for meshing !']);
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
    if ~isempty(line2d(i).linezone) % for lines in mesh
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
f_plot_point2d(qdom.p2d); hold on
f_plot_line2d(qdom.line2d,qdom.p2d)


f_view_meshquad(node,elem(1:4,:),elem(5,:)==1,'w'); hold on;
f_view_meshquad(node,elem(1:4,:),elem(5,:)==2,'r'); 
f_view_meshquad(node,elem(1:4,:),elem(5,:)==3,'b'); 
f_view_meshquad(node,elem(1:4,:),elem(5,:)==4,'gr'); 
f_view_meshquad(node,elem(1:4,:),elem(5,:)==5,'m'); 


%--------------------------------------------------------------------------








