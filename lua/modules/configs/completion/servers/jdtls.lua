return {
  flags = { debounce_text_changes = 500 },
  settings = {
    root_dir = {
      -- Single-module projects
      {
        "build.xml", -- Ant
        "pom.xml", -- Maven
        "settings.gradle", -- Gradle
        "settings.gradle.kts", -- Gradle
      },
      -- Multi-module projects
      { "build.gradle", "build.gradle.kts" },
      { "$BENTOML_GIT_ROOT/grpc-client/java" },
      { "$BENTOML_GIT_ROOT/grpc-client/kotlin" },
    } or vim.fn.getcwd(),
  },
}
