from django.urls import path, include
from rest_framework.routers import DefaultRouter

from tracker import views

router = DefaultRouter()
router.register(r'fooditems', views.FoodItemViewSet, basename='fooditem')
router.register(r'usermeals', views.UserMealViewSet, basename='usermeal')

urlpatterns = [
    path('', include(router.urls)),
]
