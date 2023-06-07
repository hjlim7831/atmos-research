# class_attribute.py
"""
class Person:
	def __init__(self):
		self.hello = 'Hi.'

	def greeting(self):
		print(self.hello)
james = Person()
james.greeting()
"""
# class_init_attribute.py
class Person:
	def __init__(self, name, age, address):
		self.hello = 'Hi.'
		self.name = name
		self.age = age
		self.address = address
	def greeting(self):
		print('{0} I am {1}'.format(self.hello, self.name))

maria = Person('maria', 20, 'Seoul, Seocho, Banpo-dong')
maria.greeting()

print('name:', maria.name)
print('age:',maria.age)
print('address:',maria.address)



