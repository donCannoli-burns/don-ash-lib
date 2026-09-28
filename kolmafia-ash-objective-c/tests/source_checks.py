from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
h = (root / "include/KMAsh.h").read_text()
m = (root / "src/KMAsh.m").read_text()
smoke = (root / "examples/smoke.m").read_text()

assert "/KoLmafia/jsonApi" in m
assert "application/x-www-form-urlencoded" in m
assert '@"body"' in m and '@"pwd"' in m
assert "KMAshCamelCaseFunctionName" in h and "KMAshCamelCaseFunctionName" in m
assert 'KMAshItem(@"seal-clubbing club")' in smoke
assert "allowsRemoteEndpoint" in h and "isLoopbackHost" in m
for name in ["set_property", "cli_execute", "visit_url"]:
    assert name in m

# Ensure every public enum helper macro expansion has a corresponding implementation.
public_types = re.findall(r"KMASH_DECLARE_ENUM_HELPERS\((\w+)\);", h)
for name in public_types:
    assert f"KMASH_DEFINE_ENUM_HELPERS({name}," in m

# Basic brace balance after stripping strings/comments would be overkill; this catches gross truncation.
assert m.count("@implementation") == m.count("@end") - 2  # two class extensions + implementations structure

print("source checks: PASS")
print("enum helper families:", len(public_types))
