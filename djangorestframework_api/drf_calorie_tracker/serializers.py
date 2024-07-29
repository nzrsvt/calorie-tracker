from tracker.models import UserProfile
from rest_framework import serializers
from django.core.validators import EmailValidator
from django.contrib.auth.password_validation import validate_password

class RegisterSerializer(serializers.ModelSerializer):
    email = serializers.EmailField(
        validators=[EmailValidator(message="Enter a valid email address.")]
    )
    password = serializers.CharField(
        write_only=True,
        validators=[validate_password]
    )

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
