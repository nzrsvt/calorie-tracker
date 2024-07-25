# Generated by Django 5.0 on 2024-07-25 12:29

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('tracker', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='usermeal',
            name='portion_carbohydrates',
            field=models.FloatField(default=10, editable=False),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name='usermeal',
            name='portion_fat',
            field=models.FloatField(default=10, editable=False),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name='usermeal',
            name='portion_proteins',
            field=models.FloatField(default=10, editable=False),
            preserve_default=False,
        ),
    ]
