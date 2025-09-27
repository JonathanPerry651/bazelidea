package bazelidea;

import foo.bar.baz.TheCodegen;

public class Example {
    public static void main(String[] args) {
        // Vanilla sync project leaves all of these unresolved.
        // 'generate sources and resync' works. How should developers figure out which to click?

        // If you jump into any of these classes, you get decompiled java rather than the original sources
        System.out.println(TheCodegen.class);
        System.out.println(wibble.wobble.AThirdCodeGen.class);

        // The third party reference to guava inside here also turns up as decompiled java
        System.out.println(wibble.wobble.AThirdCodeGen.getRefs());

        // For a repo of reasonable size and complexity, it's very slow to have to do a full resync every time I change codegen.bzl
        // in order to pick up changes in my ide.
    }
}