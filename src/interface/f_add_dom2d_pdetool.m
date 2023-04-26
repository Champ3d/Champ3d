function dom2d = f_add_dom2d_pdetool(dom2d,varargin)
%--------------------------------------------------------------------------
% Operator accepted : 
%           '+' : union
%           '*' : intersection
%           '-' : difference
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
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




