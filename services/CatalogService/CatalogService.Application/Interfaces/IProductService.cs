using CatalogService.Application.DTOs;

namespace CatalogService.Application.Interfaces;

public interface IProductService
{
    Task<ProductDto?> GetByIdAsync(string id);
    Task<IEnumerable<ProductDto>> GetAllAsync();
    Task<IEnumerable<ProductDto>> GetByCategoryAsync(string categoryId);
    Task<IEnumerable<ProductDto>> SearchAsync(string searchTerm);
    Task<ProductDto> CreateAsync(CreateProductRequest request);
    Task<ProductDto> UpdateAsync(string id, UpdateProductRequest request);
    Task<bool> DeleteAsync(string id);
}

