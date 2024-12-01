use std::collections::HashMap;

pub fn solution() -> i32 {
    let input = include_str!("input");
    let (first, second): (Vec<_>, Vec<_>) = input.split_whitespace().enumerate().partition(|(i, _)| i % 2 == 0);
    let first: Vec<i32> = first.into_iter().map(|(_, s)| s.parse().unwrap()).collect();
    let second: Vec<i32> = second.into_iter().map(|(_, s)| s.parse().unwrap()).collect();

    let frequency = second.into_iter().fold(HashMap::new(), |mut map, i| {
        *map.entry(i).or_insert(0) += 1;
        map
    });

    first.into_iter().map(|i| i * frequency.get(&i).unwrap_or(&0)).sum()
}
