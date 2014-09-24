-- find the last element of a list
-- > myLast{1, 2, 3, 4}
-- 4

myLast = function (t)
    return t[#t]
end

print(myLast{1, 2, 3, 4})
