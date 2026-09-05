import copy
import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "model_profiles", ROOT / "ai/model-profiles/apply.py"
)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class ModelProfileTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.manifest = MODULE.load_manifest(
            ROOT / "ai/model-profiles/openai-sdd.json"
        )

    def fixture(self):
        agents = {}
        phases = self.manifest["opencode"]["profiles"]["quality"]["phases"]
        for name in ["gentle-orchestrator", "dangerous-gentleman", *phases]:
            agents[name] = {"model": "old", "variant": "low"}
        for profile in self.manifest["opencode"]["profiles"]:
            agents["sdd-orchestrator-" + profile] = {"model": "old"}
            for phase in phases:
                agents[phase + "-" + profile] = {"model": "old"}
        for name in self.manifest["opencode"]["agents"]:
            if name != "dangerous-gentleman-fast":
                agents.setdefault(name, {"model": "old"})
        return {"agent": agents}

    def test_patch_is_idempotent_and_preserves_permissions(self):
        data = self.fixture()
        data["agent"]["dangerous-gentleman"]["permission"] = {"bash": "allow"}
        once = MODULE.patch_opencode(data, self.manifest)
        twice = MODULE.patch_opencode(copy.deepcopy(once), self.manifest)
        self.assertEqual(once, twice)
        fast = twice["agent"]["dangerous-gentleman-fast"]
        self.assertEqual("openai/gpt-5.6-sol-fast", fast["model"])
        self.assertEqual({"bash": "allow"}, fast["permission"])
        self.assertEqual(
            "openai/gpt-6-astra-fast",
            twice["agent"]["sdd-design-quality-fast"]["model"],
        )

    def test_codex_profiles_are_portable(self):
        for values in self.manifest["codex"]["profiles"].values():
            rendered = MODULE.render_codex_profile(values)
            self.assertNotIn("/Users/", rendered)
            self.assertNotIn("/home/", rendered)
            self.assertNotIn("sk-", rendered)

    def test_dry_run_does_not_write(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            result = MODULE.gentle_sync_args(self.manifest, True)
            self.assertIn("--dry-run", result)
            self.assertFalse((home / ".codex").exists())


if __name__ == "__main__":
    unittest.main()
