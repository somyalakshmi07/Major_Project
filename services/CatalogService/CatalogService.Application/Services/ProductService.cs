using AutoMapper;
using CatalogService.Application.DTOs;
using CatalogService.Application.Interfaces;
using CatalogService.Domain.Entities;
using CatalogService.Domain.Repositories;

namespace CatalogService.Application.Services;

public class ProductService : IProductService
{
    private readonly IProductRepository _productRepository;
    private readonly ICategoryRepository _categoryRepository;
    private readonly IMapper _mapper;

    public ProductService(IProductRepository productRepository, ICategoryRepository categoryRepository, IMapper mapper)
    {
        _productRepository = productRepository;
        _categoryRepository = categoryRepository;
        _mapper = mapper;
    }

    public async Task<ProductDto?> GetByIdAsync(string id)
    {
        var product = await _productRepository.GetByIdAsync(id);
        return product == null ? null : _mapper.Map<ProductDto>(product);
    }

    public async Task<IEnumerable<ProductDto>> GetAllAsync()
    {
        var products = await _productRepository.GetAllAsync();
        return _mapper.Map<IEnumerable<ProductDto>>(products);
    }

    public async Task<IEnumerable<ProductDto>> GetByCategoryAsync(string categoryId)
    {
        var products = await _productRepository.GetByCategoryAsync(categoryId);
        return _mapper.Map<IEnumerable<ProductDto>>(products);
    }

    public async Task<IEnumerable<ProductDto>> SearchAsync(string searchTerm)
    {
        var products = await _productRepository.SearchAsync(searchTerm);
        return _mapper.Map<IEnumerable<ProductDto>>(products);
    }

    public async Task<ProductDto> CreateAsync(CreateProductRequest request)
    {
        var category = await _categoryRepository.GetByIdAsync(request.CategoryId);
        if (category == null)
        {
            throw new InvalidOperationException("Category not found.");
        }

        var product = _mapper.Map<Product>(request);
        product.CategoryName = category.Name;
        product.CreatedAt = DateTime.UtcNow;
        product.UpdatedAt = DateTime.UtcNow;

        product = await _productRepository.CreateAsync(product);
        return _mapper.Map<ProductDto>(product);
    }

    public async Task<ProductDto> UpdateAsync(string id, UpdateProductRequest request)
    {
        var product = await _productRepository.GetByIdAsync(id);
        if (product == null)
        {
            throw new InvalidOperationException("Product not found.");
        }

        if (!string.IsNullOrEmpty(request.CategoryId) && request.CategoryId != product.CategoryId)
        {
            var category = await _categoryRepository.GetByIdAsync(request.CategoryId);
            if (category == null)
            {
                throw new InvalidOperationException("Category not found.");
            }
            product.CategoryId = request.CategoryId;
            product.CategoryName = category.Name;
        }

        product.Name = request.Name;
        product.Description = request.Description;
        product.Price = request.Price;
        product.Stock = request.Stock;
        product.ImageUrl = request.ImageUrl;
        product.IsActive = request.IsActive;
        product.UpdatedAt = DateTime.UtcNow;

        product = await _productRepository.UpdateAsync(product);
        return _mapper.Map<ProductDto>(product);
    }

    public async Task<bool> DeleteAsync(string id)
    {
        return await _productRepository.DeleteAsync(id);
    }
}

