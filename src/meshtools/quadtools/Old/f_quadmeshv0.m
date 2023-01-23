function qmesh = f_quadmeshv0(qmesh,varargin)

%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------
cr = copyright();
if ~strcmpi(cr(1:49), 'Champ3d Project - Copyright (c) 2022 Huu-Kien Bui')
    error(' must add copyright file :( ');
end
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'timeout'};

% --- default input value
timeout = 15;
% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if isfield(qmesh,'zone2d') & isfield(qmesh,'line2d') & isfield(qmesh,'p2d')
    zone2d = qmesh.zone2d;
    line2d = qmesh.line2d;
    p2d = qmesh.p2d;
end
%--------------------------------------------------------------------------
node = [p2d(:).x ; p2d(:).y];
elem = [];
%--------------------------------------------------------------------------
nbline = length(line2d);
for i = 1:nbline
    line2d(i).divline   = f_divideline('ps',[p2d(line2d(i).ips).x p2d(line2d(i).ips).y],...
                                       'pe',[p2d(line2d(i).ips).x p2d(line2d(i).ips).y],...
                                       'nbi',line2d(i).nbi,'dtype',line2d(i).dtype);
    %--- global id of node
    nbn = size(node,2);
    idnew = (nbn+1):1:(nbn+length(line2d(i).divline)-2);
    line2d(i).idpglobal = [line2d(i).ips idnew line2d(i).ipe];
    %--- update node
    node = [node line2d(i).divline(:,2:end-1)];
end
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
nbline = length(line2d);
for i = 1:nbline
    if isempty(line2d(i).linezone)
        line2d(i).divisible = 1;
    else
        line2d(i).divisible = 0;
    end
end
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
                compatible = 1;
                if nbibot > nbitop
                    tobemodified = 'itline';
                    ifnotapplicable = 'ibline';
                    nbihigher = nbibot;
                    compatible = 0;
                end
                if nbibot < nbitop
                    tobemodified = 'ibline';
                    ifnotapplicable = 'itline';
                    nbihigher = nbitop;
                    compatible = 0;
                end
                %---
                if ~compatible
                    nbtry = 0;
                    while nbtry < 2
                        nbtry = nbtry + 1;
                        nl = length(zone2d(i).(tobemodified));
                        ilfix = [];
                        for il = 1:nl
                            if line2d(zone2d(i).(tobemodified)(il)).fixed
                                ilfix = [ilfix zone2d(i).(tobemodified)(il)];
                            end
                        end
                        ilfree = setdiff([zone2d(i).(tobemodified)],ilfix);
                        if isempty(ilfree)
                            nbihigher = sum([line2d(zone2d(i).(tobemodified)).nbi]);
                            tobemodified = ifnotapplicable;
                        end
                    end
                end
                %---
                if ~compatible
                    nl = length(zone2d(i).(tobemodified));
                    ilfix = [];
                    for il = 1:nl
                        if line2d(zone2d(i).(tobemodified)(il)).fixed
                            ilfix = [ilfix zone2d(i).(tobemodified)(il)];
                        end
                    end
                    ilfree = setdiff([zone2d(i).(tobemodified)],ilfix);
                    nbifix = sum([line2d(ilfix).nbi]);
                    nbirem = nbihigher - nbifix;
                    nlfree = length(ilfree);
                    nbidis = (nbirem - mod(nbirem,nlfree))/nlfree;
                    distributed = 0;
                    for il = 1:nlfree-1
                        if line2d(ilfree(il)).nbi < nbidis
                            line2d(ilfree(il)).nbi = nbidis;
                            lz = [line2d(ilfree(il)).linezone];
                            for iz = 1:length(lz)
                                zone2d(lz(iz)).divisible = 0;
                            end
                        end
                        distributed = distributed + line2d(ilfree(il)).nbi;
                    end
                    if line2d(ilfree(end)).nbi ~= nbirem - distributed
                        line2d(ilfree(end)).nbi = nbirem - distributed;
                        lz = [line2d(ilfree(end)).linezone];
                            for iz = 1:length(lz)
                                zone2d(lz(iz)).divisible = 0;
                            end
                    end
                end
                %----------------------------------------------------------
                compatible = 1;
                if nbilef > nbirig
                    tobemodified = 'irline';
                    nbihigher = nbilef;
                    compatible = 0;
                end
                if nbilef < nbirig
                    tobemodified = 'illine';
                    nbihigher = nbirig;
                    compatible = 0;
                end
                %---
                if ~compatible
                    nbtry = 0;
                    while nbtry < 2
                        nbtry = nbtry + 1;
                        nl = length(zone2d(i).(tobemodified));
                        ilfix = [];
                        for il = 1:nl
                            if line2d(zone2d(i).(tobemodified)(il)).fixed
                                ilfix = [ilfix zone2d(i).(tobemodified)(il)];
                            end
                        end
                        ilfree = setdiff([zone2d(i).(tobemodified)],ilfix);
                        if isempty(ilfree)
                            nbihigher = sum([line2d(zone2d(i).(tobemodified)).nbi]);
                            tobemodified = ifnotapplicable;
                        end
                    end
                end
                %---
                if ~compatible
                    nl = length(zone2d(i).(tobemodified));
                    ilfix = [];
                    for il = 1:nl
                        if line2d(zone2d(i).(tobemodified)(il)).fixed
                            ilfix = [ilfix zone2d(i).(tobemodified)(il)];
                        end
                    end
                    ilfree = setdiff([zone2d(i).(tobemodified)],ilfix);
                    nbifix = sum([line2d(ilfix).nbi]);
                    nbirem = nbihigher - nbifix;
                    nlfree = length(ilfree);
                    nbidis = (nbirem - mod(nbirem,nlfree))/nlfree;
                    distributed = 0;
                    for il = 1:nlfree-1
                        if line2d(ilfree(il)).nbi < nbidis
                            line2d(ilfree(il)).nbi = nbidis;
                            lz = [line2d(ilfree(il)).linezone];
                            for iz = 1:length(lz)
                                zone2d(lz(iz)).divisible = 0;
                            end
                        end
                        distributed = distributed + line2d(ilfree(il)).nbi;
                    end
                    if line2d(ilfree(end)).nbi ~= nbirem - distributed
                        line2d(ilfree(end)).nbi = nbirem - distributed;
                        lz = [line2d(ilfree(end)).linezone];
                        for iz = 1:length(lz)
                            zone2d(lz(iz)).divisible = 0;
                        end
                    end
                end
                %----------------------------------------------------------
            end
        end
    end
    %[zone2d(:).divisible]
    alldivisible = all([zone2d(:).divisible]);
end
%--------------------------------------------------------------------------











%--------------------------------------------------------------------------
qmesh.zone2d = zone2d;
qmesh.line2d = line2d;
qmesh.p2d = p2d;
%--------------------------------------------------------------------------
