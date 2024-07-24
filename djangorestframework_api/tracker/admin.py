from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import UserProfile

class CustomUserAdmin(UserAdmin):
    model = UserProfile
    fieldsets = UserAdmin.fieldsets + (
        (None, {'fields': ('age', 'gender', 'height', 'weight', 'activity_level', 'goal', 'calorie_intake', 'protein_intake', 'fat_intake', 'carbohydrate_intake')}),
    )

admin.site.register(UserProfile, CustomUserAdmin)
