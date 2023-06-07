## class_inheritance_attribute_error
"""
class Person:
	def __init__(self):
		print('Person __init__')
		self.hello = 'Hi.'

class Student(Person):
	def __init__(self):
		print('Student __init__')
		# 이 경우 이 코드를 추가함
		super().__init__()
#		super(Student, self).__init__() #이것도 위와 동일. 현재 클래스가 어떤 클래스인지를 명확히 표시하기 위해 사용

		self.school = 'Python Coding Dojang'

james = Student()
print(james.school)
print(james.hello)
"""
## class_inheritance_no_init

class Person:
	def __init__(self):
		print('Person __init__')
		self.hello = 'Hi.'

class Student(Person):
	pass

james = Student()
print(james.hello)


