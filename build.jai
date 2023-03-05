#import "Compiler";
#import "BuildCpp";
#import "File_Utilities";
#import "Basic";
#import "String";
#import "File";
#import "Bindings_Generator";

#run {
    set_build_options_dc(.{do_output=false});

    debug := false;
    // build_options := get_build_options();
    // for build_options.compile_time_command_line {
    //     if it == "debug" then debug = true;
    // }

    extra: [..]string;
    src: [..]string;

    array_add(*src, "physx_api.cpp");

    array_add(*extra, "/I", "physx-sys\\PhysX\\physx\\include");
    array_add(*extra, "/I", "physx-sys\\PhysX\\pxshared\\include");
    array_add(*extra, "-DNDEBUG");

    log("srcs:  %\n", src);
    log("debug: %\n", debug);
    log("extra: %\n", extra);

    log("-------------------------- BUILDING STATIC LIBRARY --------------------------\n");
    make_directory_if_it_does_not_exist("win");
    build_cpp_static_lib("win/physx_lib", ..src, debug=debug, extra=extra);

    opts: Generate_Bindings_Options;
    {
        using opts;

        array_add(*libpaths, "win");
        array_add(*libnames, "physx_lib");

        array_add(*source_files, "physx_api.cpp");

        array_add(*extra_clang_arguments, "-x", "c++");
        array_add(*extra_clang_arguments, "-Iphysx-sys/PhysX/physx/include");
        array_add(*extra_clang_arguments, "-Iphysx-sys/PhysX/pxshared/include");
        array_add(*extra_clang_arguments, "-DNDEBUG");
        array_add(*extra_clang_arguments, "-e", "physx_dummy_main");
        array_add(*extra_clang_arguments, "-D_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH");
        
        generate_compile_time_struct_checks = true;

        visitor = cp_visitor;
    }

    ok := generate_bindings(opts, "module.jai");
    assert(ok);
};

cp_visitor :: (decl: *Declaration, parent_decl: *Declaration) -> Declaration_Visit_Result {
    return .RECURSE;
}