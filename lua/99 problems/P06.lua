-- find out whether a list is a palindrome. A palindrome can be read forward or backward
-- > isPalindrome{1, 2, 3}
-- false
-- > isPalindrome{1, 2, 2, 1}
-- true

isPalindrome = function(t)
    local n2 = math.floor(#t/2)
    for i = 1, n2 do
        if t[i] ~= t[#t - i + 1] then
            return false
        end
    end
    return true
end

print(isPalindrome{1, 2, 3})
print(isPalindrome{1, 2, 2, 1})
