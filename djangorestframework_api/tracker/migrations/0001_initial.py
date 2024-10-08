# Generated by Django 5.0 on 2024-08-19 07:15

import django.contrib.auth.models
import django.contrib.auth.validators
import django.core.validators
import django.db.models.deletion
import django.utils.timezone
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('auth', '0012_alter_user_first_name_max_length'),
    ]

    operations = [
        migrations.CreateModel(
            name='UserProfile',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('password', models.CharField(max_length=128, verbose_name='password')),
                ('last_login', models.DateTimeField(blank=True, null=True, verbose_name='last login')),
                ('is_superuser', models.BooleanField(default=False, help_text='Designates that this user has all permissions without explicitly assigning them.', verbose_name='superuser status')),
                ('username', models.CharField(error_messages={'unique': 'A user with that username already exists.'}, help_text='Required. 150 characters or fewer. Letters, digits and @/./+/-/_ only.', max_length=150, unique=True, validators=[django.contrib.auth.validators.UnicodeUsernameValidator()], verbose_name='username')),
                ('first_name', models.CharField(blank=True, max_length=150, verbose_name='first name')),
                ('last_name', models.CharField(blank=True, max_length=150, verbose_name='last name')),
                ('email', models.EmailField(blank=True, max_length=254, verbose_name='email address')),
                ('is_staff', models.BooleanField(default=False, help_text='Designates whether the user can log into this admin site.', verbose_name='staff status')),
                ('is_active', models.BooleanField(default=True, help_text='Designates whether this user should be treated as active. Unselect this instead of deleting accounts.', verbose_name='active')),
                ('date_joined', models.DateTimeField(default=django.utils.timezone.now, verbose_name='date joined')),
                ('gender', models.CharField(choices=[('M', 'Male'), ('F', 'Female')], max_length=1)),
                ('age', models.PositiveIntegerField(validators=[django.core.validators.MinValueValidator(1), django.core.validators.MaxValueValidator(120)])),
                ('height', models.PositiveIntegerField(validators=[django.core.validators.MinValueValidator(50), django.core.validators.MaxValueValidator(300)])),
                ('weight', models.FloatField(validators=[django.core.validators.MinValueValidator(20), django.core.validators.MaxValueValidator(500)])),
                ('activity_level', models.CharField(choices=[('S', 'Sedentary'), ('L', 'Lightly active'), ('M', 'Moderately active'), ('V', 'Very active'), ('E', 'Extra active')], max_length=1)),
                ('goal', models.CharField(choices=[('L', 'Weight loss'), ('M', 'Weight maintenance'), ('G', 'Weight gain')], max_length=1)),
                ('calorie_intake', models.FloatField(default=0)),
                ('protein_intake', models.FloatField(default=0)),
                ('fat_intake', models.FloatField(default=0)),
                ('carbohydrate_intake', models.FloatField(default=0)),
                ('groups', models.ManyToManyField(blank=True, help_text='The groups this user belongs to. A user will get all permissions granted to each of their groups.', related_name='user_set', related_query_name='user', to='auth.group', verbose_name='groups')),
                ('user_permissions', models.ManyToManyField(blank=True, help_text='Specific permissions for this user.', related_name='user_set', related_query_name='user', to='auth.permission', verbose_name='user permissions')),
            ],
            options={
                'verbose_name': 'user',
                'verbose_name_plural': 'users',
                'abstract': False,
            },
            managers=[
                ('objects', django.contrib.auth.models.UserManager()),
            ],
        ),
        migrations.CreateModel(
            name='FoodItem',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=100)),
                ('producer', models.CharField(max_length=100)),
                ('calories', models.FloatField()),
                ('protein', models.FloatField(default=0)),
                ('fat', models.FloatField(default=0)),
                ('carbohydrates', models.FloatField(default=0)),
                ('portion_size', models.FloatField()),
                ('quantity_unit', models.CharField(choices=[('g', 'Grams'), ('ml', 'Milliliters'), ('pcs', 'Pieces')], default='g', max_length=3)),
                ('owner', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='fooditems', to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name='UserMeal',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('datetime', models.DateTimeField(auto_now_add=True)),
                ('meal_type', models.CharField(choices=[('breakfast', 'Breakfast'), ('morning_snack', 'Morning Snack'), ('lunch', 'Lunch'), ('afternoon_snack', 'Afternoon Snack'), ('dinner', 'Dinner'), ('evening_snack', 'Evening Snack')], max_length=20)),
                ('quantity', models.FloatField()),
                ('portion_calories', models.FloatField(editable=False)),
                ('portion_fat', models.FloatField(editable=False)),
                ('portion_carbohydrates', models.FloatField(editable=False)),
                ('portion_proteins', models.FloatField(editable=False)),
                ('food_item', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='meals', to='tracker.fooditem')),
                ('owner', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='meals', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'ordering': ['-datetime'],
            },
        ),
    ]
