import turtle as t
t.shape('turtle')
n = 6
for i in range(n):
	t.fd(100)
	t.rt(360/n)
	t.fd(100)
	t.lt(360/n*2)


t.mainloop()
