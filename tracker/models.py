from django.db import models
from django.contrib.auth.models import User
from django.core.exceptions import ValidationError
from django.utils.translation import gettext_lazy as _

class FoodItem(models.Model):
    name = models.CharField(max_length=100)
    producer = models.CharField(max_length=100)

    calories = models.PositiveIntegerField()
    protein = models.FloatField()
    fat = models.FloatField()
    carbohydrates = models.FloatField()
    portion_size = models.FloatField()

    GRAMS = 'g'
    MILLILITERS = 'ml'
    PIECES = 'pcs'
    UNIT_CHOICES = [
        (GRAMS, 'Grams'),
        (MILLILITERS, 'Milliliters'),
        (PIECES, 'Pieces'),
    ]
    
    quantity_unit = models.CharField(max_length=3, choices=UNIT_CHOICES, default=GRAMS)

    def clean(self):
        if self.protein < 0:
            raise ValidationError(_('Protein value cannot be negative'))
        if self.fat < 0:
            raise ValidationError(_('Fat value cannot be negative'))
        if self.carbohydrates < 0:
            raise ValidationError(_('Carbohydrates value cannot be negative'))

    def save(self, *args, **kwargs):
        self.clean()
        super().save(*args, **kwargs)


class UserMeal(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='meals')
    food_item = models.ForeignKey(FoodItem, on_delete=models.CASCADE, related_name='meals')
    datetime = models.DateTimeField(auto_now_add=True)

    quantity = models.FloatField()  

    class Meta:
        ordering = ['-datetime']

    def clean(self):
        if self.quantity <= 0:
            raise ValidationError(_('Quantity must be positive'))

    def save(self, *args, **kwargs):
        self.clean()
        super().save(*args, **kwargs)