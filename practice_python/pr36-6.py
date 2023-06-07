## class_abc_error
from abc import *

class StudentBase(metaclass=ABCMeta):
	@abstractmethod
	def study(self):
		pass		# 추상 메서드는 호출할 일이 없으므로 빈 메서드로 만듦

	@abstractmethod
	def go_to_school(self):
		pass

class Student(StudentBase):
	def study(self):
		print('Study')

	def go_to_school(self):
		print('go to school')

#모든 abstractmethod가 붙은 추상 메서드를 구현하여야함!

james = Student()
james.study()

# 추상 메서드는 인스턴스로 만들 수 없음
#james = StudentBase()





