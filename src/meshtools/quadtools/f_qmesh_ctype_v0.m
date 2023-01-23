%% ------------------------------------------------------------------------
%
% Programme EF 3D
% Probleme magneto-thermique du soudage par induction des CFRP
% Laboratoire IREENA, St Nazaire
% (c) HK.Bui, 2022
%
% -------------------------------------------------------------------------

clc
clear
close all

node = [];
elem = [];

%TODO
%Use bline, tline... style

%.- scotchline, d -- etline|---|coin-.
%|               |          \   \    |
%|                \          \   \   |
%|                  \          \   \ | coin
%|                    \          \  \|
%| h/ny                 \         \  | arline/a/na
%|                        \         \|
%|                          \        | erline, e/ne
%|                            \      |
%|- scotchline, nx1 -----------------\

%%
close all
clear
clc
%--------------------------------------------------------------------------
coin = 0.1;
elay = 0.1; % e-layer thickness
alay = 0.02; % a-layer thickness
e = 3*elay;
a = 3*alay;
d = 0.5;
h = coin + a + e;
%--------------------------------------------------------------------------
qdom = [];
qdom = f_add_point2d(qdom,'x',0           ,'y',0,'id','C7');
qdom = f_add_point2d(qdom,'x',-coin       ,'y',0,'id','C6a');
qdom = f_add_point2d(qdom,'x',-coin-1*alay,'y',0,'id','C6b');
qdom = f_add_point2d(qdom,'x',-coin-2*alay,'y',0,'id','C6c');
qdom = f_add_point2d(qdom,'x',-coin-3*alay,'y',0,'id','C5a');
qdom = f_add_point2d(qdom,'x',-coin-3*alay-1*elay,'y',0,'id','C5b');
qdom = f_add_point2d(qdom,'x',-coin-3*alay-2*elay,'y',0,'id','C5c');
qdom = f_add_point2d(qdom,'x',-coin-3*alay-3*elay,'y',0,'id','C4');
qdom = f_add_point2d(qdom,'x',-coin-3*alay-3*elay-d,'y',0,'id','C3');

qdom = f_add_point2d(qdom,'x',0,'y',-coin,'id','C8a');
qdom = f_add_point2d(qdom,'x',0,'y',-coin-1*alay,'id','C8b');
qdom = f_add_point2d(qdom,'x',0,'y',-coin-2*alay,'id','C8c');
qdom = f_add_point2d(qdom,'x',0,'y',-coin-3*alay,'id','C9a');
qdom = f_add_point2d(qdom,'x',0,'y',-coin-3*alay-1*elay,'id','C9b');
qdom = f_add_point2d(qdom,'x',0,'y',-coin-3*alay-2*elay,'id','C9c');
qdom = f_add_point2d(qdom,'x',0,'y',-coin-3*alay-3*elay,'id','C2');
qdom = f_add_point2d(qdom,'x',-coin-3*alay-3*elay-d,'y',-coin-3*alay-3*elay,'id','C1');

nbimax = 20;
qdom = f_add_line2d(qdom,'id','L1','ids','C7','ide','C6a','nbi',randi([1 nbimax]),'dtype','lin');
qdom = f_add_line2d(qdom,'id','L2','ids','C7','ide','C8a','nbi',randi([1 nbimax]),'dtype','lin');
qdom = f_add_line2d(qdom,'id','L3','ids','C3','ide','C4','nbi',20,'dtype','lin','fixed',1);
qdom = f_add_line2d(qdom,'id','L4','ids','C1','ide','C2','nbi',25,'dtype','lin','fixed',1);
qdom = f_add_line2d(qdom,'id','L5','ids','C1','ide','C3','nbi',20,'dtype','lin','fixed',1);
qdom = f_add_line2d(qdom,'id','Lar1','ids','C8a','ide','C8b','nbi',randi([1 nbimax]),'dtype','lin');
qdom = f_add_line2d(qdom,'id','Lar2','ids','C8b','ide','C8c','nbi',randi([1 nbimax]),'dtype','lin');
qdom = f_add_line2d(qdom,'id','Lar3','ids','C8c','ide','C9a','nbi',randi([1 nbimax]),'dtype','lin');
qdom = f_add_line2d(qdom,'id','Ler1','ids','C9a','ide','C9b','nbi',randi([1 nbimax]),'dtype','lin');
qdom = f_add_line2d(qdom,'id','Ler2','ids','C9b','ide','C9c','nbi',randi([1 nbimax]),'dtype','lin');
qdom = f_add_line2d(qdom,'id','Ler3','ids','C9c','ide','C2','nbi',randi([1 nbimax]),'dtype','lin');
qdom = f_add_line2d(qdom,'id','Lat1','ids','C6a','ide','C6b','nbi',randi([1 nbimax]),'dtype','lin');
qdom = f_add_line2d(qdom,'id','Lat2','ids','C6b','ide','C6c','nbi',randi([1 nbimax]),'dtype','lin');
qdom = f_add_line2d(qdom,'id','Lat3','ids','C6c','ide','C5a','nbi',randi([1 nbimax]),'dtype','lin');
qdom = f_add_line2d(qdom,'id','Let1','ids','C5a','ide','C5b','nbi',randi([1 nbimax]),'dtype','lin');
qdom = f_add_line2d(qdom,'id','Let2','ids','C5b','ide','C5c','nbi',randi([1 nbimax]),'dtype','lin');
qdom = f_add_line2d(qdom,'id','Let3','ids','C5c','ide','C4','nbi',randi([1 nbimax]),'dtype','lin');

%--------------------------------------------------------------------------
qdom = f_add_zone2d(qdom,'id','Z3',...
          'bline','L4',...
          'tline',{'L1','L3','Let1','Let2','Let3','Lat1','Lat2','Lat3'},...
          'lline','L5',...
          'rline',{'L2','Ler1','Ler2','Ler3','Lar1','Lar2','Lar3'},...
          'atline',{'Lat1','Lat2','Lat3'},...
          'arline',{'Lar1','Lar2','Lar3'},...
          'etline',{'Let1','Let2','Let3'},...
          'erline',{'Ler1','Ler2','Ler3'},...
          'tscotchline','L3',...
          'bscotchline','L4',...
          'cointline','L1',...
          'coinrline','L2',...
          'zonetype','ctype'); % 'regvo', 'ctype'



%%
zone2d = qdom.zone2d;
line2d = qdom.line2d;
p2d = qdom.p2d;
%%


x0 = 0;
ri = 1;
e  = 1;
ro = ri+e;
w = 0; d = 0.5; a = 0.2;
nx1 = 20;
nx2 = 20;
ny  = 24; % should be even
ne  = 10;
na  = 10;

ly = ro; % total length
lx = ro + w + d; % total length
id0 = 0;
ie  = 0;
dy  = ro - (ro .* cos(linspace(0,pi/2,ny+1))); % nb points should be odd
%dy  = linspace(0,ly,ny1+1);


ipend1 = [];
for i = 1:ny
    for j = 1:nx1
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
nbpbotlef = ny/2+1; % = nang/2+1
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
    for j = 1:ny
        if i == 1
            id1 = ipend2(j);
            id2 = ipend2(j+1);
            id3 = id0 + j;
            id4 = id0 + j + 1;
        else
            id1 = id0 + (i-2)*(ny+1) + j;
            id2 = id0 + (i-2)*(ny+1) + j + 1;
            id3 = id0 + (i-1)*(ny+1) + j;
            id4 = id0 + (i-1)*(ny+1) + j + 1;
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




