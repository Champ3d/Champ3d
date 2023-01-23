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
timeout = 30;
% % --- check and update input
% for i = 1:(nargin-1)/2
%     if any(strcmpi(arglist,varargin{2*i-1}))
%         eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
%     else
%         error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
%     end
% end
%--------------------------------------------------------------------------
if isfield(qdom,'zone2d') && isfield(qdom,'line2d') && isfield(qdom,'p2d')
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
for i = 1:nbzone
    if strcmpi(zone2d(i).zonetype,'ctype')
        zone2d(i).divisible = 1;
        lineA = 'itscotchline';
        lineB = 'ibscotchline';
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
        if nbilineA < nbilineB
            line2d = f_redistributenbi(line2d,'ilfix',[],...
                                              'ilfree',ilineA,...
                                              'nbi',nbilineB);
            line2d = f_setproperty(line2d,'iline',ilineA,'property','fixed','value',1);
            line2d = f_setproperty(line2d,'iline',ilineB,'property','fixed','value',1);
        elseif nbilineB < nbilineA
            line2d = f_redistributenbi(line2d,'ilfix',[],...
                                              'ilfree',ilineB,...
                                              'nbi',nbilineA);
            line2d = f_setproperty(line2d,'iline',ilineA,'property','fixed','value',1);
            line2d = f_setproperty(line2d,'iline',ilineB,'property','fixed','value',1);
        else
            line2d = f_setproperty(line2d,'iline',ilineA,'property','fixed','value',1);
            line2d = f_setproperty(line2d,'iline',ilineB,'property','fixed','value',1);
        end
    end
end
%--------------------------------------------------------------------------
tic
alldivisible = 0;
while ~alldivisible
    if (toc < timeout)
        for i = 1:nbzone
            if zone2d(i).nomesh
                zone2d(i).divisible = 1;
            else
                if ~zone2d(i).divisible
                    if strcmpi(zone2d(i).zonetype,'regvo')
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
                        compatible = 1;
                        %------------------------------------------------------
                        for ix = 1: length(linesA)
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
                            if nbilineA < nbilineB
                                compatible = 0;
                                if isempty(ilfreeA) && isempty(ilfreeB) % all fixed - all fixed
                                    if nbifixA < nbifixB
                                        %fprintf(['May try to equalize the nbi of ' lineA ' and ' lineB '.\n']);
                                        %error([mfilename ': must solve compability zone ' num2str(i) ' !']);
                                        line2d = f_setproperty(line2d,'iline',ilfixA,'property','fixed','value',0);
                                        warning([mfilename ': free restriction on ' lineA ' zone ' num2str(i) ' !']);
                                        iltobemodifiedfix = [];
                                        iltobemodifiedfree = ilineA;
                                        nbitobemodified = nbilineB;
                                    end
                                elseif isempty(ilfreeA) && ~isempty(ilfreeB) % all fixed - fixed+free
                                    nbifixmin = nbifixB + length(ilfreeB);
                                    if nbifixA < nbifixmin
                                        %fprintf(['May try to increase the nbi of ' lineA ' to minimum ' num2str(nbifixmin) '.\n']);
                                        %error([mfilename ': must solve compability zone ' num2str(i) ' !']);
                                        line2d = f_setproperty(line2d,'iline',ilfixA,'property','fixed','value',0);
                                        warning([mfilename ': free restriction on ' lineA ' zone ' num2str(i) ' !']);
                                        iltobemodifiedfix = [];
                                        iltobemodifiedfree = ilineA;
                                        nbitobemodified = nbilineB;
                                    else
                                        iltobemodifiedfix = ilfixB;
                                        iltobemodifiedfree = ilfreeB;
                                        nbitobemodified = nbilineA;
                                    end
                                elseif ~isempty(ilfreeA) && isempty(ilfreeB) % fixed+free - all fixed
                                    nbifixmin = nbifixA + length(ilfreeA);
                                    if nbifixB < nbifixmin
                                        %fprintf(['May try to increase the nbi of ' lineA ' to minimum ' num2str(nbifixmin) '.\n']);
                                        %error([mfilename ': must solve compability zone ' num2str(i) ' !']);
                                        line2d = f_setproperty(line2d,'iline',ilfixB,'property','fixed','value',0);
                                        warning([mfilename ': free restriction on ' lineB ' zone ' num2str(i) ' !']);
                                        iltobemodifiedfix = [];
                                        iltobemodifiedfree = ilineB;
                                        nbitobemodified = nbilineA;
                                    else
                                        iltobemodifiedfix = ilfixA;
                                        iltobemodifiedfree = ilfreeA;
                                        nbitobemodified = nbilineB;
                                    end
                                else
                                    % fixed+free - fixed+free, free-fixed+free, free-free
                                    iltobemodifiedfix = ilfixA;
                                    iltobemodifiedfree = ilfreeA;
                                    nbitobemodified = nbilineB;
                                end
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
        alldivisible = all([zone2d(:).divisible]);
    else
        warning([mfilename ': Time out ! Sorry but impossible to resolve compability for meshing ! Free all lines !']);
        line2d = f_setproperty(line2d,'iline',1:length(line2d),'property','fixed','value',0);
        alldivisible = 0;
        tic;
    end
    %---
end


%--------------------------------------------------------------------------
% if ~alldivisible
%     warning([mfilename ': sorry but impossible to resolve compability for meshing !']);
%     warning([mfilename ': free all lines !']);
%     line2d = f_setproperty(line2d,'iline','','property','fixed','value',0);
% end
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
for izone = 1:nbzone
    if strcmpi(zone2d(izone).zonetype,'ctype')
        [node,elem] = f_qmesh_c(node,elem,line2d,zone2d(izone),...
                                     'idzone',izone);
    end
end
%--------------------------------------------------------------------------
nbline = length(line2d);
for i = 1:nbline
    if ~isempty(line2d(i).linezone) % for lines in mesh
        line2d(i).divline = f_divideline('ps',[p2d(line2d(i).ips).x p2d(line2d(i).ips).y],...
                                         'pe',[p2d(line2d(i).ipe).x p2d(line2d(i).ipe).y],...
                                         'nbi',line2d(i).nbi,'dtype',line2d(i).dtype,...
                                         'flog',line2d(i).flog);
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
                                         'nbi',line2d(i).nbi,'dtype',line2d(i).dtype,...
                                         'flog',line2d(i).flog);
    end
end
%--------------------------------------------------------------------------

elem  = [];
idbline = {};
idtline = {};
idlline = {};
idrline = {};

for izone = 1:nbzone
    if strcmpi(zone2d(izone).zonetype,'regvo')
        [node,elem] = f_qmesh_regvo(node,elem,line2d,zone2d(izone),...
                                            'idzone',izone);
    end
    if strcmpi(zone2d(izone).zonetype,'ctype')
        [node,elem] = f_qmesh_c(node,elem,line2d,zone2d(izone),...
                                     'idzone',izone);
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

for i = 1:nbzone
    f_view_meshquad(node,elem(1:4,:),elem(5,:)==i,[randi(255) randi(255) randi(255)]./255); hold on;
end
axis normal
%--------------------------------------------------------------------------








