"""
URL configuration for web_core project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""

from django.contrib import admin
from django.urls import path, include
from pathlib import Path

from web_core.core._utils.workspace_urls import build_workspace_patterns

workspace_path = Path(__file__).resolve().parent / "workspace"

urlpatterns = [
    path("admin/", admin.site.urls),
]

for workspace_pattern in build_workspace_patterns(
        module_file="urls", 
        workspace_path=workspace_path):
    urlpatterns.append(path(f"{workspace_pattern['module']}/", include(workspace_pattern['pattern'])))

for workspace_pattern in build_workspace_patterns(
        module_file="urls_api", 
        workspace_path=workspace_path):
    urlpatterns.append(path(f"api/{workspace_pattern['module']}/", include(workspace_pattern['pattern'])))

