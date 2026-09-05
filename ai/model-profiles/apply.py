#!/usr/bin/env python3
import argparse
import copy
import datetime
import json
import shutil
import subprocess
from pathlib import Path


def load_manifest(path):
    data = json.loads(path.read_text())
    if data.get("version") != 1:
        raise ValueError("Unsupported model-profile manifest version")
    return data


def set_assignment(agent, model, effort):
    agent["model"] = model
    agent["variant"] = effort
    agent.pop("reasoningEffort", None)
    options = agent.get("options")
    if isinstance(options, dict):
        options.pop("reasoningEffort", None)
        if not options:
            agent.pop("options", None)


def patch_opencode(data, manifest):
    agents = data.get("agent") or data.get("agents")
    if not isinstance(agents, dict):
        raise ValueError("OpenCode agent map not found")

    config = manifest["opencode"]
    default_name = config["default_profile"]
    default = config["profiles"][default_name]
    set_assignment(agents["gentle-orchestrator"], *default["orchestrator"])
    for phase, assignment in default["phases"].items():
        set_assignment(agents[phase], *assignment)

    for profile_name, profile in config["profiles"].items():
        orchestrator = "sdd-orchestrator-" + profile_name
        set_assignment(agents[orchestrator], *profile["orchestrator"])
        for phase, assignment in profile["phases"].items():
            set_assignment(agents[phase + "-" + profile_name], *assignment)

    if "dangerous-gentleman-fast" not in agents:
        agents["dangerous-gentleman-fast"] = copy.deepcopy(agents["dangerous-gentleman"])
        agents["dangerous-gentleman-fast"]["description"] = (
            "Gentleman Fast with full permissions - no restrictions, no questions asked"
        )

    for name, assignment in config["agents"].items():
        set_assignment(agents[name], *assignment)
    return data


def patch_state(data, manifest):
    assignments = data.setdefault("model_assignments", {})
    config = manifest["opencode"]
    default = config["profiles"][config["default_profile"]]
    selected = {"gentle-orchestrator": default["orchestrator"], **default["phases"]}
    selected.update(config["agents"])
    for name, (qualified_model, _effort) in selected.items():
        provider, model = qualified_model.split("/", 1)
        assignments[name] = {"provider_id": provider, "model_id": model}
    return data


def gentle_sync_args(manifest, dry_run):
    args = [
        "gentle-ai",
        "sync",
        "--agent",
        "opencode",
        "--sdd-profile-strategy",
        "generated-multi",
    ]
    for name, profile in manifest["opencode"]["profiles"].items():
        args += ["--profile", name + ":" + profile["orchestrator"][0]]
        for phase, assignment in profile["phases"].items():
            args += ["--profile-phase", name + ":" + phase + ":" + assignment[0]]
    if dry_run:
        args.append("--dry-run")
    return args


def write_json(path, data):
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
    temporary.replace(path)


def render_codex_profile(values):
    model, effort, tier, dangerous = values
    lines = [
        'service_tier = "' + tier + '"',
        'model = "' + model + '"',
        'model_reasoning_effort = "' + effort + '"',
    ]
    if dangerous:
        lines += ['approval_policy = "never"', 'sandbox_mode = "danger-full-access"']
    return "\n".join(lines) + "\n"


def backup(paths, home):
    stamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    destination = home / ".dotfiles-backups" / "model-profiles" / stamp
    destination.mkdir(parents=True, exist_ok=True)
    for path in paths:
        if path.exists():
            relative = path.relative_to(home)
            target = destination / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, target)
    return destination


def main():
    parser = argparse.ArgumentParser(description="Apply portable SDD model profiles")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--home", type=Path, default=Path.home())
    parser.add_argument("--skip-gentle-sync", action="store_true", help=argparse.SUPPRESS)
    args = parser.parse_args()

    manifest_path = Path(__file__).with_name("openai-sdd.json")
    manifest = load_manifest(manifest_path)
    home = args.home.expanduser().resolve()
    opencode_path = home / ".config" / "opencode" / "opencode.json"
    state_path = home / ".gentle-ai" / "state.json"
    codex_dir = home / ".codex"

    targets = [opencode_path, state_path]
    targets += [
        codex_dir / (name + ".config.toml")
        for name in manifest["codex"]["profiles"]
    ]
    if args.dry_run:
        command = gentle_sync_args(manifest, True)
        print("Gentle AI:", " ".join(command))
        if not args.skip_gentle_sync:
            subprocess.run(command, check=True)
        for target in targets:
            print("Would update:", target)
        return

    if not opencode_path.is_file() or not state_path.is_file():
        raise SystemExit("Run gentle-ai install for OpenCode before applying profiles")

    backup_path = backup(targets, home)
    command = gentle_sync_args(manifest, False)
    print("Gentle AI:", " ".join(command))
    if not args.skip_gentle_sync:
        subprocess.run(command, check=True)

    opencode = patch_opencode(json.loads(opencode_path.read_text()), manifest)
    state = patch_state(json.loads(state_path.read_text()), manifest)
    write_json(opencode_path, opencode)
    write_json(state_path, state)

    codex_dir.mkdir(parents=True, exist_ok=True)
    for name, values in manifest["codex"]["profiles"].items():
        (codex_dir / (name + ".config.toml")).write_text(render_codex_profile(values))

    print("Backup:", backup_path)
    print("Portable SDD model profiles applied")


if __name__ == "__main__":
    main()
