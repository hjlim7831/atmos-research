class Rectangle:
	def __init__(self, x1, y1, x2, y2):
		self.x1 = x1
		self.x2 = x2
		self.y1 = y1
		self.y2 = y2

rect = Rectangle(x1=20, y1=20, x2=40, y2=30)

area = abs(rect.x1-rect.x2)*abs(rect.y1-rect.y2)
print(area)

