class AdvancedList(list):
	def replace(self, a, b):
		l = len(self)
		for i in range(l):
			if self[i] == a:
				self[i] = b


x = AdvancedList([1, 2, 3, 1, 2, 3, 1, 2, 3])
x.replace(1, 100)
print(x)

