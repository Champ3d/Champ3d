function  qdom = f_add_line2d(qdom,varargin)

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
arglist = {'id','ids','ide','nbi','dtype','ips','ipe','fixed','lzone','rzone','linetype','flog'};

% --- default input value
id = [];
ids = [];
ide = [];
nbi = 1;
dtype = 'lin';
ips = []; 
ipe = [];
fixed = 0;
lzone = [];
rzone = [];
linetype = 'straight';
flog = 1.05;
% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
% -------------------------------------------------------------------------
if isempty(ids) || isempty(ide)
    error([mfilename ': need id of start and end points !']);
end
%--------------------------------------------------------------------------
if nbi == 0; dtype = 'lin'; end
%--------------------------------------------------------------------------
if all(fixed == 'yes') || all(fixed == 'y') || fixed ~= 0
    fixed = 1;
elseif all(fixed == 'no')  || all(fixed == 'none') || fixed == 0
    fixed = 0;
else
    fixed = 0;
end
%--------------------------------------------------------------------------
if isfield(qdom,'line2d')
    len = length(qdom.line2d);
    ip  = len + 1;
else
    ip = 1;
end
%--------------------------------------------------------------------------
if isempty(id)
    id = ['XXLine2dNo' num2str(ip)];
else
    line2d.id = id;
end
line2d.linetype = linetype;
%--------------------------------------------------------------------------
ips = f_find_id2d(qdom.p2d,'id',ids);
ipe = f_find_id2d(qdom.p2d,'id',ide);
%--------------------------------------------------------------------------
line2d.ids = ids;
line2d.ide = ide;
line2d.nbi = nbi;
line2d.dtype = dtype;
line2d.flog = flog;
line2d.ips = ips;
line2d.ipe = ipe;
line2d.fixed = fixed;
line2d.lzone = lzone;
line2d.rzone = rzone;
line2d.linezone = [];
line2d.xcen = (qdom.p2d(ips).x + qdom.p2d(ipe).x)/2;
line2d.ycen = (qdom.p2d(ips).y + qdom.p2d(ipe).y)/2;
%--------------------------------------------------------------------------
qdom.line2d(ip) = line2d;





