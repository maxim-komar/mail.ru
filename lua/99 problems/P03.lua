-- Find the K'th element of a list. The first element in is list is number 1
-- > elementAt({1, 2, 3, 4}, 2)
-- 2

elementAt = function (t,k)
    return t[k]
end

print(elementAt({1, 2, 3, 4}, 2))
