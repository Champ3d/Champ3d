classdef geo2d < handle
    properties
        id = [];
        d = 1;
        dtype = 'lin';
        dnum = 1;

    end
    methods
        function obj = geo2d(id, d, dtype, dnum)
            obj.id = id;
            obj.d = d;
            obj.dtype = dtype;
            obj.dnum = dnum;
        end
    end
end