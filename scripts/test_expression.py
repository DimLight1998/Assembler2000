import random
import math
import subprocess

template = '''.data
addl %s, %%eax
'''

class Expression(object):
    OPS = ['+', '-', '*']
    UNARYS = ['-']

    GROUP_PROB = 0.3
    UNARY_PROB = 0.05

    MIN_NUM, MAX_NUM = 0, 20

    def __init__(self, maxNumbers, _maxdepth=None, _depth=0):
        """
        maxNumbers has to be a power of 2
        """
        self.operator = None
        if _maxdepth is None:
            _maxdepth = int(math.log(maxNumbers, 2) - 1)

        if _depth < _maxdepth and random.randint(0, _maxdepth) > _depth:
            self.left = Expression(maxNumbers, _maxdepth, _depth + 1)
        elif random.random() < Expression.UNARY_PROB:
            self.left = ''
            self.operator = random.choice(Expression.UNARYS)
        else:
            self.left = random.randint(Expression.MIN_NUM, Expression.MAX_NUM)

        if _depth < _maxdepth and random.randint(0, _maxdepth) > _depth:
            self.right = Expression(maxNumbers, _maxdepth, _depth + 1)
        else:
            self.right = random.randint(Expression.MIN_NUM, Expression.MAX_NUM)

        self.grouped = random.random() < Expression.GROUP_PROB
        if self.operator is None:
            self.operator = random.choice(Expression.OPS)

    def __str__(self):
        s = '{0!s}{1}{2!s}'.format(self.left, self.operator, self.right)
        if self.grouped:
            return '({0})'.format(s)
        else:
            return s

if __name__ == '__main__':
    while True:
        s = str(Expression(256))
        try:
            std = eval(s)
            print s
        except:
            continue
        with open('input.txt', 'w') as f:
            f.write(template % (s, ))
        p = subprocess.Popen(['Assmebler2000.exe'], stdout=subprocess.PIPE, shell=True)
        out, err = p.communicate()
        my = int(out)
        print std, my
        if std != my:
            break
        
