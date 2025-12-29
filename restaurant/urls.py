from django.urls import path
from . import views
from rest_framework.authtoken.views import obtain_auth_token

# Define URL routes for the restaurant app
urlpatterns = [
    path('', views.index, name='index'),         # Route for the homepage
    path('menu/', views.MenuItemsView.as_view(), name='menu'),   # Route for the menu items page
    path('menu/<int:pk>', views.SingleMenuItemView.as_view(), name='single-menu-item'),  # Route for single menu item operations
    path('api-token-auth/', obtain_auth_token), # Route for obtaining auth token
]