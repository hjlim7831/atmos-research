## class_is_a
"""
class Person:
	def greeting(self):
		print('Hi.')

class Student(Person):
	def study(self):
		print('Study')
"""

## class_has_a
class Person:
	def greeting(self):
		print('Hi.')

class PersonList:
	def __init__(self):
		self.person_list = []
	
	def append_person(self, person):
		self.person_list.append(person)

a = Person()
a.greeting()
LIST = PersonList()
LIST.append_person(a)



