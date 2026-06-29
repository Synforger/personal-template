using Xunit;
using MyCsharpLib;

namespace MyCsharpLib.Tests;

public class GreeterTests
{
    [Fact]
    [Trait("Category", "Unit")]
    public void Hello_GreetsName()
    {
        Assert.Equal("hello, world!", Greeter.Hello("world"));
    }
}
