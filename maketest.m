function maketest(n, p)
% MAKETEST   make test case for mittag leffler function.
%   maketest(n, p) print out an Mathematica script for compare the result
%   of mittag_leffler and MittagLeffler. n is case number, and p represent
%   accuracy 10^(-p).
%
%   Author: Yang Zongze
%   E-mail: yangzognze@gmail.com
%   Date: 2017-9-10

    if nargin < 2
        p = 12;
    end
    if nargin < 1
        n = 10;
    end
    % funs = {@mittag_leffler, @mlf};
    funs = {@mittag_leffler_wapper};
    data = make_data(n);
    make_mathematica_script(data, n, p, funs);
end

function ret = mittag_leffler_wapper(alpha, beta, z, p)
    ret = mittag_leffler(alpha,beta,z,10^(-p));
end

function data = make_data(n)
    alpha = 100*rand(n,1);
    beta = -100 + 200*rand(n, 1);
    z = 100*rand(n, 1);
    digitsOld = digits(4);
    data = double(vpa([alpha, beta, z]));
    digits(digitsOld)
end

function make_mathematica_script(data, n, p, funs)
    ret = run_test(data, n, p, funs);

    str_cell = cellfun(@func2str, funs, 'UniformOutput', false);
    str = sprintf(strjoin(repmat({'%s'}, 1, length(funs)),','),str_cell{:});

    s = arrayfun(@matlab2math, ret, 'UniformOutput', false);
    
    fprintf(1, 'resultTable = List[\n');
    fprintf(1, 'List[alpha, beta, z, MittagLefflerE, %s],\n', str);
    for i = 1:n
        para = sprintf('%g, %g, %g', data(i, 1), data(i, 2), data(i, 3));
        fprintf(1, 'List[%s, N[MittagLefflerE@@Rationalize[{%s},0],10], %s]', para, para, strjoin(s(i,:), ','));
        if i ~= n
            fprintf(1, ',\n');
        end
    end
    fprintf(1, '];\n');
    
end

function ret = run_test(data, n, p, funs)
    ret = zeros(n, length(funs));
    for i = 1:n
        for j = 1:length(funs)
            ret(i, j) = funs{j}(data(i, 1), data(i, 2), data(i, 3), p);
        end
    end
end

function s1 = matlab2math(f)
    e1 = sprintf('%g', f);
    index = find(e1=='e');
    if index
        s1 = [e1(1:index-1) '*10^' e1(index+1:end)];
    else
        s1 = e1;
    end
end

