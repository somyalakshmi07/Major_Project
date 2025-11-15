using Microsoft.AspNetCore.Mvc;
using PaymentService.Application.DTOs;
using PaymentService.Application.Interfaces;

namespace PaymentService.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PaymentsController : ControllerBase
{
    private readonly IPaymentService _paymentService;

    public PaymentsController(IPaymentService paymentService)
    {
        _paymentService = paymentService;
    }

    [HttpPost("process")]
    public async Task<ActionResult<PaymentResponse>> ProcessPayment([FromBody] ProcessPaymentRequest request)
    {
        try
        {
            if (request.Amount <= 0)
            {
                return BadRequest(new { message = "Amount must be greater than zero." });
            }

            var response = await _paymentService.ProcessPaymentAsync(request);
            
            if (response.Status == "completed")
            {
                return Ok(response);
            }
            else
            {
                return BadRequest(response);
            }
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "An error occurred while processing the payment." });
        }
    }
}

