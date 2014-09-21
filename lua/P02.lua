-- find the last but one element of a list
-- > myButLast{1, 2, 3, 4}
-- 3

myButLast = function (t)
    return t[#t - 1]
end

print(myButLast{1, 2, 3, 4})
