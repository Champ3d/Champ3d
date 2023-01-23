function  qdom = f_add_zone2d(qdom,varargin)

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
arglist = {'id',...
           'bline','tline','lline','rline',...
           'atline','arline','etline','erline','tscotchline','bscotchline','cointline','coinrline', ...
           'zonetype','nomesh'};

% --- default input value
id = [];
bline = [];
tline = [];
lline = []; 
rline = [];
zonetype = 'regvo'; % original version of regular region
nomesh = 0;
atline = [];
arline = [];
etline = [];
erline = [];
tscotchline = [];
bscotchline = [];
cointline = [];
coinrline = [];


% --- check and update input
allInput = [];
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
        eval(['allInput{' num2str(i) '} = ' '''' lower(varargin{2*i-1}) ''';'])
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
% for i = 1:(nargin-1)/2
%     eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
% end
%--------------------------------------------------------------------------
if isempty(bline) || isempty(tline) || isempty(lline) || isempty(rline)
    error([mfilename ': bottom, top, left and right lines cannot be empty !']);
end
%--------------------------------------------------------------------------
if ischar(bline)
    bline = {bline};
end
if ischar(tline)
    tline = {tline};
end
if ischar(lline)
    lline = {lline};
end
if ischar(rline)
    rline = {rline};
end
%--------------------------------------------------------------------------
if isfield(qdom,'zone2d')
    len = length(qdom.zone2d);
    ip  = len + 1;
else
    ip = 1;
end
%--------------------------------------------------------------------------
if isempty(id)
    id = ['XXZone2dNo' num2str(ip)];
else
    zone2d.id = id;
end
zone2d.zonetype = zonetype;
zone2d.nomesh   = nomesh;
%--------------------------------------------------------------------------
ibline = [];
for i = 1:length(bline)
    il = f_find_id2d(qdom.line2d,'id',bline{i});
    ibline = [ibline il];
    qdom.line2d(il).linezone = [qdom.line2d(il).linezone ip];
end
itline = [];
for i = 1:length(tline)
    il = f_find_id2d(qdom.line2d,'id',tline{i});
    itline = [itline il];
    qdom.line2d(il).linezone = [qdom.line2d(il).linezone ip];
end
illine = [];
for i = 1:length(lline)
    il = f_find_id2d(qdom.line2d,'id',lline{i});
    illine = [illine il];
    qdom.line2d(il).linezone = [qdom.line2d(il).linezone ip];
end
irline = [];
for i = 1:length(rline)
    il = f_find_id2d(qdom.line2d,'id',rline{i});
    irline = [irline il];
    qdom.line2d(il).linezone = [qdom.line2d(il).linezone ip];
end
%--------------------------------------------------------------------------
if isempty(ibline) || isempty(itline) || isempty(illine) || isempty(irline)
    error([mfilename ': bound lines not found !']);
end
%--------------------------------------------------------------------------
if ischar(atline)
    atline = {atline};
end
if ischar(arline)
    arline = {arline};
end
if ischar(etline)
    etline = {etline};
end
if ischar(erline)
    erline = {erline};
end
if ischar(tscotchline)
    tscotchline = {tscotchline};
end
if ischar(bscotchline)
    bscotchline = {bscotchline};
end
if ischar(cointline)
    cointline = {cointline};
end
if ischar(coinrline)
    coinrline = {coinrline};
end
%--------------------------------------------------------------------------
% atline arline etline erline tscotchline bscotchline cointline coinrline
iatline = [];
for i = 1:length(atline)
    il = f_find_id2d(qdom.line2d,'id',atline{i});
    iatline = [iatline il];
    qdom.line2d(il).linezone = [qdom.line2d(il).linezone ip];
end
iarline = [];
for i = 1:length(arline)
    il = f_find_id2d(qdom.line2d,'id',arline{i});
    iarline = [iarline il];
    qdom.line2d(il).linezone = [qdom.line2d(il).linezone ip];
end
ietline = [];
for i = 1:length(etline)
    il = f_find_id2d(qdom.line2d,'id',etline{i});
    ietline = [ietline il];
    qdom.line2d(il).linezone = [qdom.line2d(il).linezone ip];
end
ierline = [];
for i = 1:length(erline)
    il = f_find_id2d(qdom.line2d,'id',erline{i});
    ierline = [ierline il];
    qdom.line2d(il).linezone = [qdom.line2d(il).linezone ip];
end
itscotchline = [];
for i = 1:length(tscotchline)
    il = f_find_id2d(qdom.line2d,'id',tscotchline{i});
    itscotchline = [itscotchline il];
    qdom.line2d(il).linezone = [qdom.line2d(il).linezone ip];
end
ibscotchline = [];
for i = 1:length(bscotchline)
    il = f_find_id2d(qdom.line2d,'id',bscotchline{i});
    ibscotchline = [ibscotchline il];
    qdom.line2d(il).linezone = [qdom.line2d(il).linezone ip];
end
icointline = [];
for i = 1:length(cointline)
    il = f_find_id2d(qdom.line2d,'id',cointline{i});
    icointline = [icointline il];
    qdom.line2d(il).linezone = [qdom.line2d(il).linezone ip];
end
icoinrline = [];
for i = 1:length(coinrline)
    il = f_find_id2d(qdom.line2d,'id',coinrline{i});
    icoinrline = [icoinrline il];
    qdom.line2d(il).linezone = [qdom.line2d(il).linezone ip];
end
%--------------------------------------------------------------------------
% make use of inherit
zone2d.bline = bline;
zone2d.tline = tline;
zone2d.lline = lline;
zone2d.rline = rline;
zone2d.ibline = ibline;
zone2d.itline = itline;
zone2d.illine = illine;
zone2d.irline = irline;
zone2d.atline = atline;
zone2d.arline = arline;
zone2d.etline = etline;
zone2d.erline = erline;
zone2d.tscotchline = tscotchline;
zone2d.bscotchline = bscotchline;
zone2d.cointline = cointline;
zone2d.coinrline = coinrline;
zone2d.iatline = iatline;
zone2d.iarline = iarline;
zone2d.ietline = ietline;
zone2d.ierline = ierline;
zone2d.itscotchline = itscotchline;
zone2d.ibscotchline = ibscotchline;
zone2d.icointline = icointline;
zone2d.icoinrline = icoinrline;
zone2d.divisible = 0;
%--------------------------------------------------------------------------
qdom.zone2d(ip) = zone2d;


