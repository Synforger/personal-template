// MyKotlinLib — library entry
// `personalize.py` will rename the package + class names.

package com.example.mykotlinlib

object MyKotlinLib {
    const val VERSION = "0.1.13"

    fun hello(name: String): String = "hello, $name!"
}
