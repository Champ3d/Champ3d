function dom2d = f_add_shape2d(dom2d,varargin)
%--------------------------------------------------------------------------
% Operator accepted : 
%           '+' : union
%           '*' : intersection
%           '-' : difference
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
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
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------
nbDomMax = 10000;
nbNum = ceil(log10(nbDomMax)) + 1;

if isempty(dom2d)
    dom2d.mesher = 'pdetool2DMatlab';
    dom2d.geoIn.dgeo = [];
    dom2d.geoIn.geo = [];
    dom2d.geoIn.nbDom = 0;
    dom2d.geoIn.dName = [];
    dom2d.geoIn.form = [];
end

if nargin <= 1
    disp('No dom to add!');
    return
end

switch lower(varargin{1}.type)
    case 'geofromedge'
        dom2d.geoIn.type = 'geofromedge';
        for i = 1 : nargin-1
            dom2d.geoIn.dgeo = [dom2d.geoIn.dgeo varargin{i}.dgeo];
        end
    case 'geofromdom'
        dom2d.geoIn.type = 'geofromdom';
        if nargin <= 2
            form = [];
            for i = 1 : nargin-1
                dom2d.geoIn.geo = [dom2d.geoIn.geo varargin{i}.dgeo];
                dom2d.geoIn.nbDom = dom2d.geoIn.nbDom + 1;
                Num = [repmat('0',1,nbNum-length(num2str(dom2d.geoIn.nbDom))) num2str(dom2d.geoIn.nbDom)];
                dom2d.geoIn.dName = [dom2d.geoIn.dName; 'D' Num];
                if i == 1
                    form  = ['D' Num];
                else
                    form  = [form '+D' Num];
                end
            end
            if isempty(dom2d.geoIn.form)
                dom2d.geoIn.form = ['(' form ')'];
            else
                dom2d.geoIn.form = [dom2d.geoIn.form '+(' form ')'];
            end

        elseif ischar(varargin{nargin-2})
            switch varargin{nargin-2}
                case {'+','u','*','i','-','d'}
                    form = [];
                    for i = 1 : nargin-3
                        dom2d.geoIn.geo = [dom2d.geoIn.geo varargin{i}.dgeo];
                        dom2d.geoIn.nbDom = dom2d.geoIn.nbDom + 1;
                        Num = [repmat('0',1,nbNum-length(num2str(dom2d.geoIn.nbDom))) num2str(dom2d.geoIn.nbDom)];
                        dom2d.geoIn.dName = [dom2d.geoIn.dName; 'D' Num];
                        if i == 1
                            form  = ['D' Num];
                        else
                            form  = [form varargin{nargin-2} 'D' Num];
                        end
                    end
                    if isempty(dom2d.geoIn.form)
                        dom2d.geoIn.form = ['(' form ')'];
                    else
                        dom2d.geoIn.form = [dom2d.geoIn.form varargin{nargin-1} '(' form ')'];
                    end
                otherwise
                  disp('No dom added! Operator need to be defined!');
            end

        elseif ischar(varargin{nargin-1})
            switch varargin{nargin-1}
                case {'+','u','*','i','-','d'}
                    form = [];
                    for i = 1 : nargin-2
                        dom2d.geoIn.geo = [dom2d.geoIn.geo varargin{i}.dgeo];
                        dom2d.geoIn.nbDom = dom2d.geoIn.nbDom + 1;
                        Num = [repmat('0',1,nbNum-length(num2str(dom2d.geoIn.nbDom))) num2str(dom2d.geoIn.nbDom)];
                        dom2d.geoIn.dName = [dom2d.geoIn.dName; 'D' Num];
                        if i == 1
                            form  = ['D' Num];
                        else
                            form  = [form '+D' Num];
                        end
                    end
                    if isempty(dom2d.geoIn.form)
                        dom2d.geoIn.form = ['(' form ')'];
                    else
                        dom2d.geoIn.form = [dom2d.geoIn.form varargin{nargin-1} '(' form ')'];
                    end
                otherwise
                  disp('No dom added! Operator need to be defined!');
            end
        end
end
end




