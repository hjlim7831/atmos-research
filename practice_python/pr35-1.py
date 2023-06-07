## class_class_attribute
"""
class Person:
	bag = []

	def put_bag(self,stuff):
#		self.bag.append(stuff) 모호함
		Person.bag.append(stuff)
james = Person()
james.put_bag('책')

maria = Person()
maria.put_bag('열쇠')
print(james.bag)
print(maria.bag)

print(james.__dict__)
print(Person.__dict__)
"""
## class_instance_attribute
"""
class Person:
	def __init__(self):
		self.bag = []
	
	def put_bag(self,stuff):
		self.bag.append(stuff)

james = Person()
james.put_bag('책')

maria = Person()
maria.put_bag('열쇠')

print(james.bag)
print(maria.bag)
"""
## class_private_class_attribute_error
class Knight:
	__item_limit = 10

	def print_item_limit(self):
		print(Knight.__item_limit)

x = Knight()
x.print_item_limit()
print(Knight.__item_limit)



