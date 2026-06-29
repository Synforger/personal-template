use my_rust_lib::hello;

#[test]
fn integration_greets() {
    assert_eq!(hello("integration"), "hello, integration!");
}
