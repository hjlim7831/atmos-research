class Animal:
	def eat(self):
		print('eat')

class Wing:
	def flap(self):
		print('flap')

class Bird(Animal, Wing):
	def fly(self):
		print('날다')

b = Bird()
b.eat()
b.flap()
b.fly()
print(issubclass(Bird, Animal))
print(issubclass(Bird, Wing))
