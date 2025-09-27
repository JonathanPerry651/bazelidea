_reference = provider(fields = {
    "package": "",
    "clazz": "",
    "java_info": "",
})

def _codegen_impl(ctx):
    package = ctx.attr.package
    clazz = ctx.attr.name

    # Generate a Java source file
    src = ctx.actions.declare_file(clazz + ".java")
    ctx.actions.write(
        output = src,
        content = """
        package %s;

        public class %s {
           public static String getRefs() {
               return %s;
           }
        }
        """ % (
            package,
            clazz,
            "+".join(["\"\""] + [ref.package + "." + ref.clazz + ".class" for ref in [r[_reference] for r in ctx.attr.references]]),
        ),
    )

    # Compile the generated source into a jar
    output_jar = ctx.actions.declare_file(ctx.attr.name + ".jar")
    java_info = java_common.compile(
        ctx = ctx,
        source_files = [src],
        output = output_jar,
        deps = [r[JavaInfo] for r in ctx.attr.references],
        java_toolchain = ctx.toolchains["@bazel_tools//tools/jdk:toolchain_type"].java,
    )

    return [_reference(package = package, clazz = clazz, java_info = java_info), java_info, DefaultInfo(files = depset([output_jar]))]

codegen = rule(
    fragments = ["java"],
    implementation = _codegen_impl,
    attrs = {
        "references": attr.label_list(providers = [_reference]),
        "package": attr.string(),
    },
    toolchains = ["@bazel_tools//tools/jdk:toolchain_type"],
)

def _make_a_ref(ctx):
    return [
        _reference(package = ctx.attr.package, clazz = ctx.attr.clazz, java_info = [ctx.attr.where_to_find_it[JavaInfo]]),
        ctx.attr.where_to_find_it[JavaInfo],
    ]

make_a_ref = rule(
    implementation = _make_a_ref,
    attrs = {"package": attr.string(), "clazz": attr.string(), "where_to_find_it": attr.label(providers = [JavaInfo])},
)
