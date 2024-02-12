classdef xxx < handle
    properties
        a
        b
    end

    methods
        function val = get.a(obj)
            if ~isempty(obj.a)
                fprintf('... \n')
                val = obj.a;
            else
                fprintf('cal_a \n')
                %obj.cal_a;
                val = obj.a;
            end
        end
        function obj = cal_a(obj)
            obj.a = 1+2;
        end
    end
end