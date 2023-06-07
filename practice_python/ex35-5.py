## MY Code
"""
class Date:
	@classmethod #Class method는 Class의 속성등에  접근하기 위해서만 사용함
	def is_date_valid(cls,DATE):
		date = DATE.split('-')
		if len(date) !=3:
			return False
		else:
			if int(date[1])>12 or int(date[2])>31:
				return False
			else:
				return True
"""
## Example
class Date:
	@staticmethod
	def is_date_valid(date_string):
		year, month, day = map(int, date_string.split('-'))
		return month <= 12 and day <= 31

if Date.is_date_valid('2000-10-31'):
	print('Good')
else:
	print('Wrong')
