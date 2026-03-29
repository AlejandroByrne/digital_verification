def register_transfer(regs: list[int], transfers: tuple[int, int]) -> list[int]:
    # One directional copy, not a swap
    for src, dst in transfers:
        regs[dst] = regs[src]
    return regs