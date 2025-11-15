using AutoMapper;
using CartService.Application.DTOs;
using CartService.Domain.Entities;

namespace CartService.Application.Mapping;

public class MappingProfile : Profile
{
    public MappingProfile()
    {
        CreateMap<Cart, CartDto>();
        CreateMap<CartItem, CartItemDto>();
    }
}

