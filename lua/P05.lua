-- reverse a list
-- > myReverse{1, 2, 3, 4}
-- {4, 3, 2, 1}

myReverse = function (t)
    local acc = {}
    for i = #t, 1, -1 do
        acc[i] = t[#t - i + 1]
    end
    return acc
end

printList = function (t)
    for i,v in ipairs(t) do
        print(v)
    end
end

printList(myReverse{1, 2, 3, 4})
