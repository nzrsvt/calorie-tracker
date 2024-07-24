from rest_framework import serializers

from tracker.models import FoodItem, UserMeal, UserProfile


class FoodItemSerializer(serializers.ModelSerializer):
    owner = serializers.ReadOnlyField(source='owner.username')

    class Meta:
        model = FoodItem
        fields = '__all__'
        read_only_fields = ['owner']
        

class UserMealSerializer(serializers.ModelSerializer):
    owner = serializers.ReadOnlyField(source='owner.username')
    food_item = serializers.PrimaryKeyRelatedField(queryset=FoodItem.objects.all())
    food_item_detail = FoodItemSerializer(source='food_item', read_only=True)
    
    class Meta:
        model = UserMeal
        fields = ['id', 'owner', 'food_item', 'food_item_detail', 'quantity', 'datetime', 'portion_calories']
        depth = 1