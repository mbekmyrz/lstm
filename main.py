import math


def dec_bin(number, integer_width, total_width):
    if number < 0:
        sign = '1'
        whole, frac = str(number)[1:].split('.')
    else:
        sign = '0'
        whole, frac = str(number).split('.')
    whole = bin(int(whole))[2:2+integer_width]
    binary = sign + whole
    frac_precision = total_width - integer_width - 1
    frac = float("0." + frac)
    while frac_precision > 0:
        frac *= 2
        frac_int = int(frac)
        if frac_int == 1:
            frac -= frac_int
            binary += '1'
        else:
            binary += '0'
        frac_precision -= 1
    return binary


def bin_dec(number, integer_width, total_width):
    number = str(number)
    whole = int(number[1:1+integer_width], 2)
    dec = float(whole)
    index = total_width - 1
    while index > integer_width:
        digit = int(number[index])
        dec += digit * (2 ** (-index+integer_width))
        index -= 1
    if number[0] == '1':
        dec = -dec
    return dec


def sigmoid(x):
    return 1 / (1 + math.exp(-x))


def sigmoid_lut(depth, integer_width, total_width):
    input_width = int(math.log(depth, 2))
    content = []
    for a in range(depth):
        b = bin(a)[2:]
        b = '0'*(input_width-len(b)) + b
        x = sigmoid(bin_dec(b, integer_width, input_width))
        print('\nbinary input:', b, '=', bin_dec(b, integer_width, input_width), 'sigmoid decimal output', x)
        x = dec_bin(x, input_width, total_width)
        print('sigmoid lut content at', b, ':', x)
        content.append(x)
    return content


def tanh_lut(depth, integer_width, total_width):
    input_width = int(math.log(depth, 2))
    content = []
    for a in range(depth):
        b = bin(a)[2:]
        b = '0'*(input_width-len(b)) + b
        x = math.tanh(bin_dec(b, integer_width, input_width))
        print('\nbinary input:', b, '=', bin_dec(b, integer_width, input_width), 'tanh decimal output', x)
        x = dec_bin(x, input_width, total_width)
        print('tanh lut content at', b, ':', x)
        content.append(x)
    return content


s = sigmoid_lut(depth=16, integer_width=1, total_width=32)
t = tanh_lut(depth=16, integer_width=1, total_width=32)
