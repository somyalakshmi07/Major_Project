using CatalogService.Application.DTOs;

namespace CatalogService.Application.Interfaces;

public interface ICategoryService
{
    Task<CategoryDto?> GetByIdAsync(string id);
    Task<IEnumerable<CategoryDto>> GetAllAsync();
    Task<CategoryDto> CreateAsync(CreateCategoryRequest request);
    Task<CategoryDto> UpdateAsync(string id, UpdateCategoryRequest request);
    Task<bool> DeleteAsync(string id);
}

