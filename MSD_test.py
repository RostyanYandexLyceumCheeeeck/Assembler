import os
from random import randint

flag_del = True
filename = 'fileTest.txt'
path = "./JDK-dir/jdk8u402-b06/bin/java -jar rars1_5.jar MSD_Radix_Sort\(16\).asm pa "


def func(arr, start, end):
    for i in range(start, end + 1):
        arr.append(chr(i))


def generate_str(l=None):
    if l is None:
        l = randint(0, 10**3)
    symbols = []
    func(symbols, 32, 126)    # ' ' -- '~'

    mas = [symbols[randint(0, len(symbols) - 1)] for _ in range(l)]
    mas.append('\n')
    return "".join(mas)


def generate_test():
    count_lines = randint(0, 10**3)
    lines = [generate_str() for _ in range(count_lines)]
    return lines


def test():
    lines = generate_test()
    with open(filename, 'w', encoding='utf-8') as fin:
        for line in lines:
            fin.write(line)

    lines.sort()
    os.system(path + filename)
    with open(filename + ".sorted", 'r', encoding='utf-8') as f:
        result = f.readlines()
    
    try:
        for i in range(len(lines)):
            assert lines[i] == result[i], i
    except AssertionError as e:
        ind = e.args[0]
        print("\nBUG!BUG!BUG!BUG!BUG!BUG!")
        print(f"number line error: {ind + 1}\n")
        print(f"result line:\n{result[ind]}")
        print("\n=============================================\n\n")
        print(f"expected line:\n{lines[ind]}")
    finally:
        if flag_del:
            os.remove(filename)
            os.remove(filename + ".sorted")


if __name__ == "__main__":
    test()

