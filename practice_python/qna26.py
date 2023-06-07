x = {'a': 10, 'b': 20, 'c': 30, 'd': 40, 'e': 50}                # 딕셔너리
#x = {'strawberry', 'grape', 'orange', 'pineapple', 'cherry'}    # 세트
it = iter(x)                  # 이터레이터를 얻음
while True:
    try:
        #print(x[next(it)])    # 딕셔너리에 키를 지정해서 값 출력
        print(next(it))      # 세트의 요소 출력
    except StopIteration:
        break
