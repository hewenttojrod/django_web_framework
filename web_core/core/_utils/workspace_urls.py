"""Helpers for building URL patterns from workspace extension modules."""

from __future__ import annotations

from pathlib import Path


def _has_include_target(
        module_dir: Path, 
        module_file: str
) -> bool:
    """Return True if a module leaf exists as either a module or package."""
    module_file_path: Path = module_dir / f"{module_file}.py"
    module_package_path: Path = module_dir / module_file / "__init__.py"
    return module_file_path.exists() or module_package_path.exists()


def find_workspace_modules(
        module_file: str,
        workspace_path: Path,
) -> list[str]:
    """Build include() URL patterns for all discoverable workspace modules.

    Args:
        url_prefix: Route prefix before module name, for example "" or "api/".
        include_module_leaf: Final include segment, for example "urls" or "urls_api".
        workspace_path: Filesystem path to the workspace modules directory.
        base_workspace_module: Python import prefix for discovered modules.
    """
    module_list: list[str] = []

    for module_dir in sorted(workspace_path.iterdir(), key=lambda entry: entry.name):
        if not module_dir.is_dir() or module_dir.name.startswith("_"):
            continue
        if module_file and not _has_include_target(module_dir, module_file):
            continue

        module_list.append(module_dir.name)

    return module_list

def _workspace_pattern(
        module_name: str,
        base_workspace_module: str = "web_core.workspace",
        module_file: str | None = None
) -> str:
    pattern: str = f"{base_workspace_module}.{module_name}"
    if(module_file and module_file != ""):
        pattern += f".{module_file}"
    return pattern


def build_workspace_patterns(
        module_file: str, 
        workspace_path: Path
) -> list[dict]:
    pattern_list: list[dict] = []
    module_list: list[str] = find_workspace_modules(module_file=module_file, workspace_path=workspace_path)

    for module in module_list:
        pattern_list.append({"module": module, "pattern":_workspace_pattern(module_name=module, module_file=module_file)})
    return pattern_list
    # url_prefix: str,
    # 
    #     include_path = f"{base_workspace_module}.{module_name}.{include_module_leaf}"
    #     urlpatterns.append(path(f"{url_prefix}{module_name}/", include(include_path)))