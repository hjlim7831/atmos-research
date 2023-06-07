## class_method_overriding

class Person:
	def greeting(self):
		print('Hi.')

class Student(Person):
	def greeting(self):
#		print('Hi. I am a Student')
		super().greeting()
		print('저는 파이썬 코딩 도장 학생입니다.')

james = Student()
james.greeting()

