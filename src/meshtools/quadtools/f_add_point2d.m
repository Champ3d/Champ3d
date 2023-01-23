function qdom = f_add_point2d(qdom,varargin)

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
arglist = {'id','x','y','z','r','phi','pointtype'};

% --- default input value
id = [];
x  = [];
y  = [];
z  = [];
r  = [];
phi = [];
ptype = '2d';
% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if isempty(z)
    z = 0;
    ptype = '2d';
end
%--------------------------------------------------------------------------
if isfield(qdom,'p2d')
    lenp = length(qdom.p2d);
    ip   = lenp + 1;
else
    ip = 1;
end
%--------------------------------------------------------------------------
if isempty(id)
    id = ['XXPoint2dNo' num2str(ip)];
else
    p2d.id = id;
end
%--------------------------------------------------------------------------
if isempty(r)
    p2d.x = x;
    p2d.y = y;
    p2d.r = sqrt(x.^2 + y.^2);
    if p2d.r == 0
        p2d.phi = 0;
    else
        p2d.phi = acos(x/p2d.r)/pi*180;
    end
end
%--------------------------------------------------------------------------
if isempty(x)
    p2d.r = r;
    p2d.phi = phi;
    p2d.x = r.*cosd(phi);
    p2d.y = r.*sind(phi);
end
%--------------------------------------------------------------------------
qdom.p2d(ip) = p2d;




