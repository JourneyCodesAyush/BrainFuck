project(
  'brainfuck',
  'cpp',
  version: '0.1.0',
  meson_version: '>=1.3.0',
  default_options: [
    'cpp_std=c++17',
    'warning_level=2',
  ],
)

python = import('python').find_installation()

inc = include_directories('src')

# Shared interpreter implementation.
engine_sources = files(
  'src/char_interpreter/interpreter.cpp',
  'src/ir_vm/optimization/optimizer.cpp',
  'src/ir_vm/parser/parser.cpp',
  'src/ir_vm/virtual-machine/vm.cpp',
  'src/runner/brainfuck-runner.cpp',
)

if meson.is_cross_build()
  # WebAssembly build: use em++ from emscripten.ini.
  executable(
    'brainfuck',
    files('web/web_api.cpp'),
    engine_sources,
    include_directories: inc,
    cpp_args: ['-Wall', '-O2'],
    link_args: [
      '-O2',
      '--no-entry',
      '-sMODULARIZE=1',
      '-sEXPORT_ES6=1',
      '-sEXPORTED_FUNCTIONS=["_run_brainfuck"]',
      '-sEXPORTED_RUNTIME_METHODS=["ccall"]',
      '-sALLOW_MEMORY_GROWTH=1',
      '-sSTACK_SIZE=1048576',
      '-sINITIAL_MEMORY=67108864',
      '-sASSERTIONS=2',
      '-sSTACK_OVERFLOW_CHECK=2',
    ],
    name_suffix: 'js',
    install: false,
  )

  # Stage the frontend alongside brainfuck.js and brainfuck.wasm.
  configure_file(
    input: 'web/index.html',
    output: 'index.html',
    copy: true,
  )

  configure_file(
    input: 'web/app.js',
    output: 'app.js',
    copy: true,
  )

  # Serve the complete WebAssembly build directory.
  run_target(
    'serve',
    command: [
      python.full_path(),
      '-m',
      'http.server',
      '8000',
      '-d',
      meson.current_build_dir(),
    ],
  )
else
  # Native build: include the regular C++ entry point.
  executable(
    'brainfuck',
    files('src/main.cpp'),
    engine_sources,
    include_directories: inc,
    cpp_args: ['-Wall'],
    install: false,
  )
endif
