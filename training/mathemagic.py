def digit_sum_magic(number: int) -> dict:
    """Return steps reducing number to a single digit via digit sums."""
    original = number
    steps = []
    while number >= 10:
        digits = [int(d) for d in str(number)]
        s = sum(digits)
        steps.append(" + ".join(str(d) for d in digits) + f" = {s}")
        number = s
    return {"original": original, "steps": steps, "result": number}


if __name__ == '__main__':
    import sys
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 12345
    info = digit_sum_magic(n)
    print(f"Magic reduction of {info['original']}")
    for step in info['steps']:
        print(step)
    print(f"Result: {info['result']}")
