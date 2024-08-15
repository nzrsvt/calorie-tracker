from django.shortcuts import render
from rest_framework import viewsets, permissions, filters
from .permissions import IsOwnerOrReadOnly
from .models import FoodItem, UserMeal, UserProfile
from .serializers import FoodItemSerializer, UserMealSerializer, UserProfileSerializer
from django.utils import timezone
from django.utils.dateparse import parse_datetime
from datetime import datetime, timedelta
from rest_framework.decorators import action
from rest_framework.response import Response
from ai21 import AI21Client
from ai21.models.chat import ChatMessage
import os
from dotenv import load_dotenv
import re
import json

class UserProfileViewSet(viewsets.ModelViewSet):
    queryset = UserProfile.objects.all()
    serializer_class = UserProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return UserProfile.objects.filter(id=self.request.user.id)

    def perform_update(self, serializer):
        serializer.save(user=self.request.user)
    
class FoodItemViewSet(viewsets.ModelViewSet):
    queryset = FoodItem.objects.all()
    serializer_class = FoodItemSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly, IsOwnerOrReadOnly,)
    filter_backends = (filters.SearchFilter,)
    search_fields = ["name", "producer",]

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)

    @action(detail=False, methods=['post'])
    def calculate_nutritional_value(self, request):
        load_dotenv()
        api_key = os.getenv("AI21_API_KEY")

        client = AI21Client(api_key=api_key)

        description = request.data.get('description')

        pre_prompt = (
            "You are an AI used for calculations in a mobile calorie counting app. "
            "Your task is to generate only a JSON response based on the input description. "
            "I will provide you with a description of a dish. Extract the ingredients and their amounts from the description. "
            "First, calculate the total nutritional values (calories, protein, fat, carbohydrates) for the entire dish by summing the values of each ingredient. "
            "Next, determine the total weight of the dish by summing the weight of all ingredients. "
            "Return only the nutritional values in JSON format with the following keys: 'calories', 'protein', 'fat', 'carbohydrates', 'weight'. "
            "Do not include any explanations, calculation steps, or text outside of the JSON. "
            "If any value cannot be calculated, return an empty JSON object."
        )


        prompt_input = f"Dish description: {description}"

        full_prompt = f"{pre_prompt}\n{prompt_input}"

        messages = [
            ChatMessage(role="user", content=full_prompt)
        ]

        response = client.chat.completions.create(
            model="jamba-instruct-preview",
            messages=messages,
            top_p=0.8,  # Налаштування для гнучкості відповідей
            temperature=0.1  # Трохи знижено для більшої точності
        )
        
        full_response = response.dict()
        assistant_content = full_response["choices"][0]["message"]["content"]
        

        try:
            nutritional_data = json.loads(assistant_content)
            for nutrient in nutritional_data:
                print(nutritional_data[nutrient])
                nutritional_data[nutrient] = round((nutritional_data[nutrient] / (nutritional_data["weight"] / 100)), 2)
        except json.JSONDecodeError:
            nutritional_data = {}
            
        return Response(nutritional_data)

class UserMealViewSet(viewsets.ModelViewSet):
    queryset = UserMeal.objects.all()
    serializer_class = UserMealSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,
                          IsOwnerOrReadOnly,)
    
    def get_queryset(self):
        return UserMeal.objects.filter(owner=self.request.user)

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)

    @action(detail=False, methods=['get'], permission_classes=[permissions.IsAuthenticated])
    def today(self, request):
        now = timezone.now()
        today_start = datetime.combine(now, datetime.min.time())
        today_end = today_start + timedelta(days=1)

        queryset = self.get_queryset().filter(datetime__range=(today_start, today_end))
        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)