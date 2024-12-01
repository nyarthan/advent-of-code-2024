pub fn solution() -> u32 {
    let input = include_str!("input");
    let (first, second): (Vec<_>, Vec<_>) = input.split_whitespace().enumerate().partition(|(i, _)| i % 2 == 0);
    let mut first: Vec<i32> = first.into_iter().map(|(_, s)| s.parse().unwrap()).collect();
    let mut second: Vec<i32> = second.into_iter().map(|(_, s)| s.parse().unwrap()).collect();

    first.sort();
    second.sort();

    let differences: Vec<u32> = first.iter().zip(second.iter()).map(|(f, s)| f.abs_diff(*s)).collect();
    let difference: u32 = differences.iter().sum();

    difference
}
