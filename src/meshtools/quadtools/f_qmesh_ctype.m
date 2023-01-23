%function [node,elem,varargout] = f_qmesh_c(node,elem,varargin)

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
arglist = {'line2d','zone2d','idzone'};

% --- default input value
line2d = [];
zone2d = [];
idzone = 0;


% --- check and update input
for i = 1:(nargin-2)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
iElem = size(elem,2);
%--------------------------------------------------------------------------
node = [];
elem = [];

%TODO
%Use bline, tline... style

x0 = 0;
ri = 1;
e  = 1;
ro = ri+e;
w  = 0; d = 0.5; a = 0.2;
nx1 = 20;
nx2 = 20;
ny1 = 24; % should be even
ne  = 10;
na  = 10;

ly = ro; % total length
lx = ro + w + d; % total length
id0 = 0;
ie  = 0;
dy  = ro - (ro .* cos(linspace(0,pi/2,ny1+1))); % nb points should be odd
%dy  = linspace(0,ly,ny1+1);

ipend1 = [];
for i = 1:ny1
    for j = 1:nx1
        %------------------------------------------------------------------
        % move to add zone 2d
        % treatment of lines' div
        Rd = ro + w + d - j*d/nx1;
        R1 = ro - dy(i); %ro - (i - 1) * ro/ny1;
        R2 = ro - dy(i+1); %ro - i * ro/ny1;
        m1 = ro + w + d - (ro+w)*sin(acos(R1/(ro+w)));
        m2 = ro + w + d - (ro+w)*sin(acos(R2/(ro+w)));
        x1 = (j-1) * m1/nx1; y1 = dy(i);   id1 = id0 + (i-1)*(nx1+1) + j;
        x2 = j * m1/nx1;     y2 = dy(i);   id2 = id0 + (i-1)*(nx1+1) + j + 1;
        x3 = (j-1) * m2/nx1; y3 = dy(i+1); id3 = id0 + i*(nx1+1) + j;
        x4 = j * m2/nx1;     y4 = dy(i+1); id4 = id0 + i*(nx1+1) + j + 1;
        %------------------------------------------------------------------
        if j == nx1; ipend1 = [ipend1 id2 id4]; end
        %------------------------------------------------------------------
        node(1,id1) = x1; node(2,id1) = y1;
        node(1,id2) = x2; node(2,id2) = y2;
        node(1,id3) = x3; node(2,id3) = y3;
        node(1,id4) = x4; node(2,id4) = y4;
        %------------------------------------------------------------------
        ie = ie + 1;
        elem(1,ie) = id1; elem(2,ie) = id2; elem(3,ie) = id4; elem(4,ie) = id3;
        %------------------------------------------------------------------
        elem(5,ie) = 1;
        %------------------------------------------------------------------
    end
end
ipend1 = sort(unique(ipend1));
nbp = size(node,2);


%--------------------------------------------------------------------------
ang  = acos((ro-node(2,ipend1))/ro); %*180/pi;
nang = length(ipend1) - 1; % = ny1

dea = linspace(0,e,ne+1);
dea(end) = [];
dea = [dea linspace(e,e+a,na+1)];
id0 = nbp;
ipend2 = [];
for i = 1:ne+na
    for j = 1:nang
        RR  = ro + w + d;
        Rx1 = ro - dea(i);
        Rx2 = ro - dea(i+1);
        x1 = RR - Rx1*sin(ang(j));
        y1 = ro - Rx1*cos(ang(j));
        x2 = RR - Rx1*sin(ang(j+1));
        y2 = ro - Rx1*cos(ang(j+1));
        x3 = RR - Rx2*sin(ang(j));
        y3 = ro - Rx2*cos(ang(j));
        x4 = RR - Rx2*sin(ang(j+1));
        y4 = ro - Rx2*cos(ang(j+1));
        if i == 1
            id1 = ipend1(j);
            id2 = ipend1(j+1);
            id3 = id0 + j;
            id4 = id0 + j + 1;
        else
            id1 = id0 + (i-2)*(nang+1) + j;
            id2 = id0 + (i-2)*(nang+1) + j + 1;
            id3 = id0 + (i-1)*(nang+1) + j;
            id4 = id0 + (i-1)*(nang+1) + j + 1;
        end
        if i == (ne+na); ipend2 = [ipend2 id3 id4]; end
        node(1,id1) = x1; node(2,id1) = y1;
        node(1,id2) = x2; node(2,id2) = y2;
        node(1,id3) = x3; node(2,id3) = y3;
        node(1,id4) = x4; node(2,id4) = y4;
        %------------------------------------------------------------------
        ie = ie + 1;
        elem(1,ie) = id1; elem(2,ie) = id3; elem(3,ie) = id4; elem(4,ie) = id2;
        %------------------------------------------------------------------
        if i <= ne
            elem(5,ie) = 100 + i;
        else
            elem(5,ie) = 300 + i - ne;
        end
        %------------------------------------------------------------------
    end
end
ipend2 = sort(unique(ipend2));
nbp = size(node,2);

