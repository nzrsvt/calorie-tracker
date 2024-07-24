from tracker.models import UserProfile
from rest_framework import serializers

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = UserProfile
        fields = (
            'username', 'password', 'email', 'gender', 'age', 
            'height', 'weight', 'activity_level', 'goal'
        )

    def create(self, validated_data):
        user_profile = UserProfile.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password'],
            gender=validated_data['gender'],
            age=validated_data['age'],
            height=validated_data['height'],
            weight=validated_data['weight'],
            activity_level=validated_data['activity_level'],
            goal=validated_data['goal'],
        )
        return user_profile
