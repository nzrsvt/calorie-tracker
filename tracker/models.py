from django.db import models
from django.contrib.auth.models import User

class FoodItem(models.Model):
    name = models.CharField(max_length=100, unique=True)
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

class UserMeal(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='meals')
    food_item = models.ForeignKey(FoodItem, on_delete=models.CASCADE, related_name='meals')
    datetime = models.DateTimeField(auto_now_add=True)

    quantity = models.FloatField()  

    class Meta:
        ordering = ['-datetime']