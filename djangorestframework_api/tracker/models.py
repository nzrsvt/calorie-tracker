from django.db import models
from django.contrib.auth.models import AbstractUser
from django.core.exceptions import ValidationError
from django.utils.translation import gettext_lazy as _
from django.conf import settings
from django.core.validators import MinValueValidator, MaxValueValidator

class UserProfile(AbstractUser):
    GENDER_CHOICES = [
        ('M', 'Male'),
        ('F', 'Female'),
    ]
    ACTIVITY_CHOICES = [
        ('S', 'Sedentary'),
        ('L', 'Lightly active'),
        ('M', 'Moderately active'),
        ('V', 'Very active'),
        ('E', 'Extra active'),
    ]
    GOAL_CHOICES = [
        ('L', 'Weight loss'),
        ('M', 'Weight maintenance'),
        ('G', 'Weight gain'),
    ]

    gender = models.CharField(max_length=1, choices=GENDER_CHOICES)
    age = models.PositiveIntegerField(validators=[MinValueValidator(1), MaxValueValidator(120)])
    height = models.PositiveIntegerField(validators=[MinValueValidator(50), MaxValueValidator(300)])  # in cm
    weight = models.FloatField(validators=[MinValueValidator(20), MaxValueValidator(500)])  # in kg
    activity_level = models.CharField(max_length=1, choices=ACTIVITY_CHOICES)
    goal = models.CharField(max_length=1, choices=GOAL_CHOICES)

    calorie_intake = models.FloatField(default=0)
    protein_intake = models.FloatField(default=0)
    fat_intake = models.FloatField(default=0)
    carbohydrate_intake = models.FloatField(default=0)

    def save(self, *args, **kwargs):
        self.calculate_intakes()
        super().save(*args, **kwargs)

    def calculate_intakes(self):
        if self.gender == 'M':
            bmr = 10 * self.weight + 6.25 * self.height - 5 * self.age + 5
        else:
            bmr = 10 * self.weight + 6.25 * self.height - 5 * self.age - 161

        activity_factors = {
            'S': 1.2,
            'L': 1.375,
            'M': 1.55,
            'V': 1.725,
            'E': 1.9
        }
        ka = activity_factors[self.activity_level]

        protein_percent = 0.25
        fat_percent = 0.30
        carb_percent = 0.45

        if self.goal == 'L':
            self.calorie_intake = (bmr * ka) - 500
            protein_percent += 0.05
            fat_percent -= 0.05
        elif self.goal == 'M':
            self.calorie_intake = bmr * ka
        else:  # 'G'
            self.calorie_intake = (bmr * ka) + 500
            carb_percent += 0.05
            protein_percent -= 0.05

        if self.activity_level in ['V', 'E']:  # Very active or Extra active
            protein_percent += 0.05
            carb_percent += 0.05
            fat_percent -= 0.10

        if self.age > 50:
            protein_percent += 0.05
            fat_percent -= 0.05

        if self.gender == 'F':
            fat_percent += 0.05
            carb_percent -= 0.05

        self.protein_intake = round((self.calorie_intake * protein_percent) / 4, 1)
        self.fat_intake = round((self.calorie_intake * fat_percent) / 9, 1)
        self.carbohydrate_intake = round((self.calorie_intake * carb_percent) / 4, 1)
        self.calorie_intake = round(self.calorie_intake, 1)

class FoodItem(models.Model):
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL, related_name='fooditems', on_delete=models.CASCADE)
    name = models.CharField(max_length=100)
    producer = models.CharField(max_length=100)

    calories = models.FloatField()
    protein = models.FloatField(default=0)
    fat = models.FloatField(default=0)
    carbohydrates = models.FloatField(default=0)
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

    def __str__(self):
        return f"{self.producer} {self.name} ({self.calories} kcal per {self.portion_size} {self.quantity_unit})"

class UserMeal(models.Model):
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL, related_name='meals', on_delete=models.CASCADE)
    food_item = models.ForeignKey(FoodItem, on_delete=models.CASCADE, related_name='meals')
    datetime = models.DateTimeField(auto_now_add=True)

    quantity = models.FloatField() 
    portion_calories = models.FloatField(editable=False)
    portion_fat = models.FloatField(editable=False)
    portion_carbohydrates = models.FloatField(editable=False)
    portion_proteins = models.FloatField(editable=False)

    class Meta:
        ordering = ['-datetime']

    def clean(self):
        if self.quantity <= 0:
            raise ValidationError(_('Quantity must be positive'))

    def save(self, *args, **kwargs):
        self.portion_calories = self.calculate_portion_calories()
        self.portion_fat = self.calculate_portion_fat()
        self.portion_carbohydrates = self.calculate_portion_carbohydrates()
        self.portion_proteins = self.calculate_portion_proteins()
        super().save(*args, **kwargs)
    
    def calculate_portion_calories(self):
        return (self.quantity / self.food_item.portion_size) * self.food_item.calories

    def calculate_portion_fat(self):
        return (self.quantity / self.food_item.portion_size) * self.food_item.fat

    def calculate_portion_carbohydrates(self):
        return (self.quantity / self.food_item.portion_size) * self.food_item.carbohydrates

    def calculate_portion_proteins(self):
        return (self.quantity / self.food_item.portion_size) * self.food_item.protein
