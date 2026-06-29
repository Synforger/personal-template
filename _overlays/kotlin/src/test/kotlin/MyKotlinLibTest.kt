package com.example.mykotlinlib

import kotlin.test.Test
import kotlin.test.assertEquals

class MyKotlinLibTest {
    @Test
    fun testHello() {
        assertEquals("hello, world!", MyKotlinLib.hello("world"))
    }
}
