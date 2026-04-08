from django.db import models


class BaseModel(models.Model):
    """
    Use this as a common parent for other models

    All base functionality/fields added here
    """

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True
