_:

{
  flake.modules.homeManager.shared = {
    programs.agent-skills = {
      enable = true;

      sources.quarkus = {
        input = "quarkus-skills";
        subdir = "skills";
      };

      skills.enable = [
        "migrate-spring-to-quarkus"
        "quarkus-update"
      ];

      targets.opencode.enable = true;
    };
  };
}
