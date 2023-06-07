# My Code
"""
def is_palindrome(word):
	l = len(word)
	TF = True
	if l<2:
		return TF
	else:
		if word[0] == word[-1]:
			return is_palindrome(word[1:l-1])
		else:
			return False
"""
#Example
def is_palindrome(word):
	if len(word) < 2:
		return True
	if word[0] != word[-1]:
		return False
	return is_palindrome(word[1:-1])


print(is_palindrome('hello'))
print(is_palindrome('level'))
