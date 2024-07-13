from django.shortcuts import render
from rest_framework import viewsets, permissions, filters
from .permissions import IsOwnerOrReadOnly
from .models import FoodItem, UserMeal
from .serializers import FoodItemSerializer, UserMealSerializer


class FoodItemViewSet(viewsets.ModelViewSet):
    queryset = FoodItem.objects.all()
    serializer_class = FoodItemSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,
                          IsOwnerOrReadOnly,)
    filter_backends = (filters.SearchFilter,)
    search_fields = ["name", "producer",]

    def perform_create(self, serializer):
        print(f'User creating FoodItem: {self.request.user}')
        serializer.save(owner=self.request.user)

class UserMealViewSet(viewsets.ModelViewSet):
    queryset = UserMeal.objects.all()
    serializer_class = UserMealSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,
                          IsOwnerOrReadOnly,)
    
    def get_queryset(self):
        return UserMeal.objects.filter(owner=self.request.user)

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)