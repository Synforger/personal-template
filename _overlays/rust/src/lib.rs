// my-rust-lib — library entry
// `personalize.py` will rename the crate name + module path.

pub fn hello(name: &str) -> String {
    format!("hello, {}!", name)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_greets() {
        assert_eq!(hello("world"), "hello, world!");
    }
}
