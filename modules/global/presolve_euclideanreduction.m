function p = presolve_euclideanreduction(p)

if p.K.l+p.K.f>0 && p.feasible
    top = 1;
    % Very common with models with only 0,1,-1 so 
    % quick exit if that is the case
    bA = p.F_struc(1:p.K.f+p.K.l,:);
    [~,~,val] = find(bA(:));
    if any(abs(val)~=1)
        for i = 1:p.K.f+p.K.l
            row = bA(i,:);
            b = row(1);
            [~,idx,val] = find(row(2:end));
            d = gcdfactor(val);
            if d > 1
                row = row/d;
                p.F_struc(i,:) = row;
                b = row(1);
                br = floor(row(1));
                if b~=br && all(p.isbinary(idx) | p.isinteger(idx))
                    if i > p.K.f
                        % This is an inequality, so round
                        p.F_struc(i,1) = br;
                    end
                end
            end
        end
    end
end