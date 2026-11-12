{ inputs, ... }:

{
  flake.modules.homeManager.agent-skills = {
    imports = [ inputs.agent-skills.homeManagerModules.default ];

    programs.agent-skills = {
      enable = true;

      sources.quarkus = {
        input = "quarkus-skills";
        subdir = "skills";
      };

      sources.deslop = {
        input = "deslop-text";
        subdir = "skills";
      };

      sources.rea = {
        input = "rea-skills";
        subdir = "skills";
      };

      skills.enable = [
        "deslop-text"
        "migrate-spring-to-quarkus"
        "quarkus-update"
        "reverse-engineer-anything"
      ];

      targets.agents.enable = true;
    };
  };
}
