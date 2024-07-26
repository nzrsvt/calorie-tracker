from django.urls import path, include
from rest_framework.routers import DefaultRouter

from tracker import views

router = DefaultRouter()
router.register(r'fooditems', views.FoodItemViewSet, basename='fooditem')
router.register(r'usermeals', views.UserMealViewSet, basename='usermeal')
router.register(r'userprofile', views.UserProfileViewSet, basename='userprofile')


urlpatterns = [
    path('', include(router.urls)),
    path('usermeals/today/', views.UserMealViewSet.as_view({'get': 'today'}), name='usermeals-today'),
]
