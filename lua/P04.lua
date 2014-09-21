-- find the number of elements of a list
-- > myLength{1, 2, 3, 4}
-- 4

myLength = function (t)
    return #t
end

print(myLength{1, 2, 3, 4})