%--------------------------------------------------------------------------
rcoin = ri - a;
sfac  = 0.9;
rrec = sfac * rcoin;
xrec = rrec / sqrt(2); % square but can be modified
yrec = rrec / sqrt(2);
nsmoo = 10; % smooth zone / fixed but may be computed
nbpbotlef = ny1/2+1; % = nang/2+1
botline(1,1:nbpbotlef) = lx - linspace(0,xrec,nbpbotlef); % same order than ipend2
botline(2,1:nbpbotlef) = ly - yrec; % same order than ipend2
lefline(1,1:nbpbotlef) = lx - xrec; % same order than ipend2
lefline(2,1:nbpbotlef) = ly - linspace(yrec,0,nbpbotlef); % same order than ipend2
%--------------------------------------------------------------------------
uppline = [botline(:,1:nbpbotlef-1) lefline];
lowline = node(1:2,ipend2);
dvec = (uppline - lowline) ./ nsmoo;
id0 = nbp;
ipend3 = [];
for i = 1:nsmoo
    for j = 1:ny1
        if i == 1
            id1 = ipend2(j);
            id2 = ipend2(j+1);
            id3 = id0 + j;
            id4 = id0 + j + 1;
        else
            id1 = id0 + (i-2)*(ny1+1) + j;
            id2 = id0 + (i-2)*(ny1+1) + j + 1;
            id3 = id0 + (i-1)*(ny1+1) + j;
            id4 = id0 + (i-1)*(ny1+1) + j + 1;
        end
        %------------------------------------------------------------------
        if i == nsmoo; ipend3 = [ipend3 id3 id4]; end
        %------------------------------------------------------------------
        x1 = lowline(1,j) + (i-1) * dvec(1,j);
        y1 = lowline(2,j) + (i-1) * dvec(2,j);
        x2 = lowline(1,j+1) + (i-1) * dvec(1,j+1);
        y2 = lowline(2,j+1) + (i-1) * dvec(2,j+1);
        x3 = lowline(1,j) + i * dvec(1,j);
        y3 = lowline(2,j) + i * dvec(2,j);
        x4 = lowline(1,j+1) + i * dvec(1,j+1);
        y4 = lowline(2,j+1) + i * dvec(2,j+1);
        %------------------------------------------------------------------
        node(1,id1) = x1; node(2,id1) = y1;
        node(1,id2) = x2; node(2,id2) = y2;
        node(1,id3) = x3; node(2,id3) = y3;
        node(1,id4) = x4; node(2,id4) = y4;
        %------------------------------------------------------------------
        ie = ie + 1;
        elem(1,ie) = id1; elem(2,ie) = id3; elem(3,ie) = id4; elem(4,ie) = id2;
        %------------------------------------------------------------------
        elem(5,ie) = 1;
    end
end
ipend3 = sort(unique(ipend3));
nbp = size(node,2);

%--------------------------------------------------------------------------
id0 = nbp;
for i = 1:nbpbotlef-1 % lines go up
    for j = 1:nbpbotlef-1 % columns go left
        if i == 1
            id1 = ipend3(j);
            id2 = ipend3(j+1);
            id3 = id0 + j;
            id4 = id0 + j + 1;
        else
            if j <= nbpbotlef-1
                id1 = id0 + (i-2)*nbpbotlef + j;
                id2 = id0 + (i-2)*nbpbotlef + j + 1;
                id3 = id0 + (i-1)*nbpbotlef + j;
                id4 = id0 + (i-1)*nbpbotlef + j + 1;
            else
                id1 = id0 + (i-2)*nbpbotlef + j;
                id2 = ipend3(i);
                id3 = id0 + (i-1)*nbpbotlef + j;
                id4 = ipend3(i+1);
            end
        end
        %------------------------------------------------------------------
        x1 = botline(1,j);   y1 = lefline(2,i);
        x2 = botline(1,j+1); y2 = lefline(2,i);
        x3 = botline(1,j);   y3 = lefline(2,i+1);
        x4 = botline(1,j+1); y4 = lefline(2,i+1);
        %------------------------------------------------------------------
        node(1,id1) = x1; node(2,id1) = y1;
        node(1,id2) = x2; node(2,id2) = y2;
        node(1,id3) = x3; node(2,id3) = y3;
        node(1,id4) = x4; node(2,id4) = y4;
        %------------------------------------------------------------------
        ie = ie + 1;
        elem(1,ie) = id1; elem(2,ie) = id3; elem(3,ie) = id4; elem(4,ie) = id2;
        %------------------------------------------------------------------
        elem(5,ie) = 1;
    end
end


%--------------------------------------------------------------------------

figure
f_view_meshquad(node,elem,':','w'); hold on
for i = 1:ne
    it2d = find(elem(5,:) == 100 + i);
    f_view_meshquad(node,elem,it2d,[randi(255) randi(255) randi(255)]./255); hold on
end

for i = 1:nx2
    it2d = find(elem(5,:) == 200 + i);
    f_view_meshquad(node,elem,it2d,[randi(255) randi(255) randi(255)]./255); hold on
end

for i = 1:na
    it2d = find(elem(5,:) == 300 + i);
    f_view_meshquad(node,elem,it2d,[randi(255) randi(255) randi(255)]./255); hold on
end

return




%--------------------------------------------------------------------------
figure
f_view_meshquad(p2d,t2d,':','w'); hold on
plot(p2d(1,ipend1),p2d(2,ipend1),'ro');
plot(p2d(1,ipend2),p2d(2,ipend2),'b*');
plot(p2d(1,ipend3),p2d(2,ipend3),'m*');


figure
f_view_meshquad(p2d,t2d,':','w'); hold on
for i = 1:nbpbotlef
    plot(botline(1,i),botline(2,i),'b*');
    plot(lefline(1,i),lefline(2,i),'ro');
end




