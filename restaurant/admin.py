from django.contrib import admin
from .models import Menu, Booking

# Register your models here.
admin.site.register(Menu) # Registering the Menu model
admin.site.register(Booking) # Registering the Booking model