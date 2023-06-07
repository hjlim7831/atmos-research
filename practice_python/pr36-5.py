## class_multiple_inheritance
"""
class Person:
	def greeting(self):
		print('안녕하세요.')

class University:
	def manage_credit(self):
		print('학점 관리')

class Undergraduate(Person, University):
	def study(self):
		print('공부하기')

james = Undergraduate()
james.greeting()
james.manage_credit()
james.study()
"""

## class_diamond_inheritance

class A:
	def greeting(self):
		print('Hi. I am A')

class B(A):
	def greeting(self):
		print('Hi. I am B')

class C(A):
	def greeting(self):
		print('Hi. I am C')

class D(B,C):
	pass

x = D()
x.greeting()

print(D.mro()) #다이아몬드 상속에선 이걸 확인하는 것이 가장 좋음.


